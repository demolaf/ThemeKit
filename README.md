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

### 1. Define your theme — `ThemeExtension`

`ThemeExtension` is the type that holds your app's theme values. It must be `Codable`, `Equatable`, and `Sendable`. It can carry any codable value — colors, font names, image asset names, spacing constants, or anything else your design system needs.

#### Colors (SwiftUI)

`ThemeKitSwiftUI` makes `Color` directly `Codable`, so you can store it without any conversion at the call site.

```swift
import ThemeKit
import ThemeKitSwiftUI

struct AppColors: ThemeExtension, ThemeOverridable {
    var tint: Color
    var background: Color
    var colorScheme: SystemColorScheme   // required by the protocol

    static let defaultValue = AppColors(
        tint: Color(hex: 0x8E44AD),
        background: Color(hex: 0xFFFFFF),
        colorScheme: .light
    )

    // Declare which fields the user can individually override.
    // theme.merge(_:) copies only these fields from the incoming value;
    // compare(to:) uses them to detect whether any differ from a preset.
    var props: [Prop<Self>] {[
        .init(\.tint),
    ]}
}
```

#### Colors (UIKit)

Use the `@CodableColor` property wrapper for `UIColor` properties. The call site reads `theme.colors.tint` and gets a `UIColor` directly — no conversion needed.

```swift
import ThemeKit

struct AppColors: ThemeExtension, ThemeOverridable {
    @CodableColor var tint: UIColor
    @CodableColor var background: UIColor
    var colorScheme: SystemColorScheme

    static let defaultValue = AppColors(
        tint: UIColor(hex: 0x8E44AD),
        background: UIColor(hex: 0xFFFFFF),
        colorScheme: .light
    )

    var props: [Prop<Self>] {[
        .init(\.tint),
    ]}
}
```

Both `Color` and `@CodableColor` encode to the same hex integer format, so storage written by one target can be read by the other.

#### Fonts, images, and icons

`ThemeExtension` isn't limited to colors. Store font names and image asset names as `String`, then add computed properties to derive the richer types your views consume.

```swift
import ThemeKit
import ThemeKitSwiftUI

struct AppTheme: ThemeExtension, ThemeOverridable {
    var accent: Color
    var backgroundImageName: String   // asset catalog image name
    var iconImageName: String         // asset catalog image name
    var fontName: String              // empty string = system font
    var colorScheme: SystemColorScheme

    // Computed — not stored, so no Codable involvement
    var titleFont: Font {
        fontName.isEmpty
            ? .largeTitle.weight(.bold)
            : .custom(fontName, size: 34, relativeTo: .largeTitle)
    }

    var bodyFont: Font {
        fontName.isEmpty
            ? .body
            : .custom(fontName, size: 17, relativeTo: .body)
    }

    static let defaultValue = AppTheme(
        accent: Color(hex: 0xCC0000),
        backgroundImageName: "bg-light",
        iconImageName: "icon-default",
        fontName: "Georgia",
        colorScheme: .light
    )

    var props: [Prop<Self>] {[
        .init(\.accent),
        .init(\.backgroundImageName),
        .init(\.iconImageName),
    ]}
}
```

### 2. Define your presets — `ThemeVariant`

`ThemeVariant` pairs a light and dark `ThemeExtension` value under a stable string ID.

```swift
struct AppThemeVariant: ThemeVariant {
    let id: String
    let name: String   // not a ThemeVariant requirement — add any extra fields you need
    let light: AppTheme
    let dark: AppTheme

    static let classic = AppThemeVariant(
        id: "classic",
        name: "Classic",
        light: AppTheme(accent: Color(hex: 0xCC0000), backgroundImageName: "bg-classic-light", iconImageName: "icon-classic", fontName: "Georgia",  colorScheme: .light),
        dark:  AppTheme(accent: Color(hex: 0xFF6B6B), backgroundImageName: "bg-classic-dark",  iconImageName: "icon-classic", fontName: "Georgia",  colorScheme: .dark)
    )

    static let minimal = AppThemeVariant(
        id: "minimal",
        name: "Minimal",
        light: AppTheme(accent: Color(hex: 0x1A5276), backgroundImageName: "bg-minimal-light", iconImageName: "icon-minimal", fontName: "",         colorScheme: .light),
        dark:  AppTheme(accent: Color(hex: 0x7FD4F4), backgroundImageName: "bg-minimal-dark",  iconImageName: "icon-minimal", fontName: "",         colorScheme: .dark)
    )

    static let all: [AppThemeVariant] = [.classic, .minimal]
}
```

### 3. Add convenience accessors — `Theme` extensions

Each `ThemeExtension` type needs one accessor. Multiple types coexist in a single `Theme` instance under separate keys:

```swift
extension Theme {
    var appColors: AppColors { value(AppColors.self) }
    var appTheme: AppTheme   { value(AppTheme.self) }
}
```

---

## User-customizable fields — `ThemeOverridable`

`ThemeOverridable` is an independent protocol types adopt alongside `ThemeExtension` when some fields should be individually overridable by the user (e.g. an accent color set via a color picker) while other fields remain controlled by the active preset.

```swift
struct AppColors: ThemeExtension, ThemeOverridable {
    var tint: Color
    var background: Color
    var colorScheme: SystemColorScheme

    static let defaultValue = AppColors(...)

    var props: [Prop<Self>] {[
        .init(\.tint),   // tint is user-customisable; background always comes from the preset
    ]}
}
```

`props` drives two operations: `merge` (which fields to copy in) and `compare(to:)` (which fields to check for drift from a preset).

### `theme.merge(_ value:)`

Overlays only the `props` fields from `value` onto the currently stored value. Non-listed fields stay from the stored base. Use this when the user changes a field via a color picker — it keeps all other preset fields in place.

```swift
var custom = theme.colors
custom.tint = newColor      // tint is in props
theme.merge(custom)         // stored value: base preset + custom tint; background unchanged
```

### `theme.apply(variant:for:)`

Full replacement — all fields come from the preset. `props` fields are not preserved. Use this when the user selects a preset.

```swift
theme.apply(variant: .ocean, for: .light)
// All fields, including tint, now come from the ocean preset
```

### `compare(to:)`

Returns `true` if any `props` field on `self` differs from the same field on `preset`. Use this to decide whether to show a "Reset to Preset" button.

```swift
let activeVariant = AppColorsVariant.all.first { $0.id == theme.activeVariantID } ?? .default
let preset = activeVariant.value(for: theme.colors.colorScheme)
if theme.colors.compare(to: preset) {
    // tint has been customised — show the Reset button
}
```

### Full picker example

```swift
// SwiftUI
Section("Custom") {
    ColorPicker("Tint", selection: tintBinding)

    let activeVariant = AppColorsVariant.all.first { $0.id == theme.activeVariantID } ?? .default
    let preset = activeVariant.value(for: theme.colors.colorScheme)
    if theme.colors.compare(to: preset) {
        Button("Reset to Preset", role: .destructive) {
            theme.apply(variant: activeVariant, for: theme.colors.colorScheme)
        }
    }
}

private var tintBinding: Binding<Color> {
    Binding(
        get: { theme.colors.tint },
        set: { newColor in
            var custom = theme.colors
            custom.tint = newColor
            theme.merge(custom)
        }
    )
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
                .applyTheme(theme, default: .classic, available: AppThemeVariant.all)
        }
    }
}
```

### Reading theme values

Read colors, fonts, and images through the typed accessor on `Theme`.

```swift
struct ContentView: View {
    @Environment(Theme.self) private var theme

    var body: some View {
        VStack {
            // Background image from the asset catalog
            Image(theme.appTheme.backgroundImageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // Icon from the asset catalog
            Image(theme.appTheme.iconImageName)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)

            // Themed font and color
            Text("Hello")
                .font(theme.appTheme.titleFont)
                .foregroundStyle(theme.appTheme.accent)

            Text("Subtitle")
                .font(theme.appTheme.bodyFont)
        }
    }
}
```

### Writing theme values

```swift
// Select a preset — records the variant ID and sets followsSystem to false
theme.apply(variant: AppThemeVariant.classic, for: .dark)

// Apply a custom accent color — only the fields in overrideProps are overlaid;
// other fields (backgroundImageName, iconImageName) stay from the stored value.
// Also sets followsSystem to false.
var custom = theme.appTheme
custom.accent = Color(hex: 0xFF0000)
theme.merge(custom)

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
    private var themeApplier: ThemeApplier<AppThemeVariant>?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = ViewController(theme: theme)
        self.window = window
        window.makeKeyAndVisible()

        let applier = ThemeApplier(theme: theme, default: .classic, available: AppThemeVariant.all)
        themeApplier = applier
        applier.onAppear()
        applier.onChangeOfThemeState()
        applier.onChangeOfSystemUserInterfaceStyle(window: window)
    }
}
```

### Reading theme values

Observe `theme` with `withObservationTracking` and apply values to your views directly.

```swift
private func observeTheme() {
    withObservationTracking {
        // Colors via @CodableColor — already UIColor, no conversion
        view.backgroundColor = theme.appColors.background
        view.tintColor = theme.appColors.tint

        // Image asset name
        heroImageView.image = UIImage(named: theme.appTheme.backgroundImageName)

        // Font name stored as String, converted at the call site
        titleLabel.font = UIFont(name: theme.appTheme.fontName, size: 34)
            ?? .preferredFont(forTextStyle: .largeTitle)
    } onChange: { [weak self] in
        Task { @MainActor [weak self] in self?.observeTheme() }
    }
}
```

### Writing theme values

The API is the same as SwiftUI — `Theme` is framework-agnostic.

```swift
// Select a preset — records the variant ID and sets followsSystem to false
theme.apply(variant: AppThemeVariant.classic, for: .dark)

// Apply a custom accent color via merge
var custom = theme.appTheme
custom.accent = UIColor(hex: 0xFF0000)
theme.merge(custom)
```

---

## `Theme` API reference

| Method / Property | Description |
|---|---|
| `value(_ type:)` | Read the current stored value for an extension type |
| `apply(_ value:)` | Replace the stored value entirely |
| `merge(_ value:)` | Overlay the `overrideProps` fields from `value` onto the stored value; sets `followsSystem` to `false` |
| `apply(variant:for:)` | Apply a variant's light or dark value, record its ID, and set `followsSystem` to `false` |
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
