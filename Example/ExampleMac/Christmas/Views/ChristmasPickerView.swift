import SwiftUI
import ThemeKit
import ThemeKitSwiftUI

struct ChristmasPickerView: View {
  @Environment(Theme.self) private var theme
  @Environment(\.colorScheme) private var colorScheme

  private var accentBinding: Binding<Color> {
    Binding(
      get: { theme.christmas.accent },
      set: { newColor in
        var custom = theme.christmas
        custom.accent = newColor
        theme.merge(custom)
      }
    )
  }

  var body: some View {
    Form {
      Section {
        Toggle("Follow System Appearance", isOn: Bindable(theme).followsSystem)
      }
      Section("Presets") {
        ForEach(ChristmasVariant.all, id: \.id) { variant in
          variantRow(for: variant)
        }
      }
      Section("Background") {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 10) {
            ForEach(ChristmasVariant.backgroundPairs, id: \.light) { pair in
              backgroundThumbnail(pair: pair)
            }
          }
          .padding(.vertical, 6)
        }
      }
      Section("Icon") {
        HStack(spacing: 10) {
          ForEach(ChristmasVariant.iconNames, id: \.self) { name in
            iconThumbnail(name: name)
          }
        }
        .padding(.vertical, 4)
      }
      Section("Accent") {
        ColorPicker("Accent Color", selection: accentBinding)
        let activeVariant = ChristmasVariant.all.first { $0.id == theme.activeVariantID } ?? .classic
        let preset = activeVariant.value(for: theme.christmas.colorScheme)
        if theme.christmas.compare(to: preset) {
          Button("Reset to Preset", role: .destructive) {
            theme.apply(variant: activeVariant, for: theme.christmas.colorScheme)
          }
        }
      }
    }
    .formStyle(.grouped)
    .padding(.vertical, 8)
  }

  @ViewBuilder
  private func variantRow(for variant: ChristmasVariant) -> some View {
    HStack(spacing: 12) {
      HStack(spacing: -6) {
        thumbnail(variant.light.backgroundImageName)
        thumbnail(variant.dark.backgroundImageName)
      }
      Text(variant.name)
      Spacer()
      HStack(spacing: 12) {
        schemeButton(variant: variant, scheme: .light)
        schemeButton(variant: variant, scheme: .dark)
      }
    }
  }

  @ViewBuilder
  private func schemeButton(variant: ChristmasVariant, scheme: SystemColorScheme) -> some View {
    let value = variant.value(for: scheme)
    let isActive = !theme.followsSystem
      && theme.activeVariantID == variant.id
      && theme.christmas.colorScheme == scheme
    Button {
      theme.apply(variant: variant, for: scheme)
    } label: {
      Image(systemName: scheme == .light ? "sun.max.fill" : "moon.fill")
        .font(.system(size: 12, weight: .semibold))
        .foregroundStyle(isActive ? value.accent : .primary)
        .frame(width: 26, height: 26)
        .background(Circle().fill(Color(nsColor: .quaternarySystemFill)))
        .overlay(Circle().stroke(isActive ? value.accent : Color.clear, lineWidth: 2).padding(-3))
    }
    .buttonStyle(.plain)
  }

  @ViewBuilder
  private func backgroundThumbnail(pair: (light: String, dark: String)) -> some View {
    let name = colorScheme == .dark ? pair.dark : pair.light
    let isSelected = theme.christmas.backgroundImageName == pair.light
      || theme.christmas.backgroundImageName == pair.dark
    Button {
      var custom = theme.christmas
      custom.backgroundImageName = name
      theme.merge(custom)
    } label: {
      Image(name)
        .resizable()
        .scaledToFill()
        .frame(width: 80, height: 56)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(isSelected ? theme.christmas.accent : Color.clear, lineWidth: 3))
    }
    .buttonStyle(.plain)
  }

  @ViewBuilder
  private func iconThumbnail(name: String) -> some View {
    let isSelected = theme.christmas.iconImageName == name
    Button {
      var custom = theme.christmas
      custom.iconImageName = name
      theme.merge(custom)
    } label: {
      Image(name)
        .resizable()
        .scaledToFit()
        .frame(width: 40, height: 40)
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 10).fill(Color(nsColor: .quaternarySystemFill)))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(isSelected ? theme.christmas.accent : Color.clear, lineWidth: 3))
    }
    .buttonStyle(.plain)
  }

  private func thumbnail(_ imageName: String) -> some View {
    Image(imageName)
      .resizable()
      .scaledToFill()
      .frame(width: 26, height: 26)
      .clipShape(RoundedRectangle(cornerRadius: 5))
      .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color(nsColor: .windowBackgroundColor), lineWidth: 2))
  }
}
