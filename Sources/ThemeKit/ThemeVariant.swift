//
//  ThemeVariant.swift
//  ThemeKit
//
//  Created by Ademola on 06/06/2026.
//

/// A light/dark pair of `ThemeExtension` values representing a named theme preset.
public protocol ThemeVariant: Sendable {
  associatedtype Value: ThemeExtension

  /// A stable identifier used to restore the active preset across app launches.
  var id: String { get }

  /// The `ThemeExtension` value to use in a light environment.
  var light: Value { get }

  /// The `ThemeExtension` value to use in a dark environment.
  var dark: Value { get }
}

extension ThemeVariant {
  /// Returns `light` or `dark` based on `scheme`.
  public func value(for scheme: SystemColorScheme) -> Value {
    scheme == .dark ? dark : light
  }
}
