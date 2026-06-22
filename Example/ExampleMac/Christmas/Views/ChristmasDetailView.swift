import SwiftUI
import ThemeKit

struct ChristmasDetailView: View {
  @Environment(Theme.self) private var theme
  @State private var showPicker = false

  private let wishes = ["Joy", "Peace", "Hope", "Love", "Warmth"]

  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        heroCard
        wishesList
      }
      .padding(24)
    }
    .background {
      Image(theme.christmas.backgroundImageName)
        .resizable()
        .scaledToFill()
        .ignoresSafeArea()
    }
    .navigationTitle("Christmas")
    .toolbar {
      ToolbarItem(placement: .primaryAction) {
        Button {
          showPicker = true
        } label: {
          Image(systemName: "paintbrush.pointed")
        }
        .popover(isPresented: $showPicker, arrowEdge: .bottom) {
          ChristmasPickerView()
            .environment(theme)
            .frame(width: 320)
        }
      }
    }
    .onAppear {
      if !theme.hasPersisted(ChristmasTheme.self) {
        theme.apply(variant: ChristmasVariant.classic, for: theme.colors.colorScheme)
      }
    }
  }

  private var heroCard: some View {
    VStack(spacing: 12) {
      Image(theme.christmas.iconImageName)
        .resizable()
        .scaledToFit()
        .frame(width: 80, height: 80)
      Text("Merry Christmas")
        .font(theme.christmas.titleFont)
        .foregroundStyle(theme.christmas.accent)
    }
    .padding(24)
    .frame(maxWidth: .infinity)
    .background(.ultraThinMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 20))
  }

  private var wishesList: some View {
    VStack(spacing: 0) {
      ForEach(wishes, id: \.self) { wish in
        Label {
          Text(wish).font(theme.christmas.bodyFont)
        } icon: {
          Image(theme.christmas.iconImageName)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)

        if wish != wishes.last {
          Divider().padding(.leading, 56)
        }
      }
    }
    .background(.ultraThinMaterial)
    .clipShape(RoundedRectangle(cornerRadius: 16))
  }
}
