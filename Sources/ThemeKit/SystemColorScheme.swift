//
//  SystemColorScheme.swift
//  ThemeKit
//
//  Created by Ademola on 07/06/2026.
//

#if canImport(UIKit)
import UIKit
#endif

/// A `Codable` representation of the system light/dark color scheme.
///
/// Use this instead of `UIUserInterfaceStyle` in `ThemeExtension` conformances
/// so that `Codable` synthesis works without manual implementation.
public enum SystemColorScheme: Int, Codable, Sendable {
  /// No preference — the system or parent environment decides.
  case unspecified = 0
  /// Light appearance.
  case light = 1
  /// Dark appearance.
  case dark = 2

#if canImport(UIKit)
  /// The corresponding `UIUserInterfaceStyle` for this scheme.
  public var uiUserInterfaceStyle: UIUserInterfaceStyle {
    UIUserInterfaceStyle(rawValue: rawValue) ?? .unspecified
  }

  /// Creates a `SystemColorScheme` from a `UIUserInterfaceStyle`.
  public init(_ style: UIUserInterfaceStyle) {
    self = SystemColorScheme(rawValue: style.rawValue) ?? .unspecified
  }
#endif
}
