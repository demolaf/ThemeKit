import UIKit
import ThemeKit

struct AppColors: ThemeExtension {
    @CodableColor var tint: UIColor
    @CodableColor var background: UIColor
    @CodableColor var container: UIColor
    var colorScheme: SystemColorScheme
    var isCustomDefined: Bool = false

    static let defaultValue = AppColors(
        tint: UIColor(hex: 0x007AFF),
        background: UIColor(hex: 0xF2F2F7),
        container: UIColor(hex: 0xE5E5EA),
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
