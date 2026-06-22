#if canImport(UIKit)
import Testing
import ThemeKit
import UIKit

@testable import ThemeKitUIKit

@Suite("ThemeApplier Logic")
@MainActor
struct ThemeApplierTests {

  func makeApplier(
    theme: Theme,
    systemStyle: UIUserInterfaceStyle = .light
  ) -> ThemeApplier<TestVariant> {
    ThemeApplier(
      theme: theme,
      default: .default,
      available: TestVariant.all,
      systemStyleProvider: { systemStyle },
      applyInterfaceStyle: { _ in }
    )
  }

  // MARK: - handleAppear: first launch

  @Test("First launch with light system applies default light value")
  func firstLaunchLightAppliesDefaultLight() {
    let theme = Theme(storage: InMemoryStorage())
    let applier = makeApplier(theme: theme, systemStyle: .light)

    applier.handleAppear(userInterfaceStyle: .light)

    #expect(theme.testColors == TestVariant.default.light)
    #expect(theme.hasPersisted(TestColors.self))
  }

  @Test("First launch with dark system applies default dark value")
  func firstLaunchDarkAppliesDefaultDark() {
    let theme = Theme(storage: InMemoryStorage())
    let applier = makeApplier(theme: theme, systemStyle: .dark)

    applier.handleAppear(userInterfaceStyle: .dark)

    #expect(theme.testColors == TestVariant.default.dark)
  }

  // MARK: - handleAppear: follow-system on

  @Test("Follow-system on syncs to dark on appear")
  func followSystemSyncsToDarkOnAppear() {
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.default, for: .light)
    theme.followsSystem = true
    let applier = makeApplier(theme: theme)

    applier.handleAppear(userInterfaceStyle: .dark)

    #expect(theme.testColors == TestVariant.default.dark)
  }

  @Test("Follow-system on syncs to light on appear")
  func followSystemSyncsToLightOnAppear() {
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.default, for: .dark)
    theme.followsSystem = true
    let applier = makeApplier(theme: theme)

    applier.handleAppear(userInterfaceStyle: .light)

    #expect(theme.testColors == TestVariant.default.light)
  }

  @Test("Follow-system on preserves theme family on appear")
  func followSystemPreservesThemeFamilyOnAppear() {
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.alternate, for: .light)
    theme.followsSystem = true
    let applier = makeApplier(theme: theme)

    applier.handleAppear(userInterfaceStyle: .dark)

    #expect(theme.testColors == TestVariant.alternate.dark)
  }

  // MARK: - handleAppear: follow-system off (forced style)

  @Test("Follow-system off forces dark interface style on appear")
  func followSystemOffForcesDarkOnAppear() {
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.default, for: .dark)

    var captured: UIUserInterfaceStyle?
    let applier = ThemeApplier(
      theme: theme, default: .default, available: TestVariant.all,
      systemStyleProvider: { .light },
      applyInterfaceStyle: { captured = $0 }
    )

    applier.handleAppear(userInterfaceStyle: .light)

    #expect(captured == .dark)
  }

  @Test("Follow-system off forces light interface style on appear")
  func followSystemOffForcesLightOnAppear() {
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.alternate, for: .light)

    var captured: UIUserInterfaceStyle?
    let applier = ThemeApplier(
      theme: theme, default: .default, available: TestVariant.all,
      systemStyleProvider: { .dark },
      applyInterfaceStyle: { captured = $0 }
    )

    applier.handleAppear(userInterfaceStyle: .dark)

    #expect(captured == .light)
  }

  // MARK: - handleThemeChange

  @Test("Theme change with follow-system off forces interface style")
  func themeChangeAppliesForcedStyle() {
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.default, for: .dark)

    var captured: UIUserInterfaceStyle?
    let applier = ThemeApplier(
      theme: theme, default: .default, available: TestVariant.all,
      systemStyleProvider: { .light },
      applyInterfaceStyle: { captured = $0 }
    )

    applier.handleThemeChange()

    #expect(captured == .dark)
  }

  @Test("Theme change with follow-system on releases interface style override")
  func themeChangeWithFollowSystemReleasesOverride() {
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.default, for: .light)
    theme.followsSystem = true

    var captured: UIUserInterfaceStyle? = .dark
    let applier = ThemeApplier(
      theme: theme, default: .default, available: TestVariant.all,
      systemStyleProvider: { .light },
      applyInterfaceStyle: { captured = $0 }
    )

    applier.handleThemeChange()

    #expect(captured == nil)
  }

  // MARK: - handleSystemStyleChange

  @Test("System change to dark with follow-system on switches to dark variant")
  func systemChangeToDarkSwitchesTheme() {
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.default, for: .light)
    theme.followsSystem = true
    let applier = makeApplier(theme: theme)

    applier.handleSystemStyleChange(.dark)

    #expect(theme.testColors.tintHex == TestVariant.default.dark.tintHex)
    #expect(theme.testColors.backgroundHex == TestVariant.default.dark.backgroundHex)
  }

  @Test("System change to light with follow-system on switches to light variant")
  func systemChangeToLightSwitchesTheme() {
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.alternate, for: .dark)
    theme.followsSystem = true
    let applier = makeApplier(theme: theme)

    applier.handleSystemStyleChange(.light)

    #expect(theme.testColors.tintHex == TestVariant.alternate.light.tintHex)
  }

  @Test("System change preserves theme family")
  func systemChangePreservesThemeFamily() {
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.alternate, for: .light)
    theme.followsSystem = true
    let applier = makeApplier(theme: theme)

    applier.handleSystemStyleChange(.dark)

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

    applier.handleSystemStyleChange(.dark)

    #expect(theme.testColors == TestVariant.default.dark)
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

    applier.handleAppear(userInterfaceStyle: .light)

    #expect(theme.testColors == TestVariant.default.light)
  }

  @Test("Theme change with follow-system on resets values to variant defaults")
  func themeChangeWithFollowSystemResetsValues() {
    let theme = Theme(storage: InMemoryStorage())
    var custom = TestVariant.default.light
    custom.tintHex = 0xABCDEF
    theme.apply(custom)
    theme.activeVariantID = TestVariant.default.id
    theme.followsSystem = true

    let applier = makeApplier(theme: theme, systemStyle: .light)
    applier.handleThemeChange()

    #expect(theme.testColors == TestVariant.default.light)
  }

  @Test("System change ignored when follow-system off")
  func systemChangeIgnoredWhenFollowSystemOff() {
    let theme = Theme(storage: InMemoryStorage())
    theme.apply(variant: TestVariant.default, for: .light)
    let applier = makeApplier(theme: theme)

    applier.handleSystemStyleChange(.dark)

    #expect(theme.testColors == TestVariant.default.light)
  }
}
#endif
