import SwiftUI
import ThemeKit
import ThemeKitSwiftUI

struct WatchColors: ThemeExtension {
  static let fallback = WatchColors(
    accent: Color(hex: 0x64D2FF),
    background: Color(hex: 0x080B12),
    card: Color(hex: 0x172033),
    colorScheme: .dark
  )

  var accent: Color
  var background: Color
  var card: Color
  var colorScheme: SystemColorScheme
}

extension Theme {
  var watchColors: WatchColors { value(WatchColors.self) }
}
