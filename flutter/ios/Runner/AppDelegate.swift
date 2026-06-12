import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  // An explicit, pre-warmed engine. The default template uses the *implicit* engine, whose
  // platform task runner is still null when FlutterViewController.viewDidLoad runs; on a
  // ProMotion device that crashes in -[VSyncClient initWithTaskRunner:callback:] when the app
  // is launched untethered (release builds, tapping the icon). Running the engine here, before
  // any view loads, gives the view controller a fully-initialized engine. See flutter/flutter#183900.
  lazy var flutterEngine = FlutterEngine(name: "io.livevoice.example.flutter")

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    flutterEngine.run()
    GeneratedPluginRegistrant.register(with: flutterEngine)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
