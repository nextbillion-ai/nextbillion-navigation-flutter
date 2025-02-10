//
//  EmbeddedNavigationView.swift
//  nb_navigation_flutter
//
//  Created by qiuyu on 2024/6/25.
//

import Foundation
import Flutter
import NbmapNavigation
import NbmapCoreNavigation
import UIKit
import Foundation
import UserNotifications
import AVFoundation
import Nbmap

public class EmbeddedNavigationView : NSObject, FlutterPlatformView, FlutterStreamHandler
{
    
    var frame: CGRect
    var viewId: Int64 = 0
    
    var messenger: FlutterBinaryMessenger
    var channel: FlutterMethodChannel
    var eventChannel: FlutterEventChannel
    var navigationController: NavigationViewController?
    var _eventSink: FlutterEventSink? = nil
    
    
    init(messenger: FlutterBinaryMessenger, frame: CGRect, viewId: Int64, args: Any?) {
        self.frame = frame
        self.viewId = viewId
        
        self.messenger = messenger
        
        self.channel = FlutterMethodChannel(name: "flutter_nb_navigation/\(viewId)", binaryMessenger: messenger)
        self.eventChannel = FlutterEventChannel(name: "flutter_nb_navigation/\(viewId)/events", binaryMessenger: messenger)
        
        
        super.init()
        
        self.channel.setMethodCallHandler { [weak self] in self?.onMethodCall(methodCall: $0, result: $1) }
        self.eventChannel.setStreamHandler(self)
        
        guard let args = args as? [String : Any] else {
            return
        }
        
        let routes = Convert.convertNavigationOptions(arguments: args)
        if routes.isEmpty {
            return
        }
        var enableDissolvedRoute = true
        var showSpeed = true

        if let config = args["launcherConfig"] as? [String : Any] {
            if let dissolvedRoute = config["enableDissolvedRouteLine"] as? Bool {
                enableDissolvedRoute = dissolvedRoute
            }
            if let showSpeedometer = config["showSpeedometer"] as? Bool {
                showSpeed = showSpeedometer
            }
        }
        
        let navigationOptions = Convert.convertNavigationOptions(args: args, routes: routes)
        navigationController = NavigationViewController(for: routes, navigationOptions: navigationOptions)
        navigationController?.delegate = self
//        navigationController?.navigationService?.delegate = self
        navigationController?.routeLineTracksTraversal = enableDissolvedRoute
        
        navigationController?.showsArrivalWaypointSheet = false
        navigationController?.showsSpeed = showSpeed
        if let navigationView = navigationController?.view {
            let insets = navigationView.safeAreaInsets
            if let label = (navigationView.subviews.first) {
                
                label.center = CGPoint(x: navigationView.center.x, y: navigationView.center.y + insets.top)
            }
        }
        
        
    }
    
    
    
    public func view() -> UIView {
        return navigationController?.view ?? UIView()
    }
    
    func onMethodCall(methodCall: FlutterMethodCall, result: @escaping FlutterResult) {
        switch methodCall.method {
        case "stopNavigation":
            
            navigationController = nil;
            result(nil)
            break
            
        default:
            break
        }
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        _eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        _eventSink = nil
        return nil
    }
    
}

extension EmbeddedNavigationView: NavigationViewControllerDelegate {
    
    public func navigationViewController(_ navigationViewController: NavigationViewController, didUpdate progress: RouteProgress, with location: CLLocation, rawLocation: CLLocation) {
        var resultMap = [String: Any?]()
        
        resultMap["location"] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude]
        
        resultMap["distanceRemaining"] = progress.distanceRemaining
        resultMap["durationRemaining"] = progress.durationRemaining
        resultMap["currentLegIndex"] = progress.legIndex
        resultMap["currentStepIndex"] = progress.currentLegProgress.stepIndex
        resultMap["distanceTraveled"] = progress.distanceTraveled
        resultMap["fractionTraveled"] = progress.fractionTraveled
        resultMap["remainingWaypoints"] = progress.remainingWaypoints.count
        resultMap["isFinalLeg"] = progress.isFinalLeg
        _eventSink?(resultMap)
    }
    
    public func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
        channel.invokeMethod("onNavigationCancelling", arguments: nil)
    }
    
    public func navigationViewController(_ navigationViewController: NavigationViewController, willRerouteFrom location: CLLocation) {
        var resultMap = [String: Any?]()
        resultMap["location"] = [
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude]
        channel.invokeMethod("willRerouteFromLocation", arguments: resultMap)
    }
    
    public func navigationViewController(_ navigationViewController: NavigationViewController, didRerouteAlong route: Route) {
        channel.invokeMethod("onRerouteAlong", arguments: route.json)
    }
    
    public func navigationViewController(_ navigationViewController: NavigationViewController, didFailToRerouteWith error: any Error) {
        channel.invokeMethod("onRerouteFailure", arguments: error.localizedDescription)
    }
    
    public func navigationViewController(_ navigationViewController: NavigationViewController, didArriveAt waypoint: Waypoint) {
        let waypointIndex = navigationViewController.navigationService.routeProgress.legIndex
        let waypointLocation = waypoint.coordinate
        var resultMap = [String: Any?]()
    
        resultMap["location"] = [
                    "latitude": waypointLocation.latitude,
                    "longitude": waypointLocation.longitude]
    
        resultMap["arrivedWaypointIndex"] = waypointIndex
        channel.invokeMethod("onArriveAtWaypoint", arguments: resultMap)
    }
    
}
