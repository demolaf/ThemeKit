import SwiftUI
import ThemeKit
import ThemeKitSwiftUI

struct AppColors: ThemeExtension, ThemeOverridable {
  static let fallback = AppColors(
    tint: Color(hex: 0x007AFF),
    background: Color(hex: 0xF2F2F7),
    container: Color(hex: 0xE5E5EA),
    colorScheme: .light
  )

  var tint: Color
  var background: Color
  var container: Color
  var colorScheme: SystemColorScheme

  var props: [Prop<Self>] {
    [.init(\.tint)]
  }
}

extension Theme {
  var colors: AppColors { value(AppColors.self) }
}
