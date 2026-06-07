import Testing
import UIKit
@testable import ThemeKit

@Suite("Theme")
@MainActor
struct ThemeTests {

    let storage = InMemoryStorage()

    // MARK: - Initial state

    @Test("Fresh Theme returns defaultValue for unset extension")
    func freshThemeReturnsDefaultValue() {
        let theme = Theme(storage: storage)
        #expect(theme.testColors == TestColors.defaultValue)
    }

    @Test("followsSystem defaults to false")
    func followsSystemDefaultsFalse() {
        let theme = Theme(storage: storage)
        #expect(theme.followsSystem == false)
    }

    // MARK: - apply

    @Test("apply stores value and can be read back")
    func applyStoresValue() {
        let theme = Theme(storage: storage)
        let newColors = TestColors(tintHex: 0x0000FF, backgroundHex: 0x000000, colorScheme: .dark)
        theme.apply(newColors)
        #expect(theme.testColors == newColors)
    }

    @Test("apply(variant:for:) applies light value for light style")
    func applyVariantAppliesLightForLightStyle() {
        let theme = Theme(storage: storage)
        theme.apply(variant: TestVariant.default, for: .light)
        #expect(theme.testColors == TestVariant.default.light)
    }

    @Test("apply(variant:for:) applies dark value for dark style")
    func applyVariantAppliesDarkForDarkStyle() {
        let theme = Theme(storage: storage)
        theme.apply(variant: TestVariant.default, for: .dark)
        #expect(theme.testColors == TestVariant.default.dark)
    }

    @Test("apply(variant:for:) stores variant id")
    func applyVariantStoresID() {
        let theme = Theme(storage: storage)
        theme.apply(variant: TestVariant.alternate, for: .light)
        #expect(theme.activeVariantID == TestVariant.alternate.id)
    }

    // MARK: - merge

    @Test("merge calls merging on existing value")
    func mergeCallsMerging() {
        let theme = Theme(storage: storage)
        var custom = TestColors.defaultValue
        custom.tintHex = 0xABCDEF
        custom.isCustomDefined = true
        theme.apply(custom)

        let incoming = TestColors(tintHex: 0x111111, backgroundHex: 0x222222, colorScheme: .dark)
        theme.merge(incoming)

        #expect(theme.testColors.tintHex == 0xABCDEF)
        #expect(theme.testColors.backgroundHex == 0x222222)
        #expect(theme.testColors.isCustomDefined == true)
    }

    @Test("apply replaces value entirely, ignoring merging")
    func applyIgnoresMerging() {
        let theme = Theme(storage: storage)
        var custom = TestColors.defaultValue
        custom.isCustomDefined = true
        theme.apply(custom)

        let replacement = TestColors(tintHex: 0x111111, backgroundHex: 0x222222, colorScheme: .dark)
        theme.apply(replacement)

        #expect(theme.testColors == replacement)
    }

    // MARK: - hasPersisted

    @Test("hasPersisted returns false before first apply")
    func hasPersistedFalseBeforeApply() {
        let theme = Theme(storage: storage)
        #expect(theme.hasPersisted(TestColors.self) == false)
    }

    @Test("hasPersisted returns true after apply")
    func hasPersistedTrueAfterApply() {
        let theme = Theme(storage: storage)
        theme.apply(TestColors.defaultValue)
        #expect(theme.hasPersisted(TestColors.self) == true)
    }

    // MARK: - Persistence

    @Test("Extension value persists across Theme instances")
    func extensionValuePersistsAcrossInstances() {
        let theme = Theme(storage: storage)
        let colors = TestColors(tintHex: 0xABCDEF, backgroundHex: 0x123456, colorScheme: .dark)
        theme.apply(colors)

        let restored = Theme(storage: storage)
        #expect(restored.testColors == colors)
    }

    @Test("followsSystem persists across Theme instances")
    func followsSystemPersistsAcrossInstances() {
        let theme = Theme(storage: storage)
        theme.followsSystem = true

        let restored = Theme(storage: storage)
        #expect(restored.followsSystem == true)
    }

    @Test("activeVariantID persists across Theme instances")
    func activeVariantIDPersistsAcrossInstances() {
        let theme = Theme(storage: storage)
        theme.apply(variant: TestVariant.alternate, for: .light)

        let restored = Theme(storage: storage)
        #expect(restored.activeVariantID == TestVariant.alternate.id)
    }

    // MARK: - Observation

    @Test("apply triggers observation")
    func applyTriggersObservation() async {
        let theme = Theme(storage: storage)
        let (stream, cont) = AsyncStream<TestColors>.makeStream()

        withObservationTracking {
            _ = theme.testColors
        } onChange: {
            Task { @MainActor in
                cont.yield(theme.testColors)
            }
        }

        let newColors = TestColors(tintHex: 0x0000FF, backgroundHex: 0x000000, colorScheme: .dark)
        theme.apply(newColors)

        let received = await stream.first { @Sendable _ in true }
        #expect(received == newColors)
    }

    @Test("Identical apply does not trigger observation")
    func identicalApplyDoesNotTriggerObservation() {
        let theme = Theme(storage: storage)
        let colors = TestColors(tintHex: 0x0000FF, backgroundHex: 0x000000, colorScheme: .dark)
        theme.apply(colors)

        nonisolated(unsafe) var changeCount = 0
        withObservationTracking {
            _ = theme.testColors
        } onChange: {
            changeCount += 1
        }

        theme.apply(colors)
        #expect(changeCount == 0)

        let different = TestColors(tintHex: 0x111111, backgroundHex: 0x000000, colorScheme: .dark)
        theme.apply(different)
        #expect(changeCount == 1)
    }
}
