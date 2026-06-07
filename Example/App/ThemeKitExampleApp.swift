import SwiftUI
import ThemeKit
import ThemeKitSwiftUI

@main
struct ExampleApp: App {
    @State private var theme = Theme()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(theme)
                .applyTheme(theme, default: .default, available: AppColorsVariant.all)
        }
    }
}
