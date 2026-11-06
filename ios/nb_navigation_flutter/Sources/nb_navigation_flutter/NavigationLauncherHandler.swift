//
//  NavigationLauncherHandler.swift
//  nb_navigation_flutter
//
//  Created by qiuyu on 2023/7/5.
//

import Foundation
import Flutter
import NbmapNavigation
import NbmapCoreNavigation

class NavigationLauncherHandler: MethodChannelHandler {
    override init() {
        super.init()
        methodChannel = MethodChannelManager.shared.navigationChannel
    }
    
    override func handleMethodCallResult(call: FlutterMethodCall?, result: @escaping FlutterResult) {
        super.handleMethodCallResult(call: call, result: result)
        
        guard let call = call else {
            return
        }
        
        switch call.method {
        case MethodID.NAVIGATION_LAUNCH_NAVIGATION:
            guard let args = call.arguments as? [String : Any] else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing navigation configuration", details: nil))
                return
            }

            let (routes, routeIndex)  = Convert.convertNavigationRoutes(arguments: args)
            if routes.isEmpty || routeIndex == nil {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "No valid navigation route", details: nil))
                return
            }
            var enableDissolvedRoute = true
            var showsArrivalWaypointSheet = true
            var showSpeed = true
            var darkModeInTunnel = true

            if let config = args["launcherConfig"] as? [String : Any] {
                if let dissolvedRoute = config["enableDissolvedRouteLine"] as? Bool {
                    enableDissolvedRoute = dissolvedRoute
                }
                if let showArrivalSheet = config["showArriveDialog"] as? Bool {
                    showsArrivalWaypointSheet = showArrivalSheet
                }
                if let showSpeedometer = config["showSpeedometer"] as? Bool {
                    showSpeed = showSpeedometer
                }
                if let tunnelDarkMode = config["darkModeInTunnel"] as? Bool {
                    darkModeInTunnel = tunnelDarkMode
                }
            }
            
            let navigationOptions = Convert.convertNavigationOptions(args: args, routes: routes,index: routeIndex ?? 0)
            guard var viewController = UIApplication.shared.keyWindow?.rootViewController else {
                result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "No navigation presenter available", details: nil))
                return
            }
            while let presented = viewController.presentedViewController { viewController = presented }
            
            let navigationViewController = NavigationViewController(for: routes, routeIndex: routeIndex, navigationOptions: navigationOptions)
            navigationViewController.delegate = self
            navigationViewController.modalPresentationStyle = .fullScreen
            navigationViewController.routeLineTracksTraversal = enableDissolvedRoute
            navigationViewController.showsArrivalWaypointSheet = showsArrivalWaypointSheet
            navigationViewController.showsSpeed = showSpeed
            navigationViewController.usesNightStyleWhileInTunnel = darkModeInTunnel
            viewController.present(navigationViewController, animated: true)
            result(nil)
            break
            
        case MethodID.NAVIGATION_PREVIEW_NAVIGATION:
            guard var viewController = UIApplication.shared.keyWindow?.rootViewController else {
                result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "No preview presenter available", details: nil))
                return
            }
            while let presented = viewController.presentedViewController { viewController = presented }
            guard let args = call.arguments as? [String : Any] else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing preview configuration", details: nil))
                return
            }

            guard let route = Convert.convertDirectionsRoute(arguments: args) else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "No valid preview route", details: nil))
                return
            }

            var navigationModeStyle: NbmapNavigation.Style = NavStyleManager.customDayStyle
            
            if let mapStyleUrl = args["mapStyle"] as? String {
                guard let url = URL(string: mapStyleUrl) else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid preview map style URL", details: nil))
                    return
                }
                navigationModeStyle.mapStyleURL = url
            }
            
            let previewController = NavigationPreviewController(route: route,style: navigationModeStyle)
            if let navigation = viewController as? UINavigationController {
                navigation.pushViewController(previewController, animated: true)
            } else {
                viewController.present(ModalPreviewNavigationController(rootViewController: previewController), animated: true)
            }
            result(nil)
            break
            
        default:
            break
        }
    }
    

}

/// A modal root cannot be popped. Give it a close action owned by its container.
final class ModalPreviewNavigationController: UINavigationController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topViewController?.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close, target: self, action: #selector(closePreview))
    }

    @objc private func closePreview() {
        dismiss(animated: true)
    }
}

extension NavigationLauncherHandler : NavigationViewControllerDelegate {
    public func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
        let routeProgress = navigationViewController.navigationService.routeProgress
        let shouldRefetchRoute = shouldReFetchRoute(routeProgress)
        let remainingWaypoints = routeProgress.remainingWaypoints.count
        methodChannel?.invokeMethod(MethodID.NAVIGATION_ON_NAVIGATION_EXIT, arguments: [
            "shouldRefreshRoute": shouldRefetchRoute,
            "remainingWaypoints": remainingWaypoints
        ] as [String : Any])
        
        navigationViewController.dismiss(animated: true, completion: nil)
    }
    
    func shouldReFetchRoute(_ routeProgress: RouteProgress) -> Bool {
        let distanceRemaining = routeProgress.distanceRemaining
        let stepRemaining = routeProgress.currentLegProgress.remainingSteps.count
        if distanceRemaining > 250 {
            return true
        } else {
            return distanceRemaining > 50 && stepRemaining >= 2
        }
    }
}
