import UIKit
import Flutter
import nb_navigation_flutter

@main
@objc class AppDelegate: FlutterAppDelegate, UINavigationControllerDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        customStyle()
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        window = UIWindow(frame: UIScreen.main.bounds)
        var navigationController = UINavigationController.init(rootViewController: controller)
        window?.rootViewController = navigationController
        navigationController.delegate = self
        window?.makeKeyAndVisible()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func customStyle() {
        NavStyleManager.customDayStyle = CustomDayStyle()
        NavStyleManager.customNightStyle = CustomNightStyle()
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        navigationController.navigationBar.isHidden = viewController.isKind(of: FlutterViewController.self)
    }
}
