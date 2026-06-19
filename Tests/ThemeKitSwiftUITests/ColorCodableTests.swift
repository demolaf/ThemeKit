import Testing
import SwiftUI
@testable import ThemeKitSwiftUI

@Suite("Color Codable")
struct ColorCodableTests {

    // All hex values used across AppColorsVariant and ChristmasVariant in both example targets.
    private let variantHexValues: [Int] = [
        // AppColors
        0x007AFF, 0x0A84FF,
        0xF2F2F7, 0x1C1C1E,
        0xE5E5EA, 0x2C2C2E,
        0x32ADE6, 0x64D2FF,
        0xF0F8FF, 0x0A1628,
        0xD0ECFF, 0x162033,
        0xFF2D55, 0xFF375F,
        0xFFF0F3, 0x1C0A0E,
        0xFFD6DE, 0x2A1016,
        // ChristmasTheme
        0xCC0000, 0xFF6B6B,
        0x1A5276, 0x7FD4F4,
    ]

    @Test("Color(hex:) round-trips through JSON encoding for all variant colors")
    func colorHexRoundTrips() throws {
        for hex in variantHexValues {
            let original = Color(hex: hex)
            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(Color.self, from: data)
            #expect(original == decoded, "Hex 0x\(String(hex, radix: 16, uppercase: true)) did not round-trip")
        }
    }
}
