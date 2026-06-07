//
//  ThemeExtension.swift
//  ThemeKit
//
//  Created by Ademola on 06/06/2026.
//

/// A typed value that can be stored in and retrieved from a `Theme`.
///
/// Adopt this protocol to define the data your app's theme carries —
/// colors, typography, spacing, or any other `Codable` type.
/// The package has no opinion on what the value contains.
///
/// Register a `ThemeExtension` type by adding a named property to `Theme`
/// via an extension, using the internal subscript as the backing store:
///
/// ```swift
/// struct AppColors: ThemeExtension {
///     static let defaultValue = AppColors.defaultLight
///     var tintColor: UIColor
///     var primaryBackgroundColor: UIColor
///     var colorScheme: SystemColorScheme
/// }
///
/// extension Theme {
///     var colors: AppColors {
///         get { self[AppColors.self] }
///         set { self[AppColors.self] = newValue }
///     }
/// }
///
/// // Usage
/// theme.colors.tintColor  // reads AppColors from the store
/// theme.apply(AppColors.pink)  // writes to the store
/// ```
public protocol ThemeExtension: Codable, Equatable, Sendable {
    /// A stable string key used to read and write this value in `UserDefaults`.
    /// Defaults to the type name. Override if you rename the type.
    static var extensionKey: String { get }
    
    /// The value returned by `Theme` before any value has been applied.
    static var defaultValue: Self { get }
    
    /// The light/dark appearance this value prefers.
    /// `ThemeApplier` reads this to override the window's interface style.
    var colorScheme: SystemColorScheme { get }
    
    /// Merges `self` into `other`, returning a combined value.
    ///
    /// Called by `Theme.merge(_:)`. Use this to preserve fields that
    ///
    /// ```swift
    /// func merging(_ other: AppColors) -> AppColors {
    ///     guard isCustomDefined else { return other }
    ///     var result = other
    ///     result.tintColor = tintColor
    ///     result.isCustomDefined = true
    ///     return result
    /// }
    /// ```
    func merging(_ other: Self) -> Self
}

/// Default implementations for `ThemeExtension`.
public extension ThemeExtension {
    /// Derives the key from the type name. Override to pin it to a stable string.
    static var extensionKey: String { String(describing: self) }
    
    /// Full replacement — `other` wins. Override to preserve custom fields.
    func merging(_ other: Self) -> Self { other }
}
