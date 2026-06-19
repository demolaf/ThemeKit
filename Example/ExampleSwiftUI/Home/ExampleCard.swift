import SwiftUI

struct ExampleCard<Destination: View>: View {
  let title: String
  let description: String
  let gradient: [Color]
  @ViewBuilder let destination: () -> Destination

  var body: some View {
    NavigationLink(destination: destination()) {
      HStack(alignment: .center, spacing: 16) {
        VStack(alignment: .leading, spacing: 6) {
          Text(title)
            .font(.headline)
            .foregroundStyle(.white)
          Text(description)
            .font(.subheadline)
            .foregroundStyle(.white.opacity(0.85))
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
        }
        Spacer()
        Image(systemName: "chevron.right")
          .foregroundStyle(.white.opacity(0.6))
          .fontWeight(.semibold)
      }
      .padding(20)
      .background(
        LinearGradient(colors: gradient, startPoint: .leading, endPoint: .trailing)
      )
      .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    .buttonStyle(.plain)
  }
}

extension Color {
  init(hex: Int) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xFF) / 255,
      green: Double((hex >> 8) & 0xFF) / 255,
      blue: Double(hex & 0xFF) / 255
    )
  }
}
