# Changelog

## [0.2.1] — 2026-06-23

### Fixed

- Lowered `swift-tools-version` from 6.3 to 6.0 so the package resolves on Swift 6.0, 6.1, and 6.2 toolchains

## [0.2.0] — 2026-06-22

### Added

- macOS 14+ support — `ThemeKit` and `ThemeKitSwiftUI` now compile and run on macOS; `ThemeKitUIKit` remains iOS-only
- `ThemeKitSwiftUI.ThemeApplier` uses `NSWindow.appearance` on macOS to force the window appearance, matching the `UIWindow.overrideUserInterfaceStyle` behaviour on iOS
- `SystemColorScheme.uiUserInterfaceStyle` and `SystemColorScheme.init(_ style:)` are now conditionally compiled on UIKit platforms only
- `UIColor(hex:)`, `UIColor.hex`, and `CodableColor` are now conditionally compiled on UIKit platforms only
- macOS test run added to CI (`swift test --arch arm64`) alongside the existing iOS Simulator run

### Changed

- `Package.swift` platforms updated to `[.iOS(.v17), .macOS(.v14)]`

## [0.1.0] — 2026-06-21

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
