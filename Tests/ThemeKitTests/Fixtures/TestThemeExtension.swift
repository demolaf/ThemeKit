import UIKit

@testable import ThemeKit

final class InMemoryStorage: ThemeStorage {
  private var store: [String: Any] = [:]
  func data(forKey key: String) -> Data? { store[key] as? Data }
  func set(_ value: Any?, forKey key: String) { store[key] = value }
}

struct TestColors: ThemeExtension {
  var tintHex: Int
  var backgroundHex: Int
  var colorScheme: SystemColorScheme

  static let defaultValue = TestColors(
    tintHex: 0xFF0000,
    backgroundHex: 0xFFFFFF,
    colorScheme: .light
  )

  var overrideProps: [OverrideProps<TestColors>] {
    [
      .init(\.tintHex)
    ]
  }
}

struct TestColorsPlain: ThemeExtension {
  var tintHex: Int
  var colorScheme: SystemColorScheme

  static let defaultValue = TestColorsPlain(tintHex: 0xFF0000, colorScheme: .light)
}

struct TestVariant: ThemeVariant {
  let id: String
  let light: TestColors
  let dark: TestColors

  static let `default` = TestVariant(
    id: "default",
    light: TestColors(tintHex: 0xFF0000, backgroundHex: 0xFFFFFF, colorScheme: .light),
    dark: TestColors(tintHex: 0x880000, backgroundHex: 0x000000, colorScheme: .dark)
  )

  static let alternate = TestVariant(
    id: "alternate",
    light: TestColors(tintHex: 0x0000FF, backgroundHex: 0xFFFFFF, colorScheme: .light),
    dark: TestColors(tintHex: 0x000088, backgroundHex: 0x000000, colorScheme: .dark)
  )

  static let all: [TestVariant] = [.default, .alternate]
}

extension Theme {
  var testColors: TestColors {
    get { self[TestColors.self] }
    set { self[TestColors.self] = newValue }
  }
}
