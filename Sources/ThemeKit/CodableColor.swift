import UIKit

/// A property wrapper that stores a `UIColor` as a hex integer for `Codable` conformance.
///
/// Use this when defining `ThemeExtension` types that need to store colors in UIKit:
///
/// ```swift
/// struct AppColors: ThemeExtension {
///     @CodableColor var tint: UIColor
///     @CodableColor var background: UIColor
/// }
/// ```
@propertyWrapper
public struct CodableColor: Codable, Equatable, @unchecked Sendable {
  public var wrappedValue: UIColor

  public init(wrappedValue: UIColor) {
    self.wrappedValue = wrappedValue
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    wrappedValue = UIColor(hex: try container.decode(Int.self))
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(wrappedValue.hex)
  }
}
