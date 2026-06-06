//
//  ThemeKitError.swift
//  ThemeKit
//
//  Created by Ademola on 06/06/2026.
//

/// Errors thrown by ThemeKit during persistence operations.
///
/// Returned by `ThemeData.store(to:)` and `ThemeData.fetch(from:)`
/// as associated values on `Result`:
///
/// ```swift
/// switch ThemeData.fetch(from: userDefaults) {
/// case .success(let data): ...
/// case .failure(let error): print(error)
/// }
/// ```
public enum ThemeKitError: Error {
    /// A value could not be read or decoded from `UserDefaults`.
    case fetch(String)
    
    /// A value could not be encoded or written to `UserDefaults`.
    case store(String)
}
