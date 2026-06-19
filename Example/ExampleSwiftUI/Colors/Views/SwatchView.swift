import SwiftUI
import ThemeKit

struct SwatchView: View {
  @Environment(Theme.self) private var theme

  var body: some View {
    HStack(spacing: 12) {
      swatch("Tint", theme.colors.tint)
      swatch("Background", theme.colors.background)
      swatch("Container", theme.colors.container)
    }
    .padding(.vertical, 4)
  }

  private func swatch(_ label: String, _ color: Color) -> some View {
    VStack(spacing: 6) {
      RoundedRectangle(cornerRadius: 8)
        .fill(color)
        .frame(height: 48)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color(.separator), lineWidth: 0.5)
        )
      Text(label)
        .font(.caption2)
        .foregroundStyle(.secondary)
    }
  }
}
