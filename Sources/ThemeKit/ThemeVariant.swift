//
//  ThemeVariant.swift
//  ThemeKit
//
//  Created by Ademola on 06/06/2026.
//

import UIKit

/// A light/dark pair of `ThemeExtension` values representing a named theme preset.
public protocol ThemeVariant {
    associatedtype Value: ThemeExtension
    var id: String { get }
    var light: Value { get }
    var dark: Value { get }
}

/// Convenience value resolution for `ThemeVariant`.
public extension ThemeVariant {
    func value(for style: UIUserInterfaceStyle) -> Value {
        style == .dark ? dark : light
    }
}
