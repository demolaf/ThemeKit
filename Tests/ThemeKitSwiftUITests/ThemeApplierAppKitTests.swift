#if canImport(AppKit)
import AppKit
import SwiftUI
import Testing
import ThemeKit

@testable import ThemeKitSwiftUI

@Suite("ThemeApplier AppKit appearance")
@MainActor
struct ThemeApplierAppKitTests {

  // MARK: - Forced scheme

  @Test("Forced dark sets NSApplication.shared.appearance to darkAqua")
  func forcedDarkSetsNSAppAppearance() {
    defer { NSApplication.shared.appearance = nil }
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.default, for: .dark)

    let applier = ThemeApplier(theme: theme, default: .default, available: TestVariant.all)
    applier.handleAppear(systemColorScheme: .light)

    #expect(NSApplication.shared.appearance?.name == .darkAqua)
  }

  @Test("Forced light sets NSApplication.shared.appearance to aqua")
  func forcedLightSetsNSAppAppearance() {
    defer { NSApplication.shared.appearance = nil }
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.default, for: .light)

    let applier = ThemeApplier(theme: theme, default: .default, available: TestVariant.all)
    applier.handleAppear(systemColorScheme: .dark)

    #expect(NSApplication.shared.appearance?.name == .aqua)
  }

  // MARK: - Follow-system

  @Test("Follow-system on theme change clears NSApplication.shared.appearance")
  func followSystemClearsNSAppAppearance() {
    defer { NSApplication.shared.appearance = nil }
    NSApplication.shared.appearance = NSAppearance(named: .darkAqua)

    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.default, for: .light)
    theme.followsSystem = true

    let applier = ThemeApplier(theme: theme, default: .default, available: TestVariant.all)
    applier.handleThemeChange(systemColorScheme: .light)

    #expect(NSApplication.shared.appearance == nil)
  }

  @Test("Switching from forced to follow-system clears NSApplication.shared.appearance")
  func switchToFollowSystemClearsAppearance() {
    defer { NSApplication.shared.appearance = nil }
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.default, for: .dark)

    let applier = ThemeApplier(theme: theme, default: .default, available: TestVariant.all)
    applier.handleAppear(systemColorScheme: .light)
    #expect(NSApplication.shared.appearance?.name == .darkAqua)

    theme.followsSystem = true
    applier.handleThemeChange(systemColorScheme: .light)

    #expect(NSApplication.shared.appearance == nil)
  }

  // MARK: - System colour scheme change

  @Test("System scheme change with follow-system on does not force NSApplication.shared.appearance")
  func systemSchemeChangeWithFollowSystemDoesNotForceAppearance() {
    defer { NSApplication.shared.appearance = nil }
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.default, for: .light)
    theme.followsSystem = true

    let applier = ThemeApplier(theme: theme, default: .default, available: TestVariant.all)
    applier.handleSystemColorSchemeChange(.dark)

    #expect(NSApplication.shared.appearance == nil)
  }
}
#endif
