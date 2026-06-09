import SwiftUI
import ThemeKit
import ThemeKitSwiftUI

struct ChristmasTheme: ThemeExtension {
    var backgroundImageName: String
    var iconImageName: String
    var accent: Color
    var fontName: String
    var colorScheme: SystemColorScheme
    var isCustomDefined: Bool = false

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
        accent: Color(hex: 0xCC0000),
        fontName: "Georgia",
        colorScheme: .light
    )

    func merging(_ other: ChristmasTheme) -> ChristmasTheme {
        guard isCustomDefined else { return other }
        var merged = other
        merged.accent = accent
        merged.backgroundImageName = backgroundImageName
        merged.iconImageName = iconImageName
        merged.isCustomDefined = true
        return merged
    }
}

extension Theme {
    var christmas: ChristmasTheme { value(ChristmasTheme.self) }
}
