//
//  SystemColorScheme+ColorScheme.swift
//  ThemeKit
//
//  Created by Ademola on 07/06/2026.
//

import SwiftUI
import ThemeKit

extension SystemColorScheme {
    /// Creates a `SystemColorScheme` from a SwiftUI `ColorScheme`.
    init(_ colorScheme: ColorScheme) {
        switch colorScheme {
        case .light: self = .light
        case .dark: self = .dark
        @unknown default: self = .unspecified
        }
    }
}

extension ColorScheme {
    /// Creates a SwiftUI `ColorScheme` from a `SystemColorScheme`, or `nil` if unspecified.
    init?(_ scheme: SystemColorScheme) {
        switch scheme {
        case .light: self = .light
        case .dark: self = .dark
        case .unspecified: return nil
        }
    }
}

extension UIUserInterfaceStyle {
    /// Creates a `UIUserInterfaceStyle` from a SwiftUI `ColorScheme`.
    init(_ colorScheme: ColorScheme) {
        switch colorScheme {
        case .light: self = .light
        case .dark: self = .dark
        @unknown default: self = .unspecified
        }
    }
}
