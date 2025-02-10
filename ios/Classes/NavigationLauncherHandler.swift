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
                return
            }

            let routes = Convert.convertNavigationOptions(arguments: args)
            if routes.isEmpty {
                return
            }
            var enableDissolvedRoute = true
            var showsArrivalWaypointSheet = true
            var showSpeed = true

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
            }
            
            let navigationOptions = Convert.convertNavigationOptions(args: args, routes: routes)
            let viewController = UIApplication.shared.keyWindow?.rootViewController
            let navigationViewController = NavigationViewController(for: routes, navigationOptions: navigationOptions)
            navigationViewController.delegate = self
            navigationViewController.modalPresentationStyle = .fullScreen
            navigationViewController.routeLineTracksTraversal = enableDissolvedRoute
            navigationViewController.showsArrivalWaypointSheet = showsArrivalWaypointSheet
            navigationViewController.showsSpeed = showSpeed
            viewController?.present(navigationViewController, animated: true)
            break
            
        case MethodID.NAVIGATION_PREVIEW_NAVIGATION:
            let viewController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
            guard let args = call.arguments as? [String : Any] else {
                return
            }

            guard let route = Convert.convertDirectionsRoute(arguments: args) else {
                return
            }

            let previewController = NavigationPreviewController(route: route)
            viewController?.pushViewController(previewController, animated: true)
            break
            
        default:
            break
        }
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
