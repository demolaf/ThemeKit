import SwiftUI
import ThemeKit
import ThemeKitSwiftUI

struct ChristmasTheme: ThemeExtension, ThemeOverridable {
  var backgroundImageName: String
  var iconImageName: String
  var accent: Color
  var fontName: String
  var colorScheme: SystemColorScheme

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

  static let fallback = ChristmasTheme(
    backgroundImageName: "bg-classic-light",
    iconImageName: "icon-classic",
    accent: Color(hex: 0xCC0000),
    fontName: "Georgia",
    colorScheme: .light
  )

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
