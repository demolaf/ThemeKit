import SwiftUI
import ThemeKit
import ThemeKitSwiftUI

@main
struct ExampleMacApp: App {
  @State private var theme = Theme()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(theme)
        .frame(minWidth: 720, minHeight: 480)
    }
    .commands {
      ThemeCommands(theme: theme)
    }

    Settings {
      SettingsView()
        .environment(theme)
    }
  }
}
