import ThemeKit
import UIKit

struct ChristmasVariant: ThemeVariant {
  let id: String
  let name: String
  let light: ChristmasTheme
  let dark: ChristmasTheme

  static let classic = ChristmasVariant(
    id: "classic",
    name: "Classic",
    light: ChristmasTheme(
      backgroundImageName: "bg-classic-light", iconImageName: "icon-classic",
      accent: UIColor(hex: 0xCC0000), fontName: "Georgia", colorScheme: .light),
    dark: ChristmasTheme(
      backgroundImageName: "bg-classic-dark", iconImageName: "icon-classic",
      accent: UIColor(hex: 0xFF6B6B), fontName: "Georgia", colorScheme: .dark)
  )

  static let winter = ChristmasVariant(
    id: "winter",
    name: "Winter",
    light: ChristmasTheme(
      backgroundImageName: "bg-winter-light", iconImageName: "icon-winter",
      accent: UIColor(hex: 0x1A5276), fontName: "", colorScheme: .light),
    dark: ChristmasTheme(
      backgroundImageName: "bg-winter-dark", iconImageName: "icon-winter",
      accent: UIColor(hex: 0x7FD4F4), fontName: "", colorScheme: .dark)
  )

  static let all: [ChristmasVariant] = [.classic, .winter]

  /// Light/dark pairs of background images available for custom selection.
  /// Add new pairs here as you add assets to Christmas.xcassets.
  static let backgroundPairs: [(light: String, dark: String)] = [
    (light: "bg-classic-light", dark: "bg-classic-dark"),
    (light: "bg-winter-light", dark: "bg-winter-dark"),
    (light: "bg-shiny-light-1", dark: "bg-shiny-light-2"),
    (light: "bg-shiny-dark-1", dark: "bg-shiny-dark-2"),
  ]

  /// Icon image names available for custom selection.
  /// Add new names here as you add assets to Christmas.xcassets.
  static let iconNames: [String] = [
    "icon-classic",
    "icon-winter",
  ]
}
