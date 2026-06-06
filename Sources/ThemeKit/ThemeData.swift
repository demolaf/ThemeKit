//
//  ThemeData.swift
//  ThemeKit
//
//  Created by Ademola on 06/06/2026.
//

import Foundation

/// Wire format for persisting theme metadata between app launches.
///
/// `ThemeData` is encoded as JSON and stored under a single `UserDefaults` key.
/// `Theme` reads it on init to restore the last known state, and writes it
/// whenever `followsSystem` or `activeVariantID` changes:
///
/// ```swift
/// // Inside Theme.init(userDefaults:)
/// if case .success(let data) = ThemeData.fetch(from: userDefaults) {
///     self.followsSystem = data.followsSystem
///     self.activeVariantID = data.activeVariantID
/// }
///
/// // Inside Theme, when followsSystem changes
/// var followsSystem: Bool = false {
///     didSet { ThemeData(followsSystem: followsSystem, activeVariantID: activeVariantID).store(to: userDefaults) }
/// }
/// ```
struct ThemeData: Codable {
    
    /// Whether the theme should mirror the system light/dark appearance.
    var followsSystem: Bool = false
    
    /// The `id` of the last active `ThemeVariant`, used to restore the correct preset on relaunch when `followsSystem` is `true`.
    var activeVariantID: String? = nil
    
    private static let key = "themekit.metadata"
    
    /// Encodes and writes this value to the given `UserDefaults` instance.
    ///
    /// - Parameter userDefaults: The store to write to.
    /// - Returns: `.success` on write, `.failure(.store(_:))` if encoding fails.
    @discardableResult
    func store(to userDefaults: UserDefaults) -> Result<Void, ThemeKitError> {
        do {
            let data = try JSONEncoder().encode(self)
            userDefaults.set(data, forKey: Self.key)
            return .success(())
        } catch {
            return .failure(.store(error.localizedDescription))
        }
    }
    
    /// Reads and decodes a `ThemeData` value from the given `UserDefaults` instance.
    ///
    /// - Parameter userDefaults: The store to read from.
    /// - Returns: `.success(ThemeData)` if data exists and decodes cleanly,
    ///   otherwise `.failure(.fetch(_:))`.
    static func fetch(from userDefaults: UserDefaults) -> Result<ThemeData, ThemeKitError> {
        guard let data = userDefaults.data(forKey: key) else {
            return .failure(.fetch("No theme metadata found"))
        }
        
        do {
            return .success(try JSONDecoder().decode(ThemeData.self, from: data))
        } catch {
            return .failure(.fetch(error.localizedDescription))
        }
    }
}
