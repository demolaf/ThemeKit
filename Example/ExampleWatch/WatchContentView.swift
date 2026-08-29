import SwiftUI
import ThemeKit

struct WatchContentView: View {
  @Environment(Theme.self) private var theme

  private var selectedPaletteID: Binding<String> {
    Binding(
      get: { theme.activeVariantID ?? WatchPalette.midnight.id },
      set: { id in
        guard let palette = WatchPalette.all.first(where: { $0.id == id }) else { return }
        theme.apply(variant: palette, for: .dark)
      }
    )
  }

  var body: some View {
    ZStack {
      theme.watchColors.background
        .ignoresSafeArea()

      List {
        Section {
          VStack(alignment: .leading, spacing: 8) {
            Label("ThemeKit", systemImage: "paintpalette.fill")
              .font(.headline)
              .foregroundStyle(theme.watchColors.accent)

            Text("A persisted palette for your watch app.")
              .font(.caption)
              .foregroundStyle(.secondary)

            HStack(spacing: 8) {
              swatch(theme.watchColors.accent)
              swatch(theme.watchColors.card)
              swatch(theme.watchColors.background)
            }
          }
          .listRowBackground(theme.watchColors.card)
        }

        Section("Palette") {
          Picker("Palette", selection: selectedPaletteID) {
            ForEach(WatchPalette.all, id: \.id) { palette in
              Text(palette.name).tag(palette.id)
            }
          }
          .tint(theme.watchColors.accent)
          .listRowBackground(theme.watchColors.card)
        }
      }
      .scrollContentBackground(.hidden)
    }
  }

  private func swatch(_ color: Color) -> some View {
    RoundedRectangle(cornerRadius: 5)
      .fill(color)
      .frame(height: 24)
      .overlay {
        RoundedRectangle(cornerRadius: 5)
          .stroke(.white.opacity(0.2), lineWidth: 1)
      }
  }
}
