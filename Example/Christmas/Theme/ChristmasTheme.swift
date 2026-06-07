import SwiftUI
import ThemeKit
import ThemeKitSwiftUI

struct ChristmasTheme: ThemeExtension {
    var backgroundImageName: String
    var iconImageName: String
    var accentHex: Int
    var fontName: String
    var colorScheme: SystemColorScheme
    var isCustomDefined: Bool = false

    var accent: Color { Color(UIColor(hex: accentHex)) }

    var titleFont: Font {
        fontName.isEmpty
            ? .largeTitle.weight(.bold)
            : .custom(fontName, size: 34, relativeTo: .largeTitle)
    }

    var bodyFont: Font {
        fontName.isEmpty
            ? .body
            : .custom(fontName, size: 17, relativeTo: .body)
    }

    static let defaultValue = ChristmasTheme(
        backgroundImageName: "bg-classic-light",
        iconImageName: "icon-classic",
        accentHex: 0xCC0000,
        fontName: "Georgia",
        colorScheme: .light
    )

    func merging(_ other: ChristmasTheme) -> ChristmasTheme {
        guard isCustomDefined else { return other }
        var merged = other
        merged.accentHex = accentHex
        merged.isCustomDefined = true
        return merged
    }
}

extension Theme {
    var christmas: ChristmasTheme { value(ChristmasTheme.self) }
}
