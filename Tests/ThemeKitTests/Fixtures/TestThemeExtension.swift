import UIKit

@testable import ThemeKit

final class InMemoryStorage: ThemeStorage {
  private var store: [String: Any] = [:]
  private(set) var writeCount = 0
  func data(forKey key: String) -> Data? { store[key] as? Data }
  func set(_ value: Any?, forKey key: String) {
    writeCount += 1
    store[key] = value
  }
}

struct TestColors: ThemeExtension, ThemeOverridable {
  var tintHex: Int
  var backgroundHex: Int
  var colorScheme: SystemColorScheme

  static let fallback = TestColors(
    tintHex: 0xFF0000,
    backgroundHex: 0xFFFFFF,
    colorScheme: .light
  )

  var props: [Prop<Self>] {
    [
      .init(\.tintHex)
    ]
  }
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

struct TestFont: ThemeExtension {
  var size: Int
  var colorScheme: SystemColorScheme

  static let fallback = TestFont(size: 16, colorScheme: .light)
}

extension Theme {
  var testColors: TestColors {
    get { self[TestColors.self] }
    set { self[TestColors.self] = newValue }
  }

  var testFont: TestFont {
    get { self[TestFont.self] }
    set { self[TestFont.self] = newValue }
  }
}
