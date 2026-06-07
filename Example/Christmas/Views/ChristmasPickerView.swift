import SwiftUI
import ThemeKit
import ThemeKitSwiftUI

struct ChristmasPickerView: View {
    @Environment(Theme.self) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("Follow System Appearance", isOn: Bindable(theme).followsSystem)
                }
                Section("Presets") {
                    ForEach(ChristmasVariant.all, id: \.id) { variant in
                        Button {
                            theme.apply(variant: variant, for: SystemColorScheme(colorScheme))
                            theme.followsSystem = false
                        } label: {
                            variantRow(for: variant)
                        }
                        .tint(.primary)
                    }
                }
            }
            .navigationTitle("Appearance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(theme.christmas.accent)
                }
            }
        }
    }

    @ViewBuilder
    private func variantRow(for variant: ChristmasVariant) -> some View {
        HStack(spacing: 12) {
            backgroundThumbnails(for: variant)
            Text(variant.name)
                .foregroundStyle(.primary)
            Spacer()
            if theme.activeVariantID == variant.id {
                Image(systemName: "checkmark")
                    .foregroundStyle(theme.christmas.accent)
                    .fontWeight(.semibold)
            }
        }
    }

    @ViewBuilder
    private func backgroundThumbnails(for variant: ChristmasVariant) -> some View {
        HStack(spacing: -8) {
            thumbnail(imageName: variant.light.backgroundImageName)
            thumbnail(imageName: variant.dark.backgroundImageName)
        }
    }

    @ViewBuilder
    private func thumbnail(imageName: String) -> some View {
        Group {
            if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Color(.secondarySystemFill)
            }
        }
        .frame(width: 28, height: 28)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(.white, lineWidth: 2))
    }
}
