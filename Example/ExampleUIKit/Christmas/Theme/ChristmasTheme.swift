import ThemeKit
import UIKit

struct ChristmasTheme: ThemeExtension, ThemeOverridable {
  static let fallback = ChristmasTheme(
    backgroundImageName: "bg-classic-light",
    iconImageName: "icon-classic",
    accent: UIColor(hex: 0xCC0000),
    fontName: "Georgia",
    colorScheme: .light
  )
  
  var backgroundImageName: String
  var iconImageName: String
  @CodableColor var accent: UIColor
  var fontName: String
  var colorScheme: SystemColorScheme

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

  var props: [Prop<Self>] {
    [
      .init(\.accent),
      .init(\.backgroundImageName),
      .init(\.iconImageName),
    ]
  }
}

extension Theme {
  var christmas: ChristmasTheme { value(ChristmasTheme.self) }
}
