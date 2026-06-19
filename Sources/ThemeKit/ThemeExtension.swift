//
//  ThemeExtension.swift
//  ThemeKit
//
//  Created by Ademola on 06/06/2026.
//

/// A type-erased wrapper around a single `WritableKeyPath` on `T`.
///
/// Create one per user-customisable field inside `ThemeOverridable.props`.
/// Each `Prop` participates in two operations:
///
/// - **`merging(_:)`** — copies the field's value from `other` onto `self`.
/// - **`compare(to:)`** — checks whether the field on `self` differs from a preset.
public struct Prop<T>: Equatable {

  /// Creates a prop for the property at `kp`.
  ///
  /// - Parameter kp: A writable key path to the field this prop governs.
  ///   The field must be `Equatable` so it can be compared in `compare(to:)`.
  public init<V: Equatable>(_ kp: WritableKeyPath<T, V>) {
    apply = { $0[keyPath: kp] = $1[keyPath: kp] }
    isEqual = { $0[keyPath: kp] == $1[keyPath: kp] }
  }

  let apply: (inout T, T) -> Void
  let isEqual: (T, T) -> Bool

  public static func == (lhs: Prop<T>, rhs: Prop<T>) -> Bool { true }
}

/// A typed value that can be stored in and retrieved from a `Theme`.
///
/// Adopt this protocol to define the data your app's theme carries —
/// colors, typography, spacing, or any other `Codable` type.
/// The package has no opinion on what the value contains.
///
/// Register a `ThemeExtension` type by adding a named property to `Theme`
/// via an extension:
///
/// ```swift
/// struct AppColors: ThemeExtension {
///     static let defaultValue = AppColors(...)
///     @CodableColor var tint: UIColor
///     @CodableColor var background: UIColor
///     var colorScheme: SystemColorScheme
/// }
///
/// extension Theme {
///     var colors: AppColors { value(AppColors.self) }
/// }
/// ```
///
/// To allow per-field user customisation (e.g. a color picker that overrides
/// just one field while keeping other preset values), conform to `ThemeOverridable`
/// alongside `ThemeExtension` and declare your `props`.
public protocol ThemeExtension: Codable, Equatable, Sendable {
  /// A stable string key used to read and write this value in `UserDefaults`.
  /// Defaults to the type name. Override if you rename the type.
  static var extensionKey: String { get }

  /// The value returned by `Theme` before any value has been applied.
  static var defaultValue: Self { get }

  /// The light/dark appearance this value prefers.
  /// `ThemeApplier` reads this to override the window's interface style.
  var colorScheme: SystemColorScheme { get }
}

extension ThemeExtension {
  /// Derives the key from the type name. Override to pin it to a stable string.
  public static var extensionKey: String { String(describing: self) }
}

/// A protocol for `ThemeExtension` types that declare user-customisable fields.
///
/// Conform to this alongside `ThemeExtension` when some fields should be
/// individually overridable by the user (e.g. an accent color set via a color
/// well) while other fields remain controlled by the active preset.
///
/// ```swift
/// struct AppColors: ThemeExtension, ThemeOverridable {
///     var tint: Color
///     var background: Color
///     var colorScheme: SystemColorScheme
///
///     static let defaultValue = AppColors(...)
///
///     var props: [Prop<Self>] {[
///         .init(\.tint),
///     ]}
/// }
/// ```
public protocol ThemeOverridable {
  /// `Prop<Self>` — a type-erased rule for a single user-customisable field.
  typealias Prop = ThemeKit.Prop<Self>

  /// The fields the user can individually override (e.g. accent color, background image).
  ///
  /// These fields drive:
  ///
  /// - `merging(_:)` — the incoming value's listed fields are overlaid onto `self`.
  /// - `compare(to:)` — detecting whether any of them differ from a preset.
  var props: [Prop] { get }
}

extension ThemeOverridable {
  /// Overlays the `props` fields from `other` onto `self`, returning the result.
  ///
  /// Starts from `self` (the stored value) and copies each field listed in `props`
  /// from `other` (the incoming value). Non-listed fields remain as they are in `self`.
  public func merging(_ other: Self) -> Self {
    var merged = self
    props.forEach { $0.apply(&merged, other) }
    return merged
  }

  /// Returns `true` if any field listed in `props` differs between `self` and `preset`.
  ///
  /// Use this to detect user customisation without storing a separate flag:
  ///
  /// ```swift
  /// let preset = variant.value(for: theme.christmas.colorScheme)
  /// if theme.christmas.compare(to: preset) {
  ///     // show Reset to Preset button
  /// }
  /// ```
  public func compare(to preset: Self) -> Bool {
    props.contains { !$0.isEqual(self, preset) }
  }
}
