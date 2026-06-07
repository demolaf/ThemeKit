import Testing
import SwiftUI
@testable import ThemeKitSwiftUI
import ThemeKit

@Suite("ThemeApplier Logic")
@MainActor
struct ThemeApplierTests {

    func makeApplier(
        theme: Theme,
        applyColorScheme: @escaping (ColorScheme?) -> Void = { _ in }
    ) -> ThemeApplier<TestVariant> {
        ThemeApplier(theme: theme, default: .default, available: TestVariant.all, applyColorScheme: applyColorScheme)
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

        applier.handleThemeChange()

        #expect(appliedScheme == .dark)
    }

    @Test("Theme change with follow-system on releases color scheme override")
    func themeChangeWithFollowSystemReleasesOverride() {
        let theme = Theme(storage: InMemoryStorage())
        theme.apply(variant: TestVariant.default, for: .light)
        theme.followsSystem = true

        var appliedScheme: ColorScheme? = .dark
        let applier = makeApplier(theme: theme, applyColorScheme: { appliedScheme = $0 })

        applier.handleThemeChange()

        #expect(appliedScheme == nil)
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

    @Test("System change uses merge — custom tint is preserved")
    func systemChangePreservesCustomValues() {
        let theme = Theme(storage: InMemoryStorage())
        var custom = TestVariant.default.light
        custom.tintHex = 0xABCDEF
        custom.isCustomDefined = true
        theme.apply(custom)
        theme.activeVariantID = TestVariant.default.id
        theme.followsSystem = true
        let applier = makeApplier(theme: theme)

        applier.handleSystemColorSchemeChange(.dark)

        #expect(theme.testColors.tintHex == 0xABCDEF)
        #expect(theme.testColors.backgroundHex == TestVariant.default.dark.backgroundHex)
        #expect(theme.testColors.isCustomDefined == true)
    }

    @Test("System change ignored when follow-system off")
    func systemChangeIgnoredWhenFollowSystemOff() {
        let theme = Theme(storage: InMemoryStorage())
        theme.apply(variant: TestVariant.default, for: .light)
        let applier = makeApplier(theme: theme)

        applier.handleSystemColorSchemeChange(.dark)

        #expect(theme.testColors == TestVariant.default.light)
    }

    @Test("Follow-system on appear preserves custom tint")
    func followSystemOnAppearPreservesCustomTint() {
        let theme = Theme(storage: InMemoryStorage())
        theme.apply(variant: TestVariant.default, for: .light)
        theme.followsSystem = true
        var custom = theme.testColors
        custom.tintHex = 0xABCDEF
        custom.isCustomDefined = true
        theme.apply(custom)
        let applier = makeApplier(theme: theme)

        // Simulates relaunch: onAppear fires while followsSystem is true
        applier.handleAppear(systemColorScheme: .light)

        #expect(theme.testColors.tintHex == 0xABCDEF)
        #expect(theme.testColors.backgroundHex == TestVariant.default.light.backgroundHex)
    }
}
