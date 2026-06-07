import SwiftUI
import ThemeKit
import ThemeKitSwiftUI

struct ThemePickerView: View {
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
                    ForEach(AppColorsVariant.all, id: \.id) { variant in
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
                        .foregroundStyle(theme.colors.tint)
                }
            }
        }
    }

    @ViewBuilder
    private func variantRow(for variant: AppColorsVariant) -> some View {
        HStack(spacing: 12) {
            swatches(for: variant)
            Text(variant.name)
                .foregroundStyle(.primary)
            Spacer()
            if theme.activeVariantID == variant.id {
                Image(systemName: "checkmark")
                    .foregroundStyle(theme.colors.tint)
                    .fontWeight(.semibold)
            }
        }
    }

    @ViewBuilder
    private func swatches(for variant: AppColorsVariant) -> some View {
        HStack(spacing: -8) {
            Circle()
                .fill(variant.light.tint)
                .frame(width: 28, height: 28)
                .overlay(Circle().stroke(.white, lineWidth: 2))
            Circle()
                .fill(variant.dark.tint)
                .frame(width: 28, height: 28)
                .overlay(Circle().stroke(.white, lineWidth: 2))
        }
    }
}
