import SwiftUI
import ThemeKit

struct ContentView: View {
  @Environment(Theme.self) private var theme
  @State private var selection: SidebarItem? = .colors

  var body: some View {
    NavigationSplitView {
      SidebarView(selection: $selection)
    } detail: {
      switch selection {
      case .colors:
        ColorsDetailView()
      case .christmas:
        ChristmasDetailView()
      case nil:
        Text("Select an example")
          .foregroundStyle(.secondary)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
  }
}
