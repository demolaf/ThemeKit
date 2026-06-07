import SwiftUI
import ThemeKit
import ThemeKitSwiftUI

struct AppColors: ThemeExtension {
    var tintHex: Int
    var backgroundHex: Int
    var containerHex: Int
    var colorScheme: SystemColorScheme
    var isCustomDefined: Bool = false

    var tint: Color { Color(UIColor(hex: tintHex)) }
    var background: Color { Color(UIColor(hex: backgroundHex)) }
    var container: Color { Color(UIColor(hex: containerHex)) }

    static let defaultValue = AppColors(
        tintHex: 0x007AFF,
        backgroundHex: 0xF2F2F7,
        containerHex: 0xE5E5EA,
        colorScheme: .light
    )

    func merging(_ other: AppColors) -> AppColors {
        guard isCustomDefined else { return other }
        var merged = other
        merged.tintHex = tintHex
        merged.isCustomDefined = true
        return merged
    }
}

extension Theme {
    var colors: AppColors { value(AppColors.self) }
}
