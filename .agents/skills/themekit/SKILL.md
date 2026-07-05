---
name: themekit
description: >
  Public API guide for the ThemeKit Swift package (github.com/demolaf/ThemeKit) —
  Theme, ThemeExtension, ThemeVariant, ThemeStorage, and the SwiftUI/UIKit
  ThemeAppliers. Use when adding ThemeKit as a dependency, defining an app's
  theme model, wiring up light/dark variants, or debugging theme persistence,
  color storage, or Swift 6 concurrency issues involving Theme, ThemeExtension,
  ThemeVariant, or ThemeApplier.
---

# ThemeKit

A small, dependency-free theming package for UIKit and SwiftUI apps. One
`Theme` store holds app-defined `ThemeExtension` values (colors, fonts,
anything `Codable`), persists them, and pushes fine-grained `@Observable`
updates to SwiftUI and UIKit.

## Install

```swift
.package(url: "https://github.com/demolaf/ThemeKit.git", from: "1.0.0")
```

Pick the product(s) you need:

- `ThemeKit` — core (`Theme`, `ThemeExtension`, `ThemeVariant`, `ThemeStorage`). No UI dependency.
- `ThemeKitSwiftUI` — adds the `applyTheme(_:default:available:)` view modifier and `Color: Codable`.
- `ThemeKitUIKit` — adds the UIKit `ThemeApplier` class and `@CodableColor`.

## Core concepts

- **`Theme`** — `@Observable @MainActor final class`. Central store. Create one instance per app (or per isolated section) and pass it down; no singleton.
- **`ThemeExtension`** — a protocol your own struct conforms to (`Codable & Equatable & Sendable`). Holds the actual theme data (colors, fonts, spacing — anything). Requires `static var fallback: Self` and `var colorScheme: SystemColorScheme`.
- **`ThemeVariant`** — a named light/dark pair of one `ThemeExtension` type. Requires `id`, `light`, `dark`.
- **`ThemeStorage`** — protocol abstracting persistence. `UserDefaults` conforms out of the box; implement it yourself for Keychain, CloudKit, or an in-memory test double.
- **`ThemeApplier`** — separate SwiftUI (`ViewModifier`) and UIKit (`class`) implementations that apply a `ThemeVariant` on first launch, follow system appearance, or force an override, and keep the window/view hierarchy in sync.

## Define a theme

SwiftUI — store `Color` directly:

<!-- doc-check: skill-colors-swiftui platform=macos -->
```swift
import ThemeKit
import ThemeKitSwiftUI

struct AppColors: ThemeExtension {
    var tint: Color
    var background: Color
    var colorScheme: SystemColorScheme

    static let fallback = AppColors(tint: .blue, background: .white, colorScheme: .light)
}
```

UIKit — wrap `UIColor` in `@CodableColor`:

<!-- doc-check: skill-colors-uikit platform=ios -->
```swift
import ThemeKit

struct AppColors: ThemeExtension {
    @CodableColor var tint: UIColor
    @CodableColor var background: UIColor
    var colorScheme: SystemColorScheme

    static let fallback = AppColors(tint: .systemBlue, background: .white, colorScheme: .light)
}
```

Both encode to the same hex-int format, so storage is interchangeable between targets. `SwiftUI.Color` gets retroactive `Codable` conformance from `ThemeKitSwiftUI` (hex int via `cgColor?.components`); UIKit properties use the `@CodableColor` property wrapper — `UIColor` itself cannot be made `Codable` directly (see Pitfalls).

Give `Theme` a named accessor:

```swift
extension Theme {
    var colors: AppColors { value(AppColors.self) }
}
```

Define a light/dark pair:

```swift
struct AppColorsVariant: ThemeVariant {
    let id: String
    let light: AppColors
    let dark: AppColors

    static let `default` = AppColorsVariant(id: "default", light: .fallback, dark: .darkFallback)
    static let all: [AppColorsVariant] = [.default]
}
```

## Wire it up

```swift
let theme = Theme()                       // UserDefaults.standard
let theme = Theme(suiteName: "com.x.y")   // isolated UserDefaults suite
let theme = Theme(storage: myStorage)     // custom backend (tests, Keychain, ...)
```

**SwiftUI** — apply once near the root of the view hierarchy:

```swift
ContentView()
    .applyTheme(theme, default: AppColorsVariant.default, available: AppColorsVariant.all)
```

**UIKit** — create one `ThemeApplier` per scene/window and drive its lifecycle hooks:

```swift
let applier = ThemeApplier(theme: theme, default: .default, available: AppColorsVariant.all, window: window)
applier.onAppear()                          // apply correct initial theme
applier.onChangeOfThemeState()              // start observing theme changes
applier.onChangeOfSystemUserInterfaceStyle()// track system light/dark changes
// applier.onDisappear()                    // reset window override when the scene goes away
```

## Read and write

```swift
theme.colors.tint                                    // read (registers fine-grained observation)
theme.apply(AppColors(tint: .red, background: theme.colors.background, colorScheme: theme.colors.colorScheme))  // replace the stored value entirely
theme.apply(variant: AppColorsVariant.default, for: .dark)  // apply a variant's light/dark value, sets followsSystem = false
theme.followsSystem = true                           // resume following system appearance
```

For partial user customization (e.g. a color well that overrides just the accent, leaving the rest of the preset intact), conform to `ThemeOverridable` and declare which fields are user-editable:

<!-- doc-check: skill-overridable platform=macos -->
```swift
import ThemeKit
import ThemeKitSwiftUI

struct AppColors: ThemeExtension, ThemeOverridable {
    var tint: Color
    var background: Color
    var colorScheme: SystemColorScheme
    static let fallback = AppColors(tint: .blue, background: .white, colorScheme: .light)

    var props: [Prop<Self>] { [.init(\.tint)] }  // only `tint` is user-overridable
}
```

```swift
theme.merge(AppColors(tint: newColor, background: theme.colors.background, colorScheme: theme.colors.colorScheme))
// merges just the `props` fields from the incoming value and sets followsSystem = false

theme.colors.compare(to: preset)  // true if any `props` field differs from `preset` — drive a "Reset" button with this
```

## Pitfalls

- **Two `Theme()` instances sharing `UserDefaults.standard` corrupt each other's metadata.** Both write to the same `"themeKit.metadata"` key (`followsSystem` / `activeVariantID`). Always pass a unique `suiteName:` for a second `Theme` in the same app.
- **`UIColor` cannot conform to `Codable` via extension** — it's a non-final class and `required init(from:)` can't be added retroactively. Use `@CodableColor` on the property instead of trying to make `UIColor` itself `Codable`.
- **Swift 6 static stored properties are always `nonisolated`**, even under module-wide `@MainActor` isolation. `ThemeExtension.fallback` and any static variant presets must not call `@MainActor` initializers.
- **`Color(hex:)` must build via `Color(red:green:blue:)`**, not `Color(UIColor(hex:))` — `Color.init(_ uiColor:)` is `@MainActor`, which fails to compile in a `nonisolated` static property under Swift 6 strict concurrency.
- **`theme.apply(_:)` replaces the whole value; `theme.merge(_:)` overlays only `props` fields.** Reach for `merge` when only some fields should be user-editable — using `apply` there silently discards untouched fields on the next read if the caller only populated a subset.
- **Reads register observation dependencies per extension type**, not globally — `theme.colors` and `theme.christmas` (say) are tracked independently, so an observer reading only `theme.colors` won't re-run when an unrelated extension changes.
