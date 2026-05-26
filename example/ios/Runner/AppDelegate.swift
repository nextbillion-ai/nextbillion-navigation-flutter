import UIKit
import Flutter
import CoreLocation
import nb_navigation_flutter

@main
@objc class AppDelegate: FlutterAppDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    private let permissionChannelName = "nb_navigation_flutter_example/permissions"
    private var locationManager: CLLocationManager?
    private var pendingPermissionResult: FlutterResult?

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
        configurePermissionChannel(controller: controller)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func customStyle() {
        NavStyleManager.customDayStyle = CustomDayStyle()
        NavStyleManager.customNightStyle = CustomNightStyle()
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        navigationController.navigationBar.isHidden = viewController.isKind(of: FlutterViewController.self)
    }

    private func configurePermissionChannel(controller: FlutterViewController) {
        let permissionChannel = FlutterMethodChannel(
            name: permissionChannelName,
            binaryMessenger: controller.binaryMessenger
        )

        permissionChannel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else {
                result(false)
                return
            }

            switch call.method {
            case "requestLocationPermission":
                self.requestLocationPermission(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func requestLocationPermission(result: @escaping FlutterResult) {
        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            result(true)
        case .restricted, .denied:
            result(false)
        case .notDetermined:
            if pendingPermissionResult != nil {
                result(
                    FlutterError(
                        code: "permission_request_in_progress",
                        message: "Location permission request is already in progress.",
                        details: nil
                    )
                )
                return
            }
            pendingPermissionResult = result
            let manager = CLLocationManager()
            manager.delegate = self
            locationManager = manager
            manager.requestWhenInUseAuthorization()
        @unknown default:
            result(false)
        }
    }

    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let result = pendingPermissionResult else {
            return
        }
        let status = manager.authorizationStatus
        resolvePermissionResult(result: result, status: status)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard let result = pendingPermissionResult else {
            return
        }
        resolvePermissionResult(result: result, status: status)
    }

    private func resolvePermissionResult(result: FlutterResult, status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            result(true)
            pendingPermissionResult = nil
            locationManager = nil
        case .denied, .restricted:
            result(false)
            pendingPermissionResult = nil
            locationManager = nil
        case .notDetermined:
            break
        @unknown default:
            result(false)
            pendingPermissionResult = nil
            locationManager = nil
        }
    }
}
