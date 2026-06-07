import ThemeKit
import ThemeKitSwiftUI

struct ChristmasVariant: ThemeVariant {
    let id: String
    let name: String
    let light: ChristmasTheme
    let dark: ChristmasTheme

    // Red gift, sunny forest road (light) / dark rainy street (dark)
    static let classic = ChristmasVariant(
        id: "classic",
        name: "Classic",
        light: ChristmasTheme(
            backgroundImageName: "bg-classic-light",
            iconImageName: "icon-classic",
            accentHex: 0xCC0000,
            fontName: "Georgia",
            colorScheme: .light
        ),
        dark: ChristmasTheme(
            backgroundImageName: "bg-classic-dark",
            iconImageName: "icon-classic",
            accentHex: 0xFF6B6B,
            fontName: "Georgia",
            colorScheme: .dark
        )
    )

    // Blue gift, bright snowy forest (light) / snowy night street (dark)
    static let winter = ChristmasVariant(
        id: "winter",
        name: "Winter",
        light: ChristmasTheme(
            backgroundImageName: "bg-winter-light",
            iconImageName: "icon-winter",
            accentHex: 0x1A5276,
            fontName: "",
            colorScheme: .light
        ),
        dark: ChristmasTheme(
            backgroundImageName: "bg-winter-dark",
            iconImageName: "icon-winter",
            accentHex: 0x7FD4F4,
            fontName: "",
            colorScheme: .dark
        )
    )

    static let all: [ChristmasVariant] = [.classic, .winter]
}
