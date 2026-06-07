import SwiftUI
import ThemeKit

struct ContentView: View {
    @Environment(Theme.self) private var theme
    @State private var showPicker = false

    private let items = [
        ("Inbox",      "tray"),
        ("Calendar",   "calendar"),
        ("Photos",     "photo.on.rectangle"),
        ("Notes",      "note.text"),
        ("Reminders",  "checklist"),
        ("Messages",   "message"),
    ]

    var body: some View {
        NavigationStack {
            List {
                Section("Active Theme") {
                    SwatchView()
                }
                Section("Preview") {
                    ForEach(items, id: \.0) { name, icon in
                        Label(name, systemImage: icon)
                            .foregroundStyle(theme.colors.tint)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(theme.colors.background)
            .navigationTitle("ThemeKit")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showPicker = true
                    } label: {
                        Image(systemName: "paintbrush.pointed")
                            .foregroundStyle(theme.colors.tint)
                    }
                }
            }
        }
        .sheet(isPresented: $showPicker) {
            ThemePickerView()
        }
    }
}
