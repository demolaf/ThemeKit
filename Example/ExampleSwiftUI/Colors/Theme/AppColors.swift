import SwiftUI
import ThemeKit
import ThemeKitSwiftUI

struct AppColors: ThemeExtension {
    var tint: Color
    var background: Color
    var container: Color
    var colorScheme: SystemColorScheme
    var isCustomDefined: Bool = false

    static let defaultValue = AppColors(
        tint: Color(hex: 0x007AFF),
        background: Color(hex: 0xF2F2F7),
        container: Color(hex: 0xE5E5EA),
        colorScheme: .light
    )

    func merging(_ other: AppColors) -> AppColors {
        guard isCustomDefined else { return other }
        var merged = other
        merged.tint = tint
        merged.isCustomDefined = true
        return merged
    }
}

extension Theme {
    var colors: AppColors { value(AppColors.self) }
}
