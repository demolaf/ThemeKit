//
//  ThemeVariant.swift
//  ThemeKit
//
//  Created by Ademola on 06/06/2026.
//

/// A light/dark pair of `ThemeExtension` values representing a named theme preset.
public protocol ThemeVariant: Sendable {
    associatedtype Value: ThemeExtension
    var id: String { get }
    var light: Value { get }
    var dark: Value { get }
}

/// Convenience value resolution for `ThemeVariant`.
public extension ThemeVariant {
    func value(for scheme: SystemColorScheme) -> Value {
        scheme == .dark ? dark : light
    }
}
