# ThemeKit

A Swift package for managing light/dark theme variants in iOS apps. Handles first-launch defaults, system appearance sync, custom color overrides, and persistence — so your app code only has to describe what the theme looks like, not how it behaves.

Three library products:

| Product | Use when |
|---|---|
| `ThemeKit` | Core types only — building a custom UI layer |
| `ThemeKitSwiftUI` | SwiftUI apps |
| `ThemeKitUIKit` | UIKit apps |

---

## Requirements

- iOS 17+
- Swift 6

---

## Installation

In Xcode: **File → Add Package Dependencies**, enter the repository URL, then add the product that matches your target (`ThemeKitSwiftUI` or `ThemeKitUIKit`).

---

## Core Concepts

### 1. Define your colors — `ThemeExtension`

`ThemeExtension` is the type that holds your app's color tokens. It must be `Codable`, `Equatable`, and `Sendable`.

```swift
import ThemeKit

struct AppColors: ThemeExtension {
    var tintHex: Int
    var backgroundHex: Int
    var colorScheme: SystemColorScheme   // required by the protocol
    var isCustomDefined: Bool = false

    static let defaultValue = AppColors(
        tintHex: 0x8E44AD,
        backgroundHex: 0xFFFFFF,
        colorScheme: .light
    )

    // Called by theme.merge(_:) — lets you preserve user-customised fields
    // when the system color scheme changes.
    func merging(_ other: AppColors) -> AppColors {
        guard isCustomDefined else { return other }
        var result = other
        result.tintHex = tintHex
        result.backgroundHex = backgroundHex
        result.isCustomDefined = true
        return result
    }
}
```

### 2. Define your presets — `ThemeVariant`

`ThemeVariant` pairs a light and dark `ThemeExtension` value under a stable string ID.

```swift
struct AppColorsVariant: ThemeVariant {
    let id: String
    let light: AppColors
    let dark: AppColors

    static let `default` = AppColorsVariant(
        id: "default",
        light: AppColors(tintHex: 0x8E44AD, backgroundHex: 0xFFFFFF, colorScheme: .light),
        dark:  AppColors(tintHex: 0x9B59B6, backgroundHex: 0x1C0C26, colorScheme: .dark)
    )

    static let all: [AppColorsVariant] = [.default]
}
```

### 3. Add a convenience accessor — `Theme` extension

```swift
extension Theme {
    var appColors: AppColors { value(AppColors.self) }
}
```

---

## SwiftUI

### Setup

Attach `.applyTheme` at the root of your view hierarchy. Pass a default variant and the full list of available variants.

```swift
import ThemeKit
import ThemeKitSwiftUI

@main
struct MyApp: App {
    @State private var theme = Theme()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(theme)
                .applyTheme(theme, default: .default, available: AppColorsVariant.all)
        }
    }
}
```

### Reading colors

```swift
struct ContentView: View {
    @Environment(Theme.self) private var theme

    var body: some View {
        Text("Hello")
            .foregroundStyle(Color(uiColor: UIColor(hex: theme.appColors.tintHex)))
            .background(Color(uiColor: UIColor(hex: theme.appColors.backgroundHex)))
    }
}
```

### Writing colors

```swift
// Apply a preset (replaces current colors)
theme.apply(variant: AppColorsVariant.default, for: .dark)
theme.followsSystem = false

// Apply a custom color (preserves via merging on scheme changes)
var custom = theme.appColors
custom.tintHex = 0xFF0000
custom.isCustomDefined = true
theme.apply(custom)

// Follow system light/dark
theme.followsSystem = true
```

---

## UIKit

### Setup

Create a `ThemeApplier` in your `SceneDelegate` and wire up its three lifecycle hooks.

```swift
import ThemeKit
import ThemeKitUIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    let theme = Theme()
    private var themeApplier: ThemeApplier<AppColorsVariant>?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = ViewController(theme: theme)
        self.window = window
        window.makeKeyAndVisible()

        let applier = ThemeApplier(theme: theme, default: .default, available: AppColorsVariant.all)
        themeApplier = applier
        applier.onAppear()
        applier.onChangeOfThemeState()
        applier.onChangeOfSystemUserInterfaceStyle(window: window)
    }
}
```

### Reading colors

Observe `theme` with `withObservationTracking` and apply colors to your views directly.

```swift
private func observeTheme() {
    withObservationTracking {
        view.backgroundColor = theme.appColors.primaryBackgroundColor
        view.tintColor = theme.appColors.tintColor
    } onChange: { [weak self] in
        Task { @MainActor [weak self] in self?.observeTheme() }
    }
}
```

### Writing colors

The API is the same as SwiftUI — `Theme` is framework-agnostic.

```swift
theme.apply(variant: AppColorsVariant.default, for: .dark)
theme.followsSystem = false
```

---

## `Theme` API reference

| Method / Property | Description |
|---|---|
| `value(_ type:)` | Read the current stored value for an extension type |
| `apply(_ value:)` | Replace the stored value entirely |
| `merge(_ value:)` | Merge into the stored value via `merging(_:)` |
| `apply(variant:for:)` | Apply a variant's light or dark value and record its ID |
| `hasPersisted(_ type:)` | Returns `true` if a value has ever been stored for this type |
| `followsSystem` | Whether the theme mirrors the system light/dark appearance |
| `activeVariantID` | ID of the last applied variant |

---

## Running the tests

The package targets iOS, so tests must run on a simulator via `xcodebuild` rather than `swift test`.

```bash
xcodebuild test \
  -workspace .swiftpm/xcode/package.xcworkspace \
  -scheme ThemeKit-Package \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

To filter to a single test target, use `-only-testing`:

```bash
xcodebuild test \
  -workspace .swiftpm/xcode/package.xcworkspace \
  -scheme ThemeKit-Package \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing ThemeKitSwiftUITests
```

Available test targets: `ThemeKitTests`, `ThemeKitSwiftUITests`, `ThemeKitUIKitTests`.
