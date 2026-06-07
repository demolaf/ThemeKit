import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink { ColorsExample() } label: {
                    Label("Colors", systemImage: "paintbrush.fill")
                }
                NavigationLink { ChristmasExample() } label: {
                    Label("Christmas", systemImage: "snowflake")
                }
            }
            .navigationTitle("ThemeKit")
        }
    }
}
