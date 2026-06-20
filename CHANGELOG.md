# Changelog

## [0.1.0] — 2026-06-20

Initial release.

### Added

- `Theme` — `@Observable @MainActor` central store backed by `UserDefaults`. Supports custom `ThemeStorage` backends for testing or alternative persistence (Keychain, CloudKit, etc.)
- `ThemeExtension` protocol — define any `Codable & Equatable & Sendable` struct as a block of theme values (colors, fonts, spacing, image names, etc.)
- `ThemeVariant` protocol — pair a light and dark `ThemeExtension` value under a stable ID for preset-based theming and relaunch restoration
- `ThemeOverridable` protocol and `Prop<T>` — declare per-field user overrides; drives `Theme.merge(_:)` and `compare(to:)` for detecting drift from a preset
- `SystemColorScheme` — `Codable` light/dark enum bridging `UIUserInterfaceStyle` and SwiftUI `ColorScheme`
- `CodableColor` property wrapper — stores `UIColor` as a hex integer for `Codable` synthesis in UIKit `ThemeExtension` types
- `UIColor(hex:alpha:)` and `UIColor.hex` — hex integer convenience API
- **ThemeKitSwiftUI**: `ThemeApplier` `ViewModifier` and `.applyTheme(_:default:available:)` view modifier; retroactive `Color: Codable` conformance encoding as hex integer; `Color(hex:)` initializer; `SystemColorScheme` ↔ `ColorScheme` bridging
- **ThemeKitUIKit**: `ThemeApplier` class with `onAppear()`, `onChangeOfThemeState()`, and `onChangeOfSystemUserInterfaceStyle(window:)` lifecycle hooks; Combine-based trait change publisher
- Three appearance modes across both appliers: `.firstLaunch` (applies default variant), `.followingSystem` (tracks system light/dark), `.forced` (locks to the active extension's `colorScheme`)
- Full test coverage for `Theme`, both `ThemeApplier` implementations, `CodableColor`, and hex round-trips
