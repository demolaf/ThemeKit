import ThemeKit
import SwiftUI
import ThemeKitSwiftUI

struct ChristmasVariant: ThemeVariant {
    let id: String
    let name: String
    let light: ChristmasTheme
    let dark: ChristmasTheme

    static let classic = ChristmasVariant(
        id: "classic",
        name: "Classic",
        light: ChristmasTheme(backgroundImageName: "bg-classic-light", iconImageName: "icon-classic", accent: Color(hex: 0xCC0000), fontName: "Georgia", colorScheme: .light),
        dark:  ChristmasTheme(backgroundImageName: "bg-classic-dark",  iconImageName: "icon-classic", accent: Color(hex: 0xFF6B6B), fontName: "Georgia", colorScheme: .dark)
    )

    static let winter = ChristmasVariant(
        id: "winter",
        name: "Winter",
        light: ChristmasTheme(backgroundImageName: "bg-winter-light", iconImageName: "icon-winter", accent: Color(hex: 0x1A5276), fontName: "", colorScheme: .light),
        dark:  ChristmasTheme(backgroundImageName: "bg-winter-dark",  iconImageName: "icon-winter", accent: Color(hex: 0x7FD4F4), fontName: "", colorScheme: .dark)
    )

    static let all: [ChristmasVariant] = [.classic, .winter]
}
