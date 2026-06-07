import UIKit
import ThemeKit

final class InMemoryStorage: ThemeStorage {
    private var store: [String: Any] = [:]
    func data(forKey key: String) -> Data? { store[key] as? Data }
    func set(_ value: Any?, forKey key: String) { store[key] = value }
}

struct TestColors: ThemeExtension {
    var tintHex: Int
    var backgroundHex: Int
    var colorScheme: SystemColorScheme
    var isCustomDefined: Bool = false

    static let defaultValue = TestColors(
        tintHex: 0xFF0000,
        backgroundHex: 0xFFFFFF,
        colorScheme: .light
    )

    func merging(_ other: TestColors) -> TestColors {
        guard isCustomDefined else { return other }
        var result = other
        result.tintHex = tintHex
        result.isCustomDefined = true
        return result
    }
}

struct TestVariant: ThemeVariant {
    let id: String
    let light: TestColors
    let dark: TestColors

    static let `default` = TestVariant(
        id: "default",
        light: TestColors(tintHex: 0xFF0000, backgroundHex: 0xFFFFFF, colorScheme: .light),
        dark:  TestColors(tintHex: 0x880000, backgroundHex: 0x000000, colorScheme: .dark)
    )

    static let alternate = TestVariant(
        id: "alternate",
        light: TestColors(tintHex: 0x0000FF, backgroundHex: 0xFFFFFF, colorScheme: .light),
        dark:  TestColors(tintHex: 0x000088, backgroundHex: 0x000000, colorScheme: .dark)
    )

    static let all: [TestVariant] = [.default, .alternate]
}

extension Theme {
    var testColors: TestColors {
        get { self[TestColors.self] }
        set { self[TestColors.self] = newValue }
    }
}
