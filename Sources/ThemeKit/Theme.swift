//
//  Theme.swift
//  ThemeKit
//
//  Created by Ademola on 06/06/2026.
//

import Foundation
import Observation
import UIKit

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
public final class Theme {
    /// Creates a `Theme` backed by the given `UserDefaults` instance.
    ///
    /// - Parameter userDefaults: Defaults to `.standard`. Pass a custom suite in tests.
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        if case .success(let data) = ThemeData.fetch(from: userDefaults) {
            self.followsSystem = data.followsSystem
            self.activeVariantID = data.activeVariantID
        }
    }
    
    // MARK: - Observation
    
    /// Per-key version counters. Reading `_observedExtensions[key]` registers
    /// a fine-grained observation dependency for that extension type only.
    private var _observedExtensions: [String: Int] = [:]
    
    /// Encoded extension values, lazily populated from `UserDefaults` on first read.
    private var _extensionCache: [String: Data] = [:]
    
    // MARK: - Metadata
    
    private let userDefaults: UserDefaults
    
    /// The `id` of the last active `ThemeVariant`.
    ///
    /// Set automatically by `apply(variant:for:)`. Read by `ThemeApplier`
    /// on relaunch to restore the correct variant when `followsSystem` is `true`.
    var activeVariantID: String? {
        didSet {
            guard activeVariantID != oldValue else { return }
            ThemeData(followsSystem: followsSystem, activeVariantID: activeVariantID)
                .store(to: userDefaults)
        }
    }
    
    /// Whether the theme mirrors the system light/dark appearance.
    ///
    /// Setting this to `true` releases any forced interface style override.
    /// Setting it to `false` locks the appearance to the active extension's `preferredStyle`.
    public var followsSystem: Bool = false {
        didSet {
            guard followsSystem != oldValue else { return }
            ThemeData(followsSystem: followsSystem, activeVariantID: activeVariantID)
                .store(to: userDefaults)
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
            if let data = _extensionCache[T.extensionKey] ?? userDefaults.data(forKey: "themeExtension.\(T.extensionKey)"),
               let value = try? JSONDecoder().decode(T.self, from: data) {
                return value
            }
            return T.defaultValue
        }
        
        set {
            guard let data = try? JSONEncoder().encode(newValue) else { return }
            guard data != _extensionCache[T.extensionKey] else { return }
            _extensionCache[T.extensionKey] = data
            userDefaults.set(data, forKey: "themeExtension.\(T.extensionKey)")
            _observedExtensions[T.extensionKey, default: 0] += 1
        }
    }
    
    // MARK: - Public API
    
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
    
    /// Applies the light or dark value from `variant` based on `style`,
    /// and records the variant's `id` for relaunch restoration.
    ///
    /// - Parameters:
    ///   - variant: The preset to apply.
    ///   - style: The interface style to resolve against.
    public func apply<V: ThemeVariant>(variant: V, for style: UIUserInterfaceStyle) {
        activeVariantID = variant.id
        apply(variant.value(for: style))
    }

    /// Returns `true` if a value for `type` has ever been written to `UserDefaults`.
    ///
    /// Used by `ThemeApplier` to detect first launch — if nothing has been
    /// persisted yet, the applier writes the default variant for the current system style.
    ///
    /// - Parameter type: The extension type to check.
    public func hasPersisted<T: ThemeExtension>(_ type: T.Type) -> Bool {
        userDefaults.data(forKey: "themeExtension.\(T.extensionKey)") != nil
    }
}
