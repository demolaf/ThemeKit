//
//  ThemeApplier.swift
//  ThemeKit
//
//  Created by Ademola on 07/06/2026.
//

import Combine
import ThemeKit
import UIKit

/// Applies a `ThemeVariant` to UIKit windows and keeps them in sync with
/// the active theme and system interface style.
///
/// Create one instance per scene and wire it up in your `SceneDelegate`:
///
/// ```swift
/// let applier = ThemeApplier(theme: theme, default: .default, available: AppColorsVariant.all)
/// applier.onAppear()
/// applier.onChangeOfThemeState()
/// applier.onChangeOfSystemUserInterfaceStyle(window: window)
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

  /// Creates a `ThemeApplier` that overrides the interface style on all connected windows.
  public init(theme: Theme, default variant: V, available: [V]) {
    self.theme = theme
    self.defaultVariant = variant
    self.available = available
    self.systemStyleProvider = { UITraitCollection.current.userInterfaceStyle }
    self.applyInterfaceStyle = { style in
      UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap(\.windows)
        .forEach { $0.overrideUserInterfaceStyle = style ?? .unspecified }
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
    self.systemStyleProvider = systemStyleProvider
    self.applyInterfaceStyle = applyInterfaceStyle
  }

  private let theme: Theme
  private let defaultVariant: V
  private let available: [V]
  private let systemStyleProvider: @MainActor () -> UIUserInterfaceStyle
  private let applyInterfaceStyle: @MainActor (UIUserInterfaceStyle?) -> Void

  public var cancellables: Set<AnyCancellable> = []

  /// Call once on scene appearance to apply the correct initial theme.
  public func onAppear() {
    handleAppear(userInterfaceStyle: systemStyleProvider())
  }

  /// Call once to begin observing theme changes for the lifetime of the scene.
  public func onChangeOfThemeState() {
    observeTheme()
  }

  /// Subscribes to interface style changes on `window` via `UITraitChangeObservable`.
  public func onChangeOfSystemUserInterfaceStyle(window: UIWindow?) {
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
        handleThemeChange()
        observeTheme()
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
