import SwiftUI
import ThemeKit
import ThemeKitSwiftUI

struct ColorsPickerView: View {
    @Environment(Theme.self) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    private var tintBinding: Binding<Color> {
        Binding(
            get: { theme.colors.tint },
            set: { newColor in
                var custom = theme.colors
                custom.tint = newColor
                custom.isCustomDefined = true
                theme.apply(custom)
            }
        )
    }

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
                Section("Custom") {
                    ColorPicker("Tint Color", selection: tintBinding)
                    if theme.colors.isCustomDefined {
                        Button("Reset to Preset", role: .destructive) {
                            let variant = AppColorsVariant.all.first { $0.id == theme.activeVariantID } ?? .default
                            theme.apply(variant: variant, for: SystemColorScheme(colorScheme))
                        }
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
}
