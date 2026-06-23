//
//  ThemeApplier.swift
//  ThemeKit
//
//  Created by Ademola on 07/06/2026.
//

#if canImport(UIKit)
import Combine
import ThemeKit
import UIKit

/// Applies a `ThemeVariant` to a UIKit window and keeps it in sync with
/// the active theme and system interface style.
///
/// Create one instance per scene in your scene delegate:
///
/// ```swift
/// let applier = ThemeApplier(theme: theme, default: .default, available: AppColorsVariant.all, window: window)
/// applier.onAppear()
/// applier.onChangeOfThemeState()
/// applier.onChangeOfSystemUserInterfaceStyle()
/// ```
@MainActor
public final class ThemeApplier<V: ThemeVariant> {

  @MainActor
  private enum AppearanceMode {
    case firstLaunch
    case followingSystem(V)
    case forced(V.Value)

    init(theme: Theme, available: [V], default defaultVariant: V) {
      guard theme.hasPersisted(V.Value.self) else {
        self = .firstLaunch
        return
      }
      if theme.followsSystem {
        self = .followingSystem(
          available.first { $0.id == theme.activeVariantID } ?? defaultVariant
        )
        return
      }
      self = .forced(theme.value(V.Value.self))
    }
  }

  /// Creates a `ThemeApplier` scoped to a single window.
  public init(theme: Theme, default variant: V, available: [V], window: UIWindow) {
    self.theme = theme
    self.defaultVariant = variant
    self.available = available
    self.window = window
    self.systemStyleProvider = { [weak window] in
      window?.traitCollection.userInterfaceStyle ?? UITraitCollection.current.userInterfaceStyle
    }
    self.applyInterfaceStyle = { [weak window] style in
      window?.overrideUserInterfaceStyle = style ?? .unspecified
    }
  }

  /// Creates a `ThemeApplier` with injected side-effect closures — for testing.
  init(
    theme: Theme,
    default variant: V,
    available: [V],
    systemStyleProvider: @escaping @MainActor () -> UIUserInterfaceStyle,
    applyInterfaceStyle: @escaping @MainActor (UIUserInterfaceStyle?) -> Void
  ) {
    self.theme = theme
    self.defaultVariant = variant
    self.available = available
    self.window = nil
    self.systemStyleProvider = systemStyleProvider
    self.applyInterfaceStyle = applyInterfaceStyle
  }

  private let theme: Theme
  private let defaultVariant: V
  private let available: [V]
  private weak var window: UIWindow?
  private let systemStyleProvider: @MainActor () -> UIUserInterfaceStyle
  private let applyInterfaceStyle: @MainActor (UIUserInterfaceStyle?) -> Void

  public var cancellables: Set<AnyCancellable> = []

  /// Call once on scene appearance to apply the correct initial theme.
  public func onAppear() {
    handleAppear(userInterfaceStyle: systemStyleProvider())
  }

  /// Call when the owning view controller disappears to reset the window interface style override.
  public func onDisappear() {
    applyInterfaceStyle(nil)
  }

  /// Call once to begin observing theme changes for the lifetime of the scene.
  public func onChangeOfThemeState() {
    observeTheme()
  }

  /// Subscribes to interface style changes on the window provided at init.
  public func onChangeOfSystemUserInterfaceStyle() {
    window?.traitChanges(traitEnvironment: UIWindow.self, traits: [UITraitUserInterfaceStyle.self])
      .filter { window, previous in
        window.traitCollection.hasDifferentColorAppearance(comparedTo: previous)
      }
      .sink { [weak self] (window, _) in
        self?.handleSystemStyleChange(window.traitCollection.userInterfaceStyle)
      }
      .store(in: &cancellables)
  }

  private func observeTheme() {
    withObservationTracking {
      _ = theme.value(V.Value.self)
      _ = theme.followsSystem
    } onChange: { [weak self] in
      Task { @MainActor [weak self] in
        guard let self else { return }
        self.handleThemeChange()
        self.observeTheme()
      }
    }
  }

  func handleAppear(userInterfaceStyle style: UIUserInterfaceStyle) {
    let scheme = SystemColorScheme(style)
    switch AppearanceMode(theme: theme, available: available, default: defaultVariant) {
    case .firstLaunch:
      theme.apply(variant: defaultVariant, for: scheme)
    case .followingSystem(let variant):
      theme.activeVariantID = variant.id
      theme.apply(variant.value(for: scheme))
    case .forced(let value):
      applyInterfaceStyle(value.colorScheme.uiUserInterfaceStyle)
    }
  }

  func handleThemeChange() {
    switch AppearanceMode(theme: theme, available: available, default: defaultVariant) {
    case .followingSystem(let variant):
      applyInterfaceStyle(nil)
      theme.apply(variant.value(for: SystemColorScheme(systemStyleProvider())))
    case .forced(let value):
      applyInterfaceStyle(value.colorScheme.uiUserInterfaceStyle)
    case .firstLaunch:
      break
    }
  }

  func handleSystemStyleChange(_ newStyle: UIUserInterfaceStyle) {
    guard
      case .followingSystem(let variant) = AppearanceMode(
        theme: theme, available: available, default: defaultVariant)
    else { return }
    theme.activeVariantID = variant.id
    theme.apply(variant.value(for: SystemColorScheme(newStyle)))
  }
}
#endif
