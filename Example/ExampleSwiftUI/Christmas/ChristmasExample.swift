import SwiftUI
import ThemeKit
import ThemeKitSwiftUI

struct ChristmasExample: View {
  @State private var theme = Theme(suiteName: "com.themekit.example.christmas")

  var body: some View {
    ChristmasContentView()
      .environment(theme)
      .applyTheme(theme, default: .classic, available: ChristmasVariant.all)
  }
}
