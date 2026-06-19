//
//  ThemeExtension.swift
//  ThemeKit
//
//  Created by Ademola on 06/06/2026.
//

/// A type-erased wrapper around a single `WritableKeyPath` on `T`.
///
/// Used by `ThemeExtension.overrideProps` to declare which fields are
/// user-customisable. Each rule participates in two operations:
///
/// - **`merging(_:)`** — copies the field from `self` onto `other`.
/// - **`compare(to:)`** — checks whether the field on `self` differs from the preset.
public struct OverrideProps<T>: Equatable {

    /// Creates an override rule for the property at `kp`.
    ///
    /// - Parameter kp: A writable key path to the field this rule governs.
    ///   The field must be `Equatable` so it can be compared in `compare(to:)`.
    public init<V: Equatable>(_ kp: WritableKeyPath<T, V>) {
        apply = { $0[keyPath: kp] = $1[keyPath: kp] }
        isEqual = { $0[keyPath: kp] == $1[keyPath: kp] }
    }

    let apply: (inout T, T) -> Void
    let isEqual: (T, T) -> Bool

    public static func == (lhs: OverrideProps<T>, rhs: OverrideProps<T>) -> Bool { true }
}

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
///
///     var overrideProps: [OverrideProps<AppColors>] {[
///         .init(\.tintColor),
///     ]}
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

    /// The fields the user can individually override (e.g. accent color, background image).
    ///
    /// These fields are used by:
    ///
    /// - `merging(_:)` — the incoming value's listed fields are overlaid onto `self`.
    /// - `compare(to:)` — to detect whether any of them differ from a preset.
    ///
    /// Return `[]` (the default) for types whose values are always replaced in full.
    var overrideProps: [OverrideProps<Self>] { get }

    /// Overlays the `overrideProps` fields from `other` onto `self`, returning the result.
    ///
    /// Called by `Theme.merge(_:)`. Starts from `self` (the stored value) and
    /// copies each field listed in `overrideProps` from `other` (the incoming value).
    /// Non-listed fields remain as they are in `self`.
    /// Returns `other` entirely when `overrideProps` is empty.
    func merging(_ other: Self) -> Self
}

/// Default implementations for `ThemeExtension`.
public extension ThemeExtension {

    /// Derives the key from the type name. Override to pin it to a stable string.
    static var extensionKey: String { String(describing: self) }

    /// Returns `[]` — the incoming value replaces `self` entirely on merge.
    /// Override to declare which fields the incoming value can selectively update.
    var overrideProps: [OverrideProps<Self>] { [] }

    /// Overlays `overrideProps` fields from `other` onto `self`.
    /// Returns `other` entirely when `overrideProps` is empty.
    func merging(_ other: Self) -> Self {
        guard !overrideProps.isEmpty else { return other }
        var merged = self
        overrideProps.forEach { $0.apply(&merged, other) }
        return merged
    }

    /// Returns `true` if any field listed in `overrideProps` differs between `self` and `preset`.
    ///
    /// Use this to detect user customisation without storing a separate flag:
    ///
    /// ```swift
    /// let preset = variant.value(for: theme.christmas.colorScheme)
    /// if theme.christmas.compare(to: preset) {
    ///     // show Reset to Preset button
    /// }
    /// ```
    func compare(to preset: Self) -> Bool {
        overrideProps.contains { !$0.isEqual(self, preset) }
    }
}
