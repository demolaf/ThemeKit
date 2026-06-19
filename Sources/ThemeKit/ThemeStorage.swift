import Foundation

/// Abstracts the persistence backend used by `Theme`.
///
/// Conform any type to this protocol to provide a custom storage mechanism —
/// Keychain, CloudKit, or an in-memory store for tests.
///
/// `UserDefaults` conforms out of the box:
/// ```swift
/// let theme = Theme() // uses UserDefaults.standard by default
/// ```
public protocol ThemeStorage {

  /// Returns the data stored for `key`, or `nil` if no value exists.
  func data(forKey key: String) -> Data?

  /// Stores `value` under `key`, replacing any existing value.
  func set(_ value: Any?, forKey key: String)
}

/// `UserDefaults` satisfies `ThemeStorage` without any additional implementation.
extension UserDefaults: ThemeStorage {}
