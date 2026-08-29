# ``ThemeKit``

Core types for app-wide theme management across iOS, macOS, and watchOS.

## Overview

ThemeKit lets your app define typed theme values — colors, fonts, spacing — as ``ThemeExtension`` structs, group them into named ``ThemeVariant`` presets, and store them in a central ``Theme`` object that persists across launches and notifies observers when values change.

Define a theme type and a convenience accessor on `Theme`:

<!-- doc-check: docc-themekit-overview platform=ios -->
```swift
struct AppColors: ThemeExtension, ThemeOverridable {
    static let fallback = AppColors(tint: .systemBlue, colorScheme: .unspecified)
    @CodableColor var tint: UIColor          // or Color in SwiftUI targets
    var colorScheme: SystemColorScheme

    var props: [Prop<Self>] {[
        .init(\.tint),
    ]}
}

extension Theme {
    var colors: AppColors { value(AppColors.self) }
}
```

Then read, apply, or merge values through the store:

```swift
// Read
let tint = theme.colors.tint

// Replace with a preset
theme.apply(variant: AppColorsVariant.pink, for: .light)

// Overlay a single user-picked field
theme.merge(AppColors(tint: .systemRed, colorScheme: .unspecified))
```

To integrate with SwiftUI or UIKit observation, see ``ThemeKitSwiftUI`` and ``ThemeKitUIKit``.

## Topics

### Central Store

- ``Theme``

### Theme Data

- ``ThemeExtension``
- ``ThemeVariant``

### User-Customizable Fields

- ``ThemeOverridable``
- ``Prop``

### Color Scheme

- ``SystemColorScheme``
- ``CodableColor``

### Persistence

- ``ThemeStorage``
- ``ThemeKitError``
