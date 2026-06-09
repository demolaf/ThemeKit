import UIKit
import ThemeKit

struct ChristmasTheme: ThemeExtension {
    var backgroundImageName: String
    var iconImageName: String
    @CodableColor var accent: UIColor
    var fontName: String
    var colorScheme: SystemColorScheme
    var isCustomDefined: Bool = false

    var titleFont: UIFont {
        fontName.isEmpty
            ? .systemFont(ofSize: 34, weight: .bold)
            : UIFont(name: fontName, size: 34) ?? .systemFont(ofSize: 34, weight: .bold)
    }

    var bodyFont: UIFont {
        fontName.isEmpty
            ? .systemFont(ofSize: 17)
            : UIFont(name: fontName, size: 17) ?? .systemFont(ofSize: 17)
    }

    static let defaultValue = ChristmasTheme(
        backgroundImageName: "bg-classic-light",
        iconImageName: "icon-classic",
        accent: UIColor(hex: 0xCC0000),
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
