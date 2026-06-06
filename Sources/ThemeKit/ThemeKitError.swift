//
//  ThemeKitError.swift
//  ThemeKit
//
//  Created by Ademola on 06/06/2026.
//

/// Errors thrown by ThemeKit during persistence operations.
public enum ThemeKitError: Error {
    case fetch(String)
    case store(String)
}
