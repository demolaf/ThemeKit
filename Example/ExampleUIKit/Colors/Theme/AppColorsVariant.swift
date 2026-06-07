import ThemeKit

struct AppColorsVariant: ThemeVariant {
    let id: String
    let name: String
    let light: AppColors
    let dark: AppColors

    static let `default` = AppColorsVariant(
        id: "default", name: "Default",
        light: AppColors(tintHex: 0x007AFF, backgroundHex: 0xF2F2F7, containerHex: 0xE5E5EA, colorScheme: .light),
        dark:  AppColors(tintHex: 0x0A84FF, backgroundHex: 0x1C1C1E, containerHex: 0x2C2C2E, colorScheme: .dark)
    )

    static let ocean = AppColorsVariant(
        id: "ocean", name: "Ocean",
        light: AppColors(tintHex: 0x32ADE6, backgroundHex: 0xF0F8FF, containerHex: 0xD0ECFF, colorScheme: .light),
        dark:  AppColors(tintHex: 0x64D2FF, backgroundHex: 0x0A1628, containerHex: 0x162033, colorScheme: .dark)
    )

    static let rose = AppColorsVariant(
        id: "rose", name: "Rose",
        light: AppColors(tintHex: 0xFF2D55, backgroundHex: 0xFFF0F3, containerHex: 0xFFD6DE, colorScheme: .light),
        dark:  AppColors(tintHex: 0xFF375F, backgroundHex: 0x1C0A0E, containerHex: 0x2A1016, colorScheme: .dark)
    )

    static let all: [AppColorsVariant] = [.default, .ocean, .rose]
}
