//
//  ThemeKitSwiftUIExample.swift
//  ThemeKit
//
//  A compilable end-to-end example showing how to integrate ThemeKitSwiftUI
//  into a SwiftUI app. Copy and adapt these types into your own app target.
//

import SwiftUI
import ThemeKitSwiftUI

// MARK: - 1. Define your ThemeExtension

struct AppColors: ThemeExtension {
    var tintHex: Int
    var backgroundHex: Int
    var colorScheme: SystemColorScheme
    var isCustomDefined: Bool = false

    static let defaultValue = AppColors(
        tintHex: 0x007AFF,
        backgroundHex: 0xF2F2F7,
        colorScheme: .light
    )

    func merging(_ other: AppColors) -> AppColors {
        guard isCustomDefined else { return other }
        var result = other
        result.tintHex = tintHex
        result.isCustomDefined = true
        return result
    }
}

// MARK: - 2. Register a named property on Theme

extension Theme {
    var colors: AppColors {
        get { self[AppColors.self] }
        set { self[AppColors.self] = newValue }
    }
}

// MARK: - 3. Define your ThemeVariant

struct AppColorsVariant: ThemeVariant {
    let id: String
    let light: AppColors
    let dark: AppColors

    static let `default` = AppColorsVariant(
        id: "default",
        light: AppColors(tintHex: 0x007AFF, backgroundHex: 0xF2F2F7, colorScheme: .light),
        dark:  AppColors(tintHex: 0x0A84FF, backgroundHex: 0x1C1C1E, colorScheme: .dark)
    )

    static let ocean = AppColorsVariant(
        id: "ocean",
        light: AppColors(tintHex: 0x32ADE6, backgroundHex: 0xF0F8FF, colorScheme: .light),
        dark:  AppColors(tintHex: 0x64D2FF, backgroundHex: 0x0A1628, colorScheme: .dark)
    )

    static let all: [AppColorsVariant] = [.default, .ocean]
}

// MARK: - 4. Set up the Theme and attach the applier

struct ExampleApp: View {
    @State private var theme = Theme()

    var body: some View {
        ExampleContentView()
            .environment(theme)
            .applyTheme(theme, default: .default, available: AppColorsVariant.all)
    }
}

// MARK: - 5. Read theme values anywhere via the environment

struct ExampleContentView: View {
    @Environment(Theme.self) private var theme

    var body: some View {
        NavigationStack {
            List {
                Section("Appearance") {
                    Toggle("Follow system", isOn: Bindable(theme).followsSystem)

                    ForEach(AppColorsVariant.all, id: \.id) { variant in
                        Button(variant.id.capitalized) {
                            theme.apply(variant: variant, for: SystemColorScheme(from: theme))
                        }
                    }
                }
            }
            .navigationTitle("Theme")
            .foregroundStyle(Color(UIColor(hex: theme.colors.tintHex)))
        }
    }
}

// MARK: - Convenience

private extension SystemColorScheme {
    /// Resolves the current active scheme from the theme — light if unspecified.
    init(from theme: Theme) {
        self = theme.colors.colorScheme == .unspecified ? .light : theme.colors.colorScheme
    }
}
