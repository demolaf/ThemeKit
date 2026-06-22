import SwiftUI
import ThemeKit

struct ColorsDetailView: View {
  @Environment(Theme.self) private var theme
  @State private var showPicker = false

  private let items = [
    ("Inbox", "tray"),
    ("Calendar", "calendar"),
    ("Photos", "photo.on.rectangle"),
    ("Notes", "note.text"),
    ("Reminders", "checklist"),
    ("Messages", "message"),
  ]

  var body: some View {
    List {
      Section("Active Palette") {
        HStack(spacing: 12) {
          swatch(theme.colors.tint, label: "Tint")
          swatch(theme.colors.background, label: "Background")
          swatch(theme.colors.container, label: "Container")
        }
        .padding(.vertical, 4)
      }
      Section("Preview") {
        ForEach(items, id: \.0) { name, icon in
          Label(name, systemImage: icon)
            .foregroundStyle(theme.colors.tint)
        }
      }
    }
    .navigationTitle("Colors")
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button {
          showPicker = true
        } label: {
          Image(systemName: "paintbrush.pointed")
        }
        .popover(isPresented: $showPicker, arrowEdge: .bottom) {
          ColorsPickerView()
            .environment(theme)
            .frame(width: 300)
        }
      }
    }
  }

  private func swatch(_ color: Color, label: String) -> some View {
    VStack(spacing: 6) {
      RoundedRectangle(cornerRadius: 8)
        .fill(color)
        .frame(height: 48)
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(nsColor: .separatorColor), lineWidth: 0.5))
      Text(label)
        .font(.caption2)
        .foregroundStyle(.secondary)
    }
  }
}
