import SwiftUI
import ThemeKit

struct ChristmasContentView: View {
  @Environment(Theme.self) private var theme
  @State private var showPicker = false

  private let wishes = ["Joy", "Peace", "Hope", "Love", "Warmth"]

  var body: some View {
    VStack(spacing: 0) {
      Spacer().frame(height: 32)
      heroCard
      Spacer().frame(height: 24)
      wishesList
      Spacer()
    }
    .padding(.horizontal, 20)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    .background { backgroundImage.ignoresSafeArea() }
    .navigationTitle("Christmas")
    .navigationBarTitleDisplayMode(.inline)
    .toolbarBackground(.hidden, for: .navigationBar)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          showPicker = true
        } label: {
          Image(systemName: "paintbrush.pointed")
            .foregroundStyle(theme.christmas.accent)
        }
      }
    }
    .sheet(isPresented: $showPicker) {
      ChristmasPickerView()
    }
  }

  private var backgroundImage: some View {
    Group {
      if let uiImage = UIImage(named: theme.christmas.backgroundImageName) {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFill()
      } else {
        Color(.systemBackground)
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
