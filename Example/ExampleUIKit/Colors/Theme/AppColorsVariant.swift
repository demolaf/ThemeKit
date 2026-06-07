import ThemeKit
import UIKit

struct AppColorsVariant: ThemeVariant {
    let id: String
    let name: String
    let light: AppColors
    let dark: AppColors

    static let `default` = AppColorsVariant(
        id: "default",
        name: "Default",
        light: AppColors(tint: UIColor(hex: 0x007AFF), background: UIColor(hex: 0xF2F2F7), container: UIColor(hex: 0xE5E5EA), colorScheme: .light),
        dark:  AppColors(tint: UIColor(hex: 0x0A84FF), background: UIColor(hex: 0x1C1C1E), container: UIColor(hex: 0x2C2C2E), colorScheme: .dark)
    )

    static let ocean = AppColorsVariant(
        id: "ocean",
        name: "Ocean",
        light: AppColors(tint: UIColor(hex: 0x32ADE6), background: UIColor(hex: 0xF0F8FF), container: UIColor(hex: 0xD0ECFF), colorScheme: .light),
        dark:  AppColors(tint: UIColor(hex: 0x64D2FF), background: UIColor(hex: 0x0A1628), container: UIColor(hex: 0x162033), colorScheme: .dark)
    )

    static let rose = AppColorsVariant(
        id: "rose",
        name: "Rose",
        light: AppColors(tint: UIColor(hex: 0xFF2D55), background: UIColor(hex: 0xFFF0F3), container: UIColor(hex: 0xFFD6DE), colorScheme: .light),
        dark:  AppColors(tint: UIColor(hex: 0xFF375F), background: UIColor(hex: 0x1C0A0E), container: UIColor(hex: 0x2A1016), colorScheme: .dark)
    )

    static let all: [AppColorsVariant] = [.default, .ocean, .rose]
}
