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
        theme.merge(custom)
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
            variantRow(for: variant)
          }
        }
        Section("Custom") {
          ColorPicker("Tint Color", selection: tintBinding)
          let activeVariant =
            AppColorsVariant.all.first { $0.id == theme.activeVariantID } ?? .default
          let preset = activeVariant.value(for: theme.colors.colorScheme)
          if theme.colors.compare(to: preset) {
            Button("Reset to Preset", role: .destructive) {
              theme.apply(variant: activeVariant, for: theme.colors.colorScheme)
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
      Text(variant.name)
        .foregroundStyle(.primary)
      Spacer()
      HStack(spacing: 16) {
        schemeButton(variant: variant, scheme: .light)
        schemeButton(variant: variant, scheme: .dark)
      }
    }
  }

  @ViewBuilder
  private func schemeButton(variant: AppColorsVariant, scheme: SystemColorScheme) -> some View {
    let colors = variant.value(for: scheme)
    let isActive =
      !theme.followsSystem && theme.activeVariantID == variant.id
      && theme.colors.colorScheme == scheme
    Button {
      theme.apply(variant: variant, for: scheme)
    } label: {
      Circle()
        .fill(colors.tint)
        .frame(width: 28, height: 28)
        .overlay(
          Circle().stroke(
            isActive ? theme.colors.tint : (scheme == .light ? .white : .black),
            lineWidth: isActive ? 3 : 1.5
          )
          .padding(-3)
        )
        .overlay(
          isActive
            ? Image(systemName: "checkmark")
              .font(.system(size: 11, weight: .bold))
              .foregroundStyle(.white)
            : nil
        )
    }
    .buttonStyle(.plain)
  }
}
