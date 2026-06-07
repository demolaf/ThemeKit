import SwiftUI

/// Retroactive `Codable` conformance for `SwiftUI.Color`, encoding as a hex integer.
///
/// This allows `ThemeExtension` types to store `Color` values directly:
///
/// ```swift
/// struct AppColors: ThemeExtension {
///     var tint: Color
///     var background: Color
/// }
/// ```
extension Color: @retroactive Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(hex: try container.decode(Int.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let components = cgColor?.components, components.count >= 3 {
            let hex = (Int(components[0] * 255) << 16)
                    | (Int(components[1] * 255) <<  8)
                    |  Int(components[2] * 255)
            try container.encode(hex)
        } else {
            try container.encode(0)
        }
    }
}

public extension Color {
    /// Creates a `Color` from a hex integer literal.
    ///
    /// ```swift
    /// let red = Color(hex: 0xFF2D55)
    /// ```
    init(hex: Int) {
        self.init(
            red:   Double((hex & 0xFF0000) >> 16) / 255.0,
            green: Double((hex & 0x00FF00) >>  8) / 255.0,
            blue:  Double( hex & 0x0000FF)         / 255.0
        )
    }
}
