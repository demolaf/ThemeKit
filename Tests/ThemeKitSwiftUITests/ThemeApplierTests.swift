import SwiftUI
import Testing
import ThemeKit

@testable import ThemeKitSwiftUI

@Suite("ThemeApplier Logic")
@MainActor
struct ThemeApplierTests {

  func makeApplier(
    theme: Theme,
    applyColorScheme: @escaping (ColorScheme?) -> Void = { _ in }
  ) -> ThemeApplier<TestVariant> {
    ThemeApplier(
      theme: theme, default: .default, available: TestVariant.all,
      applyColorScheme: applyColorScheme)
  }

  // MARK: - handleAppear: first launch

  @Test("First launch with light system sets default light value")
  func firstLaunchLightSetsDefaultLight() {
    let theme = Theme(storage: InMemoryStorage())
    let applier = makeApplier(theme: theme)

    applier.handleAppear(systemColorScheme: .light)

    #expect(theme.testColors == TestVariant.default.light)
    #expect(theme.hasPersisted(TestColors.self))
  }

  @Test("First launch with dark system sets default dark value")
  func firstLaunchDarkSetsDefaultDark() {
    let theme = Theme(storage: InMemoryStorage())
    let applier = makeApplier(theme: theme)

    applier.handleAppear(systemColorScheme: .dark)

    #expect(theme.testColors == TestVariant.default.dark)
  }

  // MARK: - handleAppear: follow-system on

  @Test("Follow-system on syncs to dark on appear")
  func followSystemSyncsToDarkOnAppear() {
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.default, for: .light)
    theme.followsSystem = true
    let applier = makeApplier(theme: theme)

    applier.handleAppear(systemColorScheme: .dark)

    #expect(theme.testColors == TestVariant.default.dark)
  }

  @Test("Follow-system on syncs to light on appear")
  func followSystemSyncsToLightOnAppear() {
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.default, for: .dark)
    theme.followsSystem = true
    let applier = makeApplier(theme: theme)

    applier.handleAppear(systemColorScheme: .light)

    #expect(theme.testColors == TestVariant.default.light)
  }

  @Test("Follow-system on preserves theme family on appear")
  func followSystemPreservesThemeFamilyOnAppear() {
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.alternate, for: .light)
    theme.followsSystem = true
    let applier = makeApplier(theme: theme)

    applier.handleAppear(systemColorScheme: .dark)

    #expect(theme.testColors == TestVariant.alternate.dark)
  }

  // MARK: - handleAppear: follow-system off

  @Test("Follow-system off forces dark scheme on appear")
  func followSystemOffForcesDarkSchemeOnAppear() {
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.default, for: .dark)

    var appliedScheme: ColorScheme?
    let applier = makeApplier(theme: theme, applyColorScheme: { appliedScheme = $0 })

    applier.handleAppear(systemColorScheme: .light)

    #expect(appliedScheme == .dark)
  }

  @Test("Follow-system off forces light scheme on appear")
  func followSystemOffForcesLightSchemeOnAppear() {
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.alternate, for: .light)

    var appliedScheme: ColorScheme?
    let applier = makeApplier(theme: theme, applyColorScheme: { appliedScheme = $0 })

    applier.handleAppear(systemColorScheme: .dark)

    #expect(appliedScheme == .light)
  }

  // MARK: - handleThemeChange

  @Test("Theme change with follow-system off forces color scheme")
  func themeChangeAppliesForcedScheme() {
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.default, for: .dark)

    var appliedScheme: ColorScheme?
    let applier = makeApplier(theme: theme, applyColorScheme: { appliedScheme = $0 })

    applier.handleThemeChange(systemColorScheme: .light)

    #expect(appliedScheme == .dark)
  }

  @Test("Theme change with follow-system on releases color scheme override")
  func themeChangeWithFollowSystemReleasesOverride() {
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.default, for: .light)
    theme.followsSystem = true

    var appliedScheme: ColorScheme? = .dark
    let applier = makeApplier(theme: theme, applyColorScheme: { appliedScheme = $0 })

    applier.handleThemeChange(systemColorScheme: .light)

    #expect(appliedScheme == nil)
  }

  @Test("Theme change with follow-system on resets values to variant defaults")
  func themeChangeWithFollowSystemResetsValues() {
    let theme = Theme(storage: InMemoryStorage())
    var custom = TestVariant.default.light
    custom.tintHex = 0xABCDEF
    theme.apply(custom)
    theme.activeVariantID = TestVariant.default.id
    theme.followsSystem = true

    let applier = makeApplier(theme: theme)
    applier.handleThemeChange(systemColorScheme: .light)

    #expect(theme.testColors == TestVariant.default.light)
  }

  // MARK: - handleSystemColorSchemeChange

  @Test("System change to dark with follow-system on switches to dark variant")
  func systemChangeToDarkSwitchesTheme() {
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.default, for: .light)
    theme.followsSystem = true
    let applier = makeApplier(theme: theme)

    applier.handleSystemColorSchemeChange(.dark)

    #expect(theme.testColors.tintHex == TestVariant.default.dark.tintHex)
    #expect(theme.testColors.backgroundHex == TestVariant.default.dark.backgroundHex)
  }

  @Test("System change to light with follow-system on switches to light variant")
  func systemChangeToLightSwitchesTheme() {
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.alternate, for: .dark)
    theme.followsSystem = true
    let applier = makeApplier(theme: theme)

    applier.handleSystemColorSchemeChange(.light)

    #expect(theme.testColors.tintHex == TestVariant.alternate.light.tintHex)
  }

  @Test("System change preserves theme family")
  func systemChangePreservesThemeFamily() {
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.alternate, for: .light)
    theme.followsSystem = true
    let applier = makeApplier(theme: theme)

    applier.handleSystemColorSchemeChange(.dark)

    #expect(theme.activeVariantID == TestVariant.alternate.id)
    #expect(theme.testColors.tintHex == TestVariant.alternate.dark.tintHex)
  }

  @Test("System change to dark resets values to dark variant defaults")
  func systemChangeToDarkResetsCustomValues() {
    let theme = Theme(storage: InMemoryStorage())
    var custom = TestVariant.default.light
    custom.tintHex = 0xABCDEF
    theme.apply(custom)
    theme.activeVariantID = TestVariant.default.id
    theme.followsSystem = true
    let applier = makeApplier(theme: theme)

    applier.handleSystemColorSchemeChange(.dark)

    #expect(theme.testColors == TestVariant.default.dark)
  }

  @Test("System change ignored when follow-system off")
  func systemChangeIgnoredWhenFollowSystemOff() {
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.default, for: .light)
    let applier = makeApplier(theme: theme)

    applier.handleSystemColorSchemeChange(.dark)

    #expect(theme.testColors == TestVariant.default.light)
  }

  @Test("Follow-system on appear resets values to variant defaults")
  func followSystemOnAppearResetsValues() {
    let theme = Theme(storage: InMemoryStorage())
    var custom = TestVariant.default.light
    custom.tintHex = 0xABCDEF
    theme.apply(custom)
    theme.activeVariantID = TestVariant.default.id
    theme.followsSystem = true
    let applier = makeApplier(theme: theme)

    applier.handleAppear(systemColorScheme: .light)

    #expect(theme.testColors == TestVariant.default.light)
  }
}
