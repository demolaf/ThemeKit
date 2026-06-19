import ThemeKit
import ThemeKitUIKit
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  private let theme = Theme()
  private var applier: ThemeApplier<AppColorsVariant>?

  func scene(
    _ scene: UIScene, willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else { return }

    let homeVC = HomeViewController(theme: theme)
    let nav = UINavigationController(rootViewController: homeVC)
    nav.navigationBar.prefersLargeTitles = true

    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = nav
    window.makeKeyAndVisible()
    self.window = window

    let applier = ThemeApplier(theme: theme, default: .default, available: AppColorsVariant.all)
    applier.onAppear()
    applier.onChangeOfThemeState()
    applier.onChangeOfSystemUserInterfaceStyle(window: window)
    self.applier = applier
  }
}
