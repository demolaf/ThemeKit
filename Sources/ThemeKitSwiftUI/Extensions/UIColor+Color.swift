//
//  UIColor+Color.swift
//  ThemeKit
//
//  Created by Ademola on 07/06/2026.
//

import SwiftUI

/// Bridges `UIColor` to SwiftUI's `Color`.
extension UIColor {
  public var color: Color { Color(uiColor: self) }
}
