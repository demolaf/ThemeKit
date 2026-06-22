//
//  ThemeApplier.swift
//  ThemeKit
//
//  Created by Ademola on 07/06/2026.
//

import SwiftUI
import ThemeKit
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Applies a `ThemeVariant` to the view hierarchy and keeps it in sync with
/// the active theme and system color scheme.
///
/// Attach via the `applyTheme(_:default:available:)` view modifier:
///
/// ```swift
/// ContentView()
///     .applyTheme(theme, default: AppColorsVariant.default, available: AppColorsVariant.all)
/// ```
@MainActor
public struct ThemeApplier<V: ThemeVariant>: ViewModifier {

  @MainActor private enum AppearanceMode {
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

  /// Creates a `ThemeApplier` that applies interface style overrides to all connected windows.
  public init(theme: Theme, default variant: V, available: [V]) {
    self.theme = theme
    self.defaultVariant = variant
    self.available = available
    #if canImport(UIKit)
    self.applyColorScheme = { colorScheme in
      let windows = UIApplication.shared.connectedScenes
        .compactMap { $0 as? UIWindowScene }
        .flatMap(\.windows)
      if let colorScheme {
        windows.forEach { $0.overrideUserInterfaceStyle = UIUserInterfaceStyle(colorScheme) }
      } else {
        windows.forEach { $0.overrideUserInterfaceStyle = .unspecified }
      }
    }
    #elseif canImport(AppKit)
    self.applyColorScheme = { colorScheme in
      let appearance = colorScheme.map {
        NSAppearance(named: $0 == .dark ? .darkAqua : .aqua)
      } ?? nil
      NSApplication.shared.windows.forEach { $0.appearance = appearance }
    }
    #endif
  }

  /// Creates a `ThemeApplier` with an injected color scheme sink — for testing.
  init(
    theme: Theme,
    default variant: V,
    available: [V],
    applyColorScheme: @escaping (ColorScheme?) -> Void
  ) {
    self.theme = theme
    self.defaultVariant = variant
    self.available = available
    self.applyColorScheme = applyColorScheme
  }

  @Environment(\.colorScheme) var systemColorScheme
  var theme: Theme

  private let defaultVariant: V
  private let available: [V]
  private let applyColorScheme: (ColorScheme?) -> Void

  private var effectiveColorScheme: ColorScheme {
    theme.followsSystem
      ? systemColorScheme
      : ColorScheme(theme.value(V.Value.self).colorScheme) ?? systemColorScheme
  }

  public func body(content: Content) -> some View {
    content
      .colorScheme(effectiveColorScheme)
      .onAppear { handleAppear(systemColorScheme: systemColorScheme) }
      .onChange(of: theme.followsSystem) { _, _ in
        handleThemeChange(systemColorScheme: systemColorScheme)
      }
      .onChange(of: theme.value(V.Value.self)) { _, _ in
        handleThemeChange(systemColorScheme: systemColorScheme)
      }
      .onChange(of: systemColorScheme) { _, new in handleSystemColorSchemeChange(new) }
  }

  func handleAppear(systemColorScheme: ColorScheme) {
    let scheme = SystemColorScheme(systemColorScheme)
    switch AppearanceMode(theme: theme, available: available, default: defaultVariant) {
    case .firstLaunch:
      theme.apply(variant: defaultVariant, for: scheme)
    case .followingSystem(let variant):
      theme.activeVariantID = variant.id
      theme.apply(variant.value(for: scheme))
    case .forced(let value):
      applyColorScheme(ColorScheme(value.colorScheme))
    }
  }

  func handleThemeChange(systemColorScheme: ColorScheme) {
    switch AppearanceMode(theme: theme, available: available, default: defaultVariant) {
    case .followingSystem(let variant):
      applyColorScheme(nil)
      theme.apply(variant.value(for: SystemColorScheme(systemColorScheme)))
    case .forced(let value):
      applyColorScheme(ColorScheme(value.colorScheme))
    case .firstLaunch:
      break
    }
  }

  func handleSystemColorSchemeChange(_ newColorScheme: ColorScheme) {
    guard
      case .followingSystem(let variant) = AppearanceMode(
        theme: theme, available: available, default: defaultVariant)
    else { return }
    theme.activeVariantID = variant.id
    theme.apply(variant.value(for: SystemColorScheme(newColorScheme)))
  }
}

extension View {
  /// Applies a `ThemeVariant` to this view and keeps it in sync with the theme and system appearance.
  @MainActor public func applyTheme<V: ThemeVariant>(
    _ theme: Theme,
    default variant: V,
    available: [V]
  ) -> some View {
    modifier(ThemeApplier(theme: theme, default: variant, available: available))
  }
}
