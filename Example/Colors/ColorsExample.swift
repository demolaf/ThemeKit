import SwiftUI
import ThemeKit
import ThemeKitSwiftUI

struct ColorsExample: View {
    @State private var theme = Theme()

    var body: some View {
        ColorsContentView()
            .environment(theme)
            .applyTheme(theme, default: .default, available: AppColorsVariant.all)
    }
}
