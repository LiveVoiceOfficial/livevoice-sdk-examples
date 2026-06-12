import Flutter
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else { return }

    // Build the FlutterViewController around the pre-warmed engine from AppDelegate rather than
    // letting the storyboard instantiate a bare (implicit-engine) one. This is the other half of
    // the flutter/flutter#183900 fix: the engine is already running, so its task runner is live by
    // the time the view controller loads on a ProMotion device.
    let engine = (UIApplication.shared.delegate as? AppDelegate)?.flutterEngine
    let controller = engine.map { FlutterViewController(engine: $0, nibName: nil, bundle: nil) }
      ?? FlutterViewController(project: nil, nibName: nil, bundle: nil)

    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = controller
    self.window = window
    window.makeKeyAndVisible()
  }
}
