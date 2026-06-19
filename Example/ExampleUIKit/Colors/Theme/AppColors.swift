import ThemeKit
import UIKit

struct AppColors: ThemeExtension {
  @CodableColor var tint: UIColor
  @CodableColor var background: UIColor
  @CodableColor var container: UIColor
  var colorScheme: SystemColorScheme

  static let defaultValue = AppColors(
    tint: UIColor(hex: 0x007AFF),
    background: UIColor(hex: 0xF2F2F7),
    container: UIColor(hex: 0xE5E5EA),
    colorScheme: .light
  )

  var overrideProps: [OverrideProps<Self>] {
    [
      .init(\.tint)
    ]
  }
}

extension Theme {
  var colors: AppColors { value(AppColors.self) }
}
