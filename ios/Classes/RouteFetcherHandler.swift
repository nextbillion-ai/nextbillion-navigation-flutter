//
//  RouteFetcherHandler.swift
//  nb_navigation_flutter
//
//  Created by qiuyu on 2023/7/5.
//

import Foundation
import Flutter
import NbmapNavigation
import NbmapCoreNavigation
import Turf

class RouteFetcherHandler: MethodChannelHandler {
    let dateComponentsFormatter = DateComponentsFormatter()

    override init() {
        super.init()
        methodChannel = MethodChannelManager.shared.navigationChannel
        
        dateComponentsFormatter.allowedUnits = [.day, .hour, .minute]
        dateComponentsFormatter.unitsStyle = .brief
    }
    
    override func handleMethodCallResult(call: FlutterMethodCall?, result: @escaping FlutterResult) {
        super.handleMethodCallResult(call: call, result: result)
        
        guard let call = call else {
            return
        }
        
        switch call.method {
        case MethodID.NAVIGATION_FETCH_ROUTE:
            guard let args = call.arguments as? String else {
                return
            }
            if let routeOptions = Convert.convertRouteRequestParams(arguments: args) {
                requestRoute(with: routeOptions, call: call, result: result)
            }
        case MethodID.NAVIGATION_FIND_SELECTED_ROUTE:
            guard let args = call.arguments as? [String : Any] else {
                return
            }
            guard let clicked = args["clickPoint"] as? [Double],
                  let coordinates = args["coordinates"] as? [[[Double]]] else {
                return
            }
            
            let tapCoordinate = CLLocationCoordinate2D(latitude: clicked[0], longitude: clicked[1])
            var lines: [[CLLocationCoordinate2D]] = []
            for line in coordinates {
                var coordinates: [CLLocationCoordinate2D] = []
                for coordinate in line {
                    let coord = CLLocationCoordinate2D(latitude: coordinate[0], longitude: coordinate[1])
                    coordinates.append(coord)
                }
                lines.append(coordinates)
            }
            let closest = lines.sorted { (left, right) -> Bool in
                //existance has been assured through use of filter.
                let leftLine = Polyline(left)
                let rightLine = Polyline(right)
                let leftDistance = leftLine.closestCoordinate(to: tapCoordinate)!.distance
                let rightDistance = rightLine.closestCoordinate(to: tapCoordinate)!.distance
                
                return leftDistance < rightDistance
            }
            let candidates = closest.filter {
                let closestCoordinate = Polyline($0).closestCoordinate(to: tapCoordinate)!.coordinate
                return closestCoordinate.distance(to: tapCoordinate) < 5000
            }
            if !candidates.isEmpty, let routeIndex = lines.firstIndex(of: candidates.first!) {
                result(routeIndex)
            }
        case MethodID.NAVIGATION_GET_FORMATTED_ROUTE_DURATION:
            guard let arguments = call.arguments as? [String: Any] else {
                result("")
                return
            }
            if let timeDuration = arguments["duration"] as? Double {
                var durationText = ""
                if let hardcodedTime = self.dateComponentsFormatter.string(from: 61), timeDuration < 60 {
                    durationText = String.localizedStringWithFormat(NSLocalizedString("LESS_THAN", bundle: .main, value: "<%@", comment: "Format string for a short distance or time less than a minimum threshold; 1 = duration remaining"), hardcodedTime)
                } else {
                    durationText = (self.dateComponentsFormatter.string(from: TimeInterval(timeDuration)))!
                }
                result(durationText)
            } else {
                result("")
            }
            break
            
        case MethodID.NAVIGATION_CAPTURE_ROUTE_DURATION_SYMBOL:
            guard let arguments = call.arguments as? [String: Any] else {
                result(nil)
                return
            }
            if let timeDuration = arguments["duration"] as? Double, let isPrimaryRoute = arguments["isPrimaryRoute"] as? Bool {
                
                let durationSymbol = RouteDurationSymbol.init(duration: timeDuration, isPrimary: isPrimaryRoute, durationSymbolType: NavigationMapView.DurationSymbolType.ROUTE_DURATION)
                
                if let symbolImage = durationSymbol.screenshotImage() {
                    result(symbolImage.pngData())
                }
                result(nil)
            } else {
                result(nil)
            }
            break
            
        case MethodID.NAVIGATION_CAPTURE_ROUTE_WAY_POINTS:
            guard let arguments = call.arguments as? [String: Any] else {
                result(nil)
                return
            }
            if let waypointIndex = arguments["waypointIndex"] as? Int {
                
                let indexString = String(waypointIndex)
                let circularView = WayPointSymbol(frame: CGRect(x: 0, y: 0, width: 28, height: 28), labelText: indexString)
                if let circularImage = circularView.captureScreenshot() {
                    result(circularImage.pngData())
                }
                result(nil)
            } else {
                result(nil)
            }
            break

        default:
            break
        }
    }

    func requestRoute(with options: RouteOptions, call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        Directions.shared.calculate(options, completionHandler: {(potentialRoutes, potentialError) in
            if let error = potentialError {
                result(["message": error.toastError(), "errorCode": error.code])
            }
            
            guard let routes = potentialRoutes else { return }
            
            let routeResult = routes.map { route in
                return route.json
            }
            let routeOptions = Convert.convertRouteOptionsToMap(routeOptions: options)
            var args: [String: Any] = [:]
            args["routeResult"] = routeResult
            args["routeOptions"] = routeOptions
            result(args)
        })
    }
    
}
