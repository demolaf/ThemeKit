import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ExampleCard(
                        title: "Colors",
                        description: "Switch between light and dark color variants, or follow the system appearance.",
                        gradient: [Color(hex: 0x007AFF), Color(hex: 0x0A84FF)]
                    ) {
                        ColorsExample()
                    }

                    ExampleCard(
                        title: "Christmas",
                        description: "Background gradients, icons, and fonts that all respond to your theme.",
                        gradient: [Color(hex: 0xCC0000), Color(hex: 0x1A5C1A)]
                    ) {
                        ChristmasExample()
                    }
                }
                .padding()
            }
            .navigationTitle("ThemeKit")
        }
    }
}
