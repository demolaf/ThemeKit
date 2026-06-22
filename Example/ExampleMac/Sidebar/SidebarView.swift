import SwiftUI

enum SidebarItem: String, CaseIterable, Identifiable {
  case colors = "Colors"
  case christmas = "Christmas"

  var id: String { rawValue }

  var icon: String {
    switch self {
    case .colors: "paintpalette"
    case .christmas: "snowflake"
    }
  }
}

struct SidebarView: View {
  @Binding var selection: SidebarItem?

  var body: some View {
    List(SidebarItem.allCases, selection: $selection) { item in
      Label(item.rawValue, systemImage: item.icon)
        .tag(item)
    }
    .listStyle(.sidebar)
    .navigationTitle("ThemeKit")
  }
}
