# ``ThemeKitSwiftUI``

SwiftUI integration for ThemeKit — automatic theme application and `Color` persistence.

## Overview

``ThemeKitSwiftUI`` adds two things to a SwiftUI app:

**Theme application** — attach ``ThemeApplier`` to your root view via the `applyTheme(_:default:available:)` modifier. It handles first-launch defaults, follow-system mode, and forced color-scheme overrides so your view hierarchy always reflects the active theme.

```swift
@main
struct MyApp: App {
    let theme = Theme()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(theme)
                .applyTheme(theme, default: AppColorsVariant.default, available: AppColorsVariant.all)
        }
    }
}
```

**`Color` persistence** — `Color` gains `Codable` conformance in this module, so you can store `Color` properties directly in your `ThemeExtension` structs:

```swift
struct AppColors: ThemeExtension {
    var tint: Color
    var background: Color
    var colorScheme: SystemColorScheme

    static let fallback = AppColors(tint: .blue, background: .white, colorScheme: .unspecified)
}
```

Use `Color(hex:)` — not `Color(UIColor(hex:))` — in static stored property initializers to stay nonisolated under Swift 6.

## Topics

### Applying Themes

- ``ThemeApplier``
