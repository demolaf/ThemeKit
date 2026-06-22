import SwiftUI
import ThemeKit

struct SettingsView: View {
  var body: some View {
    TabView {
      AppearanceSettingsTab()
        .tabItem { Label("Appearance", systemImage: "paintbrush") }
      PaletteSettingsTab()
        .tabItem { Label("Palette", systemImage: "swatchpalette") }
    }
    .frame(width: 380)
    .padding()
  }
}

struct AppearanceSettingsTab: View {
  @Environment(Theme.self) private var theme

  var body: some View {
    Form {
      Toggle("Follow System Appearance", isOn: Bindable(theme).followsSystem)

      if !theme.followsSystem {
        Picker("Color Scheme", selection: schemeBinding) {
          Text("Light").tag(SystemColorScheme.light)
          Text("Dark").tag(SystemColorScheme.dark)
        }
        .pickerStyle(.radioGroup)
      }
    }
    .formStyle(.grouped)
    .frame(height: 160)
  }

  private var schemeBinding: Binding<SystemColorScheme> {
    Binding(
      get: { theme.colors.colorScheme },
      set: { scheme in
        let variant = AppColorsVariant.all.first { $0.id == theme.activeVariantID } ?? .default
        theme.apply(variant: variant, for: scheme)
      }
    )
  }
}

struct PaletteSettingsTab: View {
  @Environment(Theme.self) private var theme

  var body: some View {
    Form {
      Section("Color Palette") {
        ForEach(AppColorsVariant.all, id: \.id) { variant in
          HStack {
            Circle()
              .fill(variant.light.tint)
              .frame(width: 18, height: 18)
            Text(variant.name)
            Spacer()
            if theme.activeVariantID == variant.id {
              Image(systemName: "checkmark")
                .foregroundStyle(theme.colors.tint)
                .fontWeight(.semibold)
            }
          }
          .contentShape(Rectangle())
          .onTapGesture {
            theme.apply(variant: variant, for: theme.colors.colorScheme)
          }
        }
      }
    }
    .formStyle(.grouped)
    .frame(height: 180)
  }
}
