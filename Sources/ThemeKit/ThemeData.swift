//
//  ThemeData.swift
//  ThemeKit
//
//  Created by Ademola on 06/06/2026.
//

import Foundation

/// Wire format for persisting theme metadata between app launches.
///
/// `ThemeData` is encoded as JSON and stored under a single `ThemeStorage` key.
/// `Theme` reads it on init to restore the last known state, and writes it
/// whenever `followsSystem` or `activeVariantID` changes:
///
/// ```swift
/// // Inside Theme.init(storage:)
/// if case .success(let data) = ThemeData.fetch(from: storage) {
///     self.followsSystem = data.followsSystem
///     self.activeVariantID = data.activeVariantID
/// }
///
/// // Inside Theme, when followsSystem changes
/// var followsSystem: Bool = false {
///     didSet { ThemeData(followsSystem: followsSystem, activeVariantID: activeVariantID).store(to: storage) }
/// }
/// ```
struct ThemeData: Codable {

    /// Whether the theme should mirror the system light/dark appearance.
    var followsSystem: Bool = false

    /// The `id` of the last active `ThemeVariant`, used to restore the correct
    /// preset on relaunch when `followsSystem` is `true`.
    var activeVariantID: String? = nil

    private static let key = "themeKit.metadata"

    /// Encodes and writes this value to the given `ThemeStorage` instance.
    ///
    /// - Parameter storage: The store to write to.
    /// - Returns: `.success` on write, `.failure(.store(_:))` if encoding fails.
    @discardableResult
    func store(to storage: any ThemeStorage) -> Result<Void, ThemeKitError> {
        do {
            let data = try JSONEncoder().encode(self)
            storage.set(data, forKey: Self.key)
            return .success(())
        } catch {
            return .failure(.store(error.localizedDescription))
        }
    }

    /// Reads and decodes a `ThemeData` value from the given `ThemeStorage` instance.
    ///
    /// - Parameter storage: The store to read from.
    /// - Returns: `.success(ThemeData)` if data exists and decodes cleanly,
    ///   otherwise `.failure(.fetch(_:))`.
    static func fetch(from storage: any ThemeStorage) -> Result<ThemeData, ThemeKitError> {
        guard let data = storage.data(forKey: key) else {
            return .failure(.fetch("No theme metadata found"))
        }
        do {
            return .success(try JSONDecoder().decode(ThemeData.self, from: data))
        } catch {
            return .failure(.fetch(error.localizedDescription))
        }
    }
}
