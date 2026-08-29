import SwiftUI
import ThemeKit
import ThemeKitSwiftUI

@main
struct ExampleWatchApp: App {
  @State private var theme = Theme(suiteName: "com.themekit.example.watch")

  var body: some Scene {
    WindowGroup {
      WatchContentView()
        .environment(theme)
        .applyTheme(theme, default: .midnight, available: WatchPalette.all)
    }
  }
}
