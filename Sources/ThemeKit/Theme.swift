//
//  Theme.swift
//  ThemeKit
//
//  Created by Ademola on 06/06/2026.
//

import Foundation
import Observation

/// The central store for all theme values.
///
/// `Theme` holds any number of `ThemeExtension` values, persists them across
/// launches, and notifies SwiftUI and UIKit observers when they change.
///
/// Create one instance and pass it down — no singleton:
///
/// ```swift
/// // SceneDelegate / App entry point
/// let theme = Theme()
///
/// // Read
/// theme.colors.tintColor
///
/// // Write
/// theme.apply(AppColors.pink)
/// theme.merge(AppColors(tintColor: .red))
/// theme.apply(variant: AppColorsVariant.pink, for: .dark)
/// ```
@Observable
@MainActor
public final class Theme {

    // MARK: - Observation

    /// Per-key version counters. Reading `_observedExtensions[key]` registers
    /// a fine-grained observation dependency for that extension type only.
    private var _observedExtensions: [String: Int] = [:]

    /// Encoded extension values, lazily populated from storage on first read.
    @ObservationIgnored
    private var _extensionCache: [String: Data] = [:]

    // MARK: - Metadata

    private let storage: any ThemeStorage

    /// Whether the theme mirrors the system light/dark appearance.
    ///
    /// Setting this to `true` releases any forced interface style override.
    /// Setting it to `false` locks the appearance to the active extension's `colorScheme`.
    public var followsSystem: Bool = false {
        didSet {
            guard followsSystem != oldValue else { return }
            ThemeData(followsSystem: followsSystem, activeVariantID: activeVariantID)
                .store(to: storage)
        }
    }

    /// The `id` of the last active `ThemeVariant`.
    ///
    /// Set automatically by `apply(variant:for:)`. Read by appliers in
    /// `ThemeKitSwiftUI` and `ThemeKitUIKit` to restore the correct variant on relaunch.
    public var activeVariantID: String? {
        didSet {
            guard activeVariantID != oldValue else { return }
            ThemeData(followsSystem: followsSystem, activeVariantID: activeVariantID)
                .store(to: storage)
        }
    }

    // MARK: - Init

    /// Creates a `Theme` backed by `UserDefaults.standard`.
    public convenience init() {
        self.init(storage: UserDefaultsStorage(.standard))
    }

    /// Creates a `Theme` backed by a `UserDefaults` suite.
    ///
    /// Use a unique `suiteName` to isolate this theme's storage from other `Theme` instances
    /// in the same app (e.g. a self-contained themed section with its own variant history).
    ///
    /// - Parameter suiteName: The `UserDefaults` suite name to use for storage.
    public convenience init(suiteName: String) {
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        self.init(storage: UserDefaultsStorage(defaults))
    }

    /// Creates a `Theme` backed by a custom storage — pass any `ThemeStorage` conformance,
    /// including an in-memory store for tests.
    public init(storage: any ThemeStorage) {
        self.storage = storage
        if case .success(let data) = ThemeData.fetch(from: storage) {
            self.followsSystem = data.followsSystem
            self.activeVariantID = data.activeVariantID
        }
    }

    // MARK: - Subscript

    /// Reads and writes a `ThemeExtension` value by type.
    ///
    /// Reading registers a fine-grained observation dependency for that type —
    /// observers are only notified when that specific extension changes.
    subscript<T: ThemeExtension>(_ type: T.Type) -> T {
        get {
            _ = _observedExtensions[T.extensionKey]
            if let data = _extensionCache[T.extensionKey] ?? storage.data(forKey: "themeExtension.\(T.extensionKey)"),
               let value = try? JSONDecoder().decode(T.self, from: data) {
                return value
            }
            return T.defaultValue
        }
        set {
            if let cachedData = _extensionCache[T.extensionKey],
               let cached = try? JSONDecoder().decode(T.self, from: cachedData),
               cached == newValue { return }
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            _extensionCache[T.extensionKey] = data
            storage.set(data, forKey: "themeExtension.\(T.extensionKey)")
            _observedExtensions[T.extensionKey, default: 0] += 1
        }
    }

    // MARK: - Public API

    /// Returns the currently stored value for `T`, or `T.defaultValue` if nothing has been stored.
    ///
    /// - Parameter type: The extension type to read.
    public func value<T: ThemeExtension>(_ type: T.Type) -> T { self[T.self] }

    /// Replaces the stored value for `T` entirely.
    ///
    /// - Parameter value: The new value. Overwrites any previously stored value.
    public func apply<T: ThemeExtension>(_ value: T) {
        self[T.self] = value
    }

    /// Merges `value` into the currently stored value for `T` and sets `followsSystem` to `false`.
    ///
    /// Calls `currentValue.merging(value)` — overlaying the fields listed in
    /// `overrideProps` from `value` onto the stored base. Use this when the user
    /// sets a custom field (e.g. a custom accent color) so the change takes manual
    /// control and disables follow-system.
    ///
    /// - Parameter value: The incoming value whose `overrideProps` fields are applied.
    public func merge<T: ThemeExtension>(_ value: T) {
        self[T.self] = self[T.self].merging(value)
        followsSystem = false
    }

    /// Applies the light or dark value from `variant` based on `scheme`,
    /// records the variant's `id` for relaunch restoration, and sets `followsSystem` to `false`.
    ///
    /// - Parameters:
    ///   - variant: The preset to apply.
    ///   - scheme: The color scheme to resolve against.
    public func apply<V: ThemeVariant>(variant: V, for scheme: SystemColorScheme) {
        activeVariantID = variant.id
        apply(variant.value(for: scheme))
        followsSystem = false
    }

    /// Returns `true` if a value for `type` has ever been written to storage.
    ///
    /// Used by `ThemeApplier` to detect first launch — if nothing has been
    /// persisted yet, the applier writes the default variant for the current system style.
    ///
    /// - Parameter type: The extension type to check.
    public func hasPersisted<T: ThemeExtension>(_ type: T.Type) -> Bool {
        storage.data(forKey: "themeExtension.\(T.extensionKey)") != nil
    }
}
