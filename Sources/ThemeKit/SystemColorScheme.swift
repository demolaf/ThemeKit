//
//  SystemColorScheme.swift
//  ThemeKit
//
//  Created by Ademola on 07/06/2026.
//

import UIKit

/// A `Codable` representation of the system light/dark color scheme.
///
/// Use this instead of `UIUserInterfaceStyle` in `ThemeExtension` conformances
/// so that `Codable` synthesis works without manual implementation.
public enum SystemColorScheme: Int, Codable, Sendable {
  case unspecified = 0
  case light = 1
  case dark = 2

  /// The corresponding `UIUserInterfaceStyle` for this scheme.
  public var uiUserInterfaceStyle: UIUserInterfaceStyle {
    UIUserInterfaceStyle(rawValue: rawValue) ?? .unspecified
  }

  /// Creates a `SystemColorScheme` from a `UIUserInterfaceStyle`.
  public init(_ style: UIUserInterfaceStyle) {
    self = SystemColorScheme(rawValue: style.rawValue) ?? .unspecified
  }
}
