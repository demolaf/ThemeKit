import UIKit
import ThemeKit

struct ChristmasTheme: ThemeExtension {
    var backgroundImageName: String
    var iconImageName: String
    var accentHex: Int
    var fontName: String
    var colorScheme: SystemColorScheme
    var isCustomDefined: Bool = false

    var accentColor: UIColor { UIColor(hex: accentHex) }

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
