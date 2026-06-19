import UIKit

/// Hex integer convenience initialisers and accessors for `UIColor`.
public extension UIColor {

    /// Creates a `UIColor` from a hex integer literal.
    ///
    /// ```swift
    /// let purple = UIColor(hex: 0x8E44AD)
    /// let semiTransparent = UIColor(hex: 0x8E44AD, alpha: 0.5)
    /// ```
    ///
    /// - Parameters:
    ///   - hex: An RGB hex integer, e.g. `0xFF2D55`.
    ///   - alpha: Opacity from `0.0` to `1.0`. Defaults to `1.0`.
    convenience init(hex: Int, alpha: Double = 1.0) {
        let red   = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0xFF00)   >>  8) / 255.0
        let blue  = Double((hex & 0xFF)     >>  0) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    /// The RGB components of this color packed into a hex integer.
    ///
    /// ```swift
    /// UIColor(hex: 0xFF2D55).hex // → 0xFF2D55
    /// ```
    var hex: Int {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (Int((red * 255).rounded()) << 16) | (Int((green * 255).rounded()) << 8) | Int((blue * 255).rounded())
    }
}
