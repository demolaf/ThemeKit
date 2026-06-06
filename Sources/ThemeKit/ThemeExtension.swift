//
//  ThemeExtension.swift
//  ThemeKit
//
//  Created by Ademola on 06/06/2026.
//

import UIKit

/// A typed value that can be stored in and retrieved from a `Theme`.
public protocol ThemeExtension: Codable, Equatable {
    static var extensionKey: String { get }
    static var defaultValue: Self { get }
    var preferredStyle: UIUserInterfaceStyle { get }
    func merging(_ other: Self) -> Self
}

/// Default implementations for `ThemeExtension`.
public extension ThemeExtension {
    static var extensionKey: String { String(describing: self) }
    func merging(_ other: Self) -> Self { other }
}
