# API Reference

## ThemeKit (Core)

---

### `Theme`

`@Observable @MainActor public final class Theme`

The central store for all theme values. Create one instance per scene and pass it down — no singleton.

**Initializers**

```swift
Theme()
// Backed by UserDefaults.standard. Calls synchronize() after every write.

Theme(suiteName: String)
// Backed by a named UserDefaults suite.
// Required for any second Theme instance in the same app to avoid corrupting
// the shared "themeKit.metadata" key.

Theme(storage: any ThemeStorage)
// Backed by a custom storage (tests, Keychain, etc.)
```

**Properties**

| Property | Type | Description |
|---|---|---|
| `followsSystem` | `Bool` | When `true`, the applier tracks the system appearance. Setting it to `false` locks to the active extension's `colorScheme`. Persisted across launches. |
| `activeVariantID` | `String?` | The `id` of the last applied `ThemeVariant`. Written by `apply(variant:for:)`, read by `ThemeApplier` on relaunch to restore the correct preset. Persisted across launches. |

**Methods**

```swift
func value<T: ThemeExtension>(_ type: T.Type) -> T
// Returns the stored value for T, or T.fallback if nothing has been written yet.

func apply<T: ThemeExtension>(_ value: T)
// Replaces the stored value for T entirely.

func merge<T: ThemeExtension & ThemeOverridable>(_ value: T)
// Overlays the props fields from value onto the stored value, then sets followsSystem = false.
// Use this when the user customises a single field (e.g. accent color picker).

func apply<V: ThemeVariant>(variant: V, for scheme: SystemColorScheme)
// Applies the light or dark value from variant, records variant.id as activeVariantID,
// and sets followsSystem = false.

func hasPersisted<T: ThemeExtension>(_ type: T.Type) -> Bool
// Returns true if a value for T has ever been written to storage.
// Used by ThemeApplier to detect first launch.
```

---

### `ThemeExtension`

`public protocol ThemeExtension: Codable, Equatable, Sendable`

Adopt this to define a block of theme values your app carries — colors, typography, spacing, etc. Register it on `Theme` via an extension:

```swift
extension Theme {
    var colors: AppColors { value(AppColors.self) }
}
```

**Requirements**

```swift
static var extensionKey: String { get }
// Stable storage key. Defaults to the type name. Override if you rename the type.

static var fallback: Self { get }
// Returned by Theme before any value has been applied.

var colorScheme: SystemColorScheme { get }
// The light/dark appearance this value prefers.
// ThemeApplier reads this to override the window's interface style.
```

---

### `ThemeOverridable`

`public protocol ThemeOverridable`

Conform alongside `ThemeExtension` when individual fields should be user-overridable (e.g. an accent color picker) while the rest of the preset remains intact.

**Requirements**

```swift
var props: [Prop<Self>] { get }
// The fields eligible for per-field user override.
// Drives merging(_:) and compare(to:).
```

**Provided**

```swift
func merging(_ other: Self) -> Self
// Starts from self, overlays the props fields from other, returns the result.

func compare(to preset: Self) -> Bool
// Returns true if any props field on self differs from preset.
// Use to show/hide a "Reset to Preset" button.
```

---

### `Prop<T>`

`public struct Prop<T>: Equatable`

A type-erased wrapper around a single writable key path on `T`. Declare one per user-customisable field inside `ThemeOverridable.props`.

```swift
public init<V: Equatable>(_ kp: WritableKeyPath<T, V>)
```

```swift
// Example
var props: [Prop<Self>] {[
    .init(\.tint),
    .init(\.background),
]}
```

---

### `ThemeVariant`

`public protocol ThemeVariant: Sendable`

A named light/dark pair of `ThemeExtension` values representing a preset.

**Requirements**

```swift
var id: String { get }         // Stable identifier — used for relaunch restoration.
var light: Value { get }       // Value used in light environments.
var dark: Value { get }        // Value used in dark environments.
```

**Provided**

```swift
func value(for scheme: SystemColorScheme) -> Value
// Returns light or dark depending on scheme.
```

---

### `ThemeStorage`

`public protocol ThemeStorage`

Abstracts the persistence backend. `UserDefaults` conforms out of the box.

```swift
func data(forKey key: String) -> Data?
func set(_ value: Any?, forKey key: String)
```

`extension UserDefaults: ThemeStorage` — no additional implementation needed.

---

### `SystemColorScheme`

`public enum SystemColorScheme: Int, Codable, Sendable`

A `Codable` light/dark enum for use in `ThemeExtension` conformances (use instead of `UIUserInterfaceStyle`, which isn't `Codable`).

| Case | Raw Value |
|---|---|
| `.unspecified` | `0` |
| `.light` | `1` |
| `.dark` | `2` |

```swift
var uiUserInterfaceStyle: UIUserInterfaceStyle
// The corresponding UIKit style.

init(_ style: UIUserInterfaceStyle)
// Converts from UIKit.
```

---

### `CodableColor`

`@propertyWrapper public struct CodableColor: Codable, Equatable, @unchecked Sendable`

Stores a `UIColor` as a hex integer for `Codable` synthesis. Use on `UIColor` properties inside UIKit `ThemeExtension` types.

```swift
public init(wrappedValue: UIColor)
public var wrappedValue: UIColor
```

```swift
struct AppColors: ThemeExtension {
    @CodableColor var tint: UIColor
    @CodableColor var background: UIColor
}
```

---

### `UIColor` extensions

```swift
extension UIColor {
    convenience init(hex: Int, alpha: Double = 1.0)
    // UIColor(hex: 0xFF2D55) or UIColor(hex: 0xFF2D55, alpha: 0.5)

    var hex: Int
    // RGB components packed as a hex integer. Alpha is dropped.
}
```

---

## ThemeKitUIKit

---

### `ThemeApplier<V>`

`@MainActor public final class ThemeApplier<V: ThemeVariant>`

Applies a `ThemeVariant` to all UIKit windows and keeps them in sync with the active theme and system interface style. Create one per scene in your `SceneDelegate`.

**Initializer**

```swift
public init(theme: Theme, default variant: V, available: [V])
```

**Properties**

```swift
public var cancellables: Set<AnyCancellable>
// Holds Combine subscriptions. Keep this alive for the lifetime of the scene.
```

**Methods**

```swift
public func onAppear()
// Call once when the scene first appears. Applies the correct initial theme.

public func onChangeOfThemeState()
// Call once to begin observing theme mutations for the scene's lifetime.

public func onChangeOfSystemUserInterfaceStyle(window: UIWindow?)
// Subscribes to trait-collection changes on window so system light/dark
// switches are forwarded to the theme when followsSystem is true.
```

**Usage**

```swift
// SceneDelegate
let applier = ThemeApplier(theme: theme, default: AppColorsVariant.default, available: AppColorsVariant.all)
applier.onAppear()
applier.onChangeOfThemeState()
applier.onChangeOfSystemUserInterfaceStyle(window: window)
```

---

## ThemeKitSwiftUI

---

### `ThemeApplier<V>`

`@MainActor public struct ThemeApplier<V: ThemeVariant>: ViewModifier`

Applies a `ThemeVariant` to the SwiftUI view hierarchy and keeps it in sync with the active theme and system color scheme. Use via the `applyTheme` view modifier rather than directly.

```swift
public init(theme: Theme, default variant: V, available: [V])
```

---

### `View.applyTheme(_:default:available:)`

```swift
@MainActor public func applyTheme<V: ThemeVariant>(
    _ theme: Theme,
    default variant: V,
    available: [V]
) -> some View
```

Attaches a `ThemeApplier` to the view. Call this once at the root of your view hierarchy.

```swift
ContentView()
    .applyTheme(theme, default: AppColorsVariant.default, available: AppColorsVariant.all)
```

---

### `Color` extensions

```swift
extension Color: @retroactive Codable
// Encodes/decodes as a hex integer via cgColor?.components.
// Enables Color properties directly in ThemeExtension structs.

extension Color {
    public init(hex: Int)
    // Color(hex: 0xFF2D55)
    // Uses Color(red:green:blue:) — safe in nonisolated static lets.
}
```

---

### `SystemColorScheme` extensions

```swift
extension SystemColorScheme {
    public init(_ colorScheme: ColorScheme)
    // Converts SwiftUI ColorScheme → SystemColorScheme.
}

extension ColorScheme {
    public init?(_ scheme: SystemColorScheme)
    // Converts SystemColorScheme → ColorScheme. Returns nil for .unspecified.
}

extension UIUserInterfaceStyle {
    public init(_ colorScheme: ColorScheme)
    // Converts SwiftUI ColorScheme → UIUserInterfaceStyle.
}
```

---

### `UIColor` extension

```swift
extension UIColor {
    public var color: Color { get }
    // Bridges UIColor → SwiftUI Color via Color(uiColor:).
}
```
