import SwiftUI
import ThemeKit
import ThemeKitSwiftUI

struct ChristmasPickerView: View {
  @Environment(Theme.self) private var theme
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.dismiss) private var dismiss

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
    NavigationStack {
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
            HStack(spacing: 12) {
              ForEach(ChristmasVariant.backgroundPairs, id: \.light) { pair in
                backgroundPickerThumbnail(pair: pair)
              }
            }
            .padding(.vertical, 8)
            .padding(.leading, 4)
          }
          .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
        Section("Icon") {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
              ForEach(ChristmasVariant.iconNames, id: \.self) { name in
                iconPickerThumbnail(name: name)
              }
            }
            .padding(.vertical, 8)
            .padding(.leading, 4)
          }
          .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
        Section("Accent") {
          ColorPicker("Accent Color", selection: accentBinding)
          let activeVariant =
            ChristmasVariant.all.first { $0.id == theme.activeVariantID } ?? .classic
          let preset = activeVariant.value(for: theme.christmas.colorScheme)
          if theme.christmas.compare(to: preset) {
            Button("Reset to Preset", role: .destructive) {
              theme.apply(variant: activeVariant, for: theme.christmas.colorScheme)
            }
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
  private func backgroundPickerThumbnail(pair: (light: String, dark: String)) -> some View {
    let imageName = colorScheme == .dark ? pair.dark : pair.light
    let isSelected =
      theme.christmas.backgroundImageName == pair.light
      || theme.christmas.backgroundImageName == pair.dark
    Button {
      var custom = theme.christmas
      custom.backgroundImageName = imageName
      theme.merge(custom)
    } label: {
      Group {
        if let uiImage = UIImage(named: imageName) {
          Image(uiImage: uiImage)
            .resizable()
            .scaledToFill()
        } else {
          Color(.secondarySystemFill)
        }
      }
      .frame(width: 88, height: 60)
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .stroke(isSelected ? theme.christmas.accent : Color.clear, lineWidth: 3)
      )
    }
    .buttonStyle(.plain)
  }

  @ViewBuilder
  private func iconPickerThumbnail(name: String) -> some View {
    let isSelected = theme.christmas.iconImageName == name
    Button {
      var custom = theme.christmas
      custom.iconImageName = name
      theme.merge(custom)
    } label: {
      Group {
        if let uiImage = UIImage(named: name) {
          Image(uiImage: uiImage)
            .resizable()
            .scaledToFit()
        } else {
          Color(.secondarySystemFill)
        }
      }
      .frame(width: 44, height: 44)
      .padding(8)
      .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemGroupedBackground)))
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(isSelected ? theme.christmas.accent : Color.clear, lineWidth: 3)
      )
    }
    .buttonStyle(.plain)
  }

  @ViewBuilder
  private func variantRow(for variant: ChristmasVariant) -> some View {
    HStack(spacing: 12) {
      backgroundThumbnails(for: variant)
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
  private func schemeButton(variant: ChristmasVariant, scheme: SystemColorScheme) -> some View {
    let value = variant.value(for: scheme)
    let isActive =
      !theme.followsSystem && theme.activeVariantID == variant.id
      && theme.christmas.colorScheme == scheme
    Button {
      theme.apply(variant: variant, for: scheme)
    } label: {
      Image(systemName: scheme == .light ? "sun.max.fill" : "moon.fill")
        .font(.system(size: 13, weight: .semibold))
        .foregroundStyle(isActive ? value.accent : .primary)
        .frame(width: 28, height: 28)
        .background(Circle().fill(Color(.secondarySystemFill)))
        .overlay(
          Circle().stroke(
            isActive ? value.accent : (scheme == .light ? .white : .black),
            lineWidth: isActive ? 3 : 1.5
          )
          .padding(-3)
        )
    }
    .buttonStyle(.plain)
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
