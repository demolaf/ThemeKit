# ``ThemeKitSwiftUI``

SwiftUI integration for ThemeKit on iOS, macOS, and watchOS — automatic theme application and `Color` persistence.

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

## watchOS

On watchOS 10+, the modifier applies the active palette through the scoped SwiftUI environment. Because watchOS doesn't provide a system light/dark appearance setting, watch-only variants should use `.dark` as their canonical scheme and may provide the same palette for both required values.

ThemeKit's watchOS integration covers the main SwiftUI app. WatchKit interfaces, WidgetKit extensions, complications, and automatic iPhone–Watch synchronization are outside its scope; use a custom `ThemeStorage` when an app needs its own synchronization strategy.

## Topics

### Applying Themes

- ``ThemeApplier``
