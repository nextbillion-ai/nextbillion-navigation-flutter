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
import NBTurf

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
            guard let args = call.arguments as? String,
                  let routeOptions = Convert.convertRouteRequestParams(arguments: args) else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid route parameters", details: nil))
                return
            }
            requestRoute(with: routeOptions, call: call, result: result)
        case MethodID.NAVIGATION_FIND_SELECTED_ROUTE:
            guard let args = call.arguments as? [String : Any] else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing route selection arguments", details: nil))
                return
            }
            guard let clicked = args["clickPoint"] as? [Double],
                  let coordinates = args["coordinates"] as? [[[Double]]],
                  Self.validCoordinate(clicked),
                  coordinates.allSatisfy({ $0.allSatisfy(Self.validCoordinate) }) else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid route selection coordinates", details: nil))
                return
            }
            
            let tapCoordinate = CLLocationCoordinate2D(latitude: clicked[0], longitude: clicked[1])
            let candidates = coordinates.enumerated().compactMap { index, line -> (Int, Double)? in
                guard line.count >= 2 else { return nil }
                let shape = line.map { CLLocationCoordinate2D(latitude: $0[0], longitude: $0[1]) }
                guard let closest = NBPolyline(shape).closestCoordinate(to: tapCoordinate) else { return nil }
                let distance = closest.coordinate.distance(to: tapCoordinate)
                return distance < 5000 ? (index, distance) : nil
            }
            result(candidates.min { $0.1 < $1.1 }?.0)
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
                
                let durationSymbol = RouteDurationSymbol.init(duration: timeDuration, isPrimary: isPrimaryRoute, durationSymbolType: NavigationMapView.DurationSymbolType.routeDuration)
                
                if let symbolImage = durationSymbol.screenshotImage() {
                    result(symbolImage.pngData())
                } else { result(nil) }
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
                } else { result(nil) }
            } else {
                result(nil)
            }
            break

        default:
            break
        }
    }

    private static func validCoordinate(_ value: [Double]) -> Bool {
        value.count >= 2 && value[0].isFinite && value[1].isFinite &&
            (-90...90).contains(value[0]) && (-180...180).contains(value[1])
    }

    func requestRoute(with options: RouteOptions, call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        NBNavigation.fetchRoute(options: options, completion: { routes, source, error in
            DispatchQueue.main.async {
                if let error {
                    let failure = NavigationBridgeError.flutterError(error)
                    result(["message": failure.message ?? "Route request failed", "errorCode": (error as NSError).code,
                            "errorDetails": ["code": failure.code, "nativeDetails": failure.details as Any]])
                    return
                }
                guard let routes, !routes.isEmpty else {
                    result(["message": "No routes returned", "errorCode": -1])
                    return
                }
                do {
                    let serialized = try routes.map(NavigationRouteCodec.encode)
                    result(["routeResult": serialized,
                            "routeOptions": Convert.convertRouteOptionsToMap(routeOptions: options),
                            "routeSource": source == .offline ? "offline" : "online"])
                } catch {
                    result(FlutterError(code: "ROUTE_SERIALIZATION_FAILED", message: error.localizedDescription, details: nil))
                }
            }
        })
    }
}
