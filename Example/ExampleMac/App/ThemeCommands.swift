import SwiftUI
import ThemeKit

struct ThemeCommands: Commands {
  var theme: Theme

  var body: some Commands {
    CommandMenu("Theme") {
      Toggle("Follow System", isOn: Bindable(theme).followsSystem)
        .keyboardShortcut("s", modifiers: [.command, .option])

      Divider()

      Button("Light") {
        theme.followsSystem = false
        theme.apply(variant: activeVariant, for: .light)
      }
      .disabled(theme.followsSystem)

      Button("Dark") {
        theme.followsSystem = false
        theme.apply(variant: activeVariant, for: .dark)
      }
      .disabled(theme.followsSystem)

      Divider()

      ForEach(AppColorsVariant.all, id: \.id) { variant in
        Button(variant.name) {
          theme.apply(variant: variant, for: theme.colors.colorScheme)
        }
      }
    }
  }

  private var activeVariant: AppColorsVariant {
    AppColorsVariant.all.first { $0.id == theme.activeVariantID } ?? .default
  }
}
