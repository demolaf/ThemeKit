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
    package var activeVariantID: String? {
        didSet {
            guard activeVariantID != oldValue else { return }
            ThemeData(followsSystem: followsSystem, activeVariantID: activeVariantID)
                .store(to: storage)
        }
    }

    // MARK: - Init

    /// Creates a `Theme` backed by the given storage.
    ///
    /// - Parameter storage: Defaults to `UserDefaults.standard`. Pass any `ThemeStorage`
    ///   conformance — including an in-memory store in tests.
    public init(storage: any ThemeStorage = UserDefaults.standard) {
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

    /// Merges `value` into the currently stored value for `T`.
    ///
    /// Calls `currentValue.merging(value)` — letting the app's `merging(_:)`
    /// implementation decide which fields to preserve (e.g. user-customised colors).
    ///
    /// - Parameter value: The incoming value to merge.
    public func merge<T: ThemeExtension>(_ value: T) {
        self[T.self] = self[T.self].merging(value)
    }

    /// Applies the light or dark value from `variant` based on `scheme`,
    /// and records the variant's `id` for relaunch restoration.
    ///
    /// - Parameters:
    ///   - variant: The preset to apply.
    ///   - scheme: The color scheme to resolve against.
    public func apply<V: ThemeVariant>(variant: V, for scheme: SystemColorScheme) {
        activeVariantID = variant.id
        apply(variant.value(for: scheme))
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
