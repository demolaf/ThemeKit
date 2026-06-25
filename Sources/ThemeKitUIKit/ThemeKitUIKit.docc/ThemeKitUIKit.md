# ``ThemeKitUIKit``

UIKit integration for ThemeKit — window-level theme application driven by Combine and observation.

## Overview

``ThemeKitUIKit`` provides a ``ThemeApplier`` class that applies a `ThemeVariant` to a `UIWindow` and keeps it synchronized with the active theme and system interface style.

Create one applier per window scene in your scene delegate, then call the three lifecycle methods:

```swift
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var applier: ThemeApplier<AppColorsVariant>?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let theme = Theme()
        let applier = ThemeApplier(
            theme: theme,
            default: .default,
            available: AppColorsVariant.all,
            window: window
        )

        applier.onAppear()
        applier.onChangeOfThemeState()
        applier.onChangeOfSystemUserInterfaceStyle()

        self.window = window
        self.applier = applier
        window.makeKeyAndVisible()
    }
}
```

Observe the theme in view controllers using `withObservationTracking`:

```swift
private func observeTheme() {
    withObservationTracking {
        updateColors(theme.colors)
    } onChange: { [weak self] in
        Task { @MainActor [weak self] in self?.observeTheme() }
    }
}
```

## Topics

### Applying Themes

- ``ThemeApplier``
