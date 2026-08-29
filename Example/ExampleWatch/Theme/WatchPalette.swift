import SwiftUI
import ThemeKit
import ThemeKitSwiftUI

struct WatchPalette: ThemeVariant {
  let id: String
  let name: String
  let light: WatchColors
  let dark: WatchColors

  static let midnight = make(
    id: "midnight",
    name: "Midnight",
    accent: 0x64D2FF,
    background: 0x080B12,
    card: 0x172033
  )

  static let berry = make(
    id: "berry",
    name: "Berry",
    accent: 0xFF6482,
    background: 0x19080F,
    card: 0x32121E
  )

  static let forest = make(
    id: "forest",
    name: "Forest",
    accent: 0x30D158,
    background: 0x07130B,
    card: 0x102A19
  )

  static let all: [WatchPalette] = [.midnight, .berry, .forest]

  private static func make(
    id: String,
    name: String,
    accent: Int,
    background: Int,
    card: Int
  ) -> WatchPalette {
    let colors = WatchColors(
      accent: Color(hex: accent),
      background: Color(hex: background),
      card: Color(hex: card),
      colorScheme: .dark
    )
    return WatchPalette(id: id, name: name, light: colors, dark: colors)
  }
}
