//
//  Convert.swift
//  nb_navigation_flutter
//
//  Created by qiuyu on 2023/2/28.
//

import Foundation
import NbmapNavigation
import NbmapCoreNavigation

public class Convert {
    static let navigationMode = [
        "car": NBNavigationMode.car,
        "truck": NBNavigationMode.truck,
        "bike": NBNavigationMode.bike,
        "motorcycle": NBNavigationMode.motocycle
    ]
    
    static let mapOptions = [
        "flexible": NBMapOption.valhalla,
        "fast": NBMapOption.none
    ]
    
    static let measurements = [
        "imperial": MeasurementSystem.imperial,
        "metric": MeasurementSystem.metric
    ]
    
    class func convertRouteRequestParams(arguments: Any?) -> NBNavRouteOptions? {
        guard let arguments = arguments as? String else { return nil }
        let options = jsonStringToDictionary(arguments)
        var routeOptions: NBNavRouteOptions?
        let mode = options["mode"] as? String
        
        var allWayPoints: [Waypoint] = []
        if let points = options["waypoints"] as? [Any], !points.isEmpty {
            let waypoints = points.map { point in
                return convertWayPoint(point: point as! [Double])
            }
            allWayPoints.append(contentsOf: waypoints)
        }
        
        if let origin = options["origin"] as? [Double], let destination = options["destination"] as? [Double] {
            let originWayPoint = convertWayPoint(point: origin)
            let destinationWayPoint = convertWayPoint(point: destination)

            allWayPoints.insert(originWayPoint, at: 0)
            allWayPoints.append(destinationWayPoint)
        }
        
        if let approaches = options["approaches"] as? [String], approaches.count == allWayPoints.count - 1 {
            for (index, approache) in approaches.enumerated() {
                allWayPoints[index + 1].allowsArrivingOnOppositeSide = approache == "unrestricted"
            }
        }
        
        if !allWayPoints.isEmpty {
            routeOptions = NBNavRouteOptions(waypoints: allWayPoints, profile: convertMode(mode: mode) ?? .car)
        }
        
        guard let routeOptions = routeOptions else {
            return nil
        }
        
        let locale = options["language"] as? String ?? Locale.DEFAULT_LANGUAGE_VALUE
        routeOptions.locale = Locale.init(identifier: locale)
        
        if let unit = options["unit"] as? String, let unitValue = MeasurementSystem(description: unit) {
            routeOptions.distanceMeasurementSystem = unitValue
        }
        
        if let alternatives = options["alternatives"] as? Bool {
            routeOptions.includesAlternativeRoutes = alternatives
        }
        
        if let mapOption = options["option"] as? String, let optionValue = mapOptions[mapOption] {
            routeOptions.mapOption = optionValue
        }
        
        if let departureTime = options["departureTime"] as? Int {
            routeOptions.departureTime = departureTime
        }
        
        if let overview = options["overview"] as? String, let overviewValue = RouteShapeResolution(description: overview) {
            routeOptions.routeShapeResolution = overviewValue
        }
        
        if let avoidType = options["avoid"] as? [String] {
            routeOptions.avoid = avoidType
        }

        if let hazmatType = options["hazmatType"] as? [String], let hazmatTypes = NavigationHazmatTypes(descriptions: hazmatType) {
            routeOptions.hazmatTypes = hazmatTypes
        }
        
        if let shapeFormat = options["geometry"] as? String {
            routeOptions.shapeFormat = RouteShapeFormat(description: shapeFormat)!
        }
        
        if let truckSize = options["truckSize"] as? [Int] {
            routeOptions.truckSize = truckSize
        }
        
        if let truckWeight = options["truckWeight"] as? Int {
            routeOptions.truckWeight = truckWeight
        }
        
        if let crossBorder = options["crossBorder"] as? Bool {
            routeOptions.crossBorder = crossBorder
        }

        if let truckAxleLoad = options["truckAxleLoad"] as? Double {
            routeOptions.truckAxleLoad = truckAxleLoad
        }

        if let allow = options["allow"] as? String {
            routeOptions.allow = allow
        }

         if let routeType = options["routeType"] as? String {
             routeOptions.routeType = NBNavigationRouteType.init(routeType)
         }
        //            routeOptions.apiEndpoint
        //            routeOptions.accessToken
        
        return routeOptions
            
    }
    
    class func convertMode(mode: String?) -> NBNavigationMode? {
        guard let mode = mode else {
            return nil
        }
        return navigationMode[mode]
    }
    
    class func convertWayPoint(point: [Double]) -> Waypoint {
        let latitude = point[1]
        let longitude = point[0]
        
        let pointLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let wayPoint = Waypoint(coordinate: pointLocation, name: "\(latitude),\(longitude)")
        return wayPoint
    }
    
    class func convertRouteOptionsToMap(routeOptions: RouteOptions) -> [String: Any] {
        var options: [String: Any] = [:]
        
        var wayPoints: [[Double]] = []
        var approaches: [String] = []

        let optionWayPoints = routeOptions.waypoints
        if !optionWayPoints.isEmpty, optionWayPoints.count > 1 {
            optionWayPoints.forEach { wayPoint in
                wayPoints.append(convertCoordinateToMap(coordinate: wayPoint.coordinate))
            }
            options["origin"] = wayPoints.first
            options["destination"] = wayPoints.last
            if optionWayPoints.count > 2 {
                options["waypoints"] = Array(wayPoints.dropFirst().dropLast())
            }
        }
        
        let forbiddenArrivingOnOppositeSide = optionWayPoints.dropFirst().contains { !$0.allowsArrivingOnOppositeSide }
        if forbiddenArrivingOnOppositeSide {
            approaches = optionWayPoints.dropFirst().compactMap { $0.allowsArrivingOnOppositeSide ? "unrestricted" : "curb" }
        }
        
        options["mode"] = routeOptions.profileIdentifier.rawValue
        options["language"] = routeOptions.locale.languageCode
        options["unit"] = routeOptions.distanceMeasurementSystem.description
        options["alternatives"] = routeOptions.includesAlternativeRoutes
        options["option"] = routeOptions.mapOption.rawValue
        options["departureTime"] = routeOptions.departureTime
        options["overview"] = routeOptions.routeShapeResolution.description
        options["avoid"] = routeOptions.avoid
        options["geometry"] = routeOptions.shapeFormat.description
        options["truckSize"] = routeOptions.truckSize
        options["truckWeight"] = routeOptions.truckWeight
        options["allow"] = routeOptions.allow

        if (!routeOptions.hazmatTypes.isEmpty) {
            options["hazmatType"] = routeOptions.hazmatTypes.description.components(separatedBy: ";")
        }
        
        if (!approaches.isEmpty) {
            options["approaches"] = approaches
        }

        options["crossBorder"] = routeOptions.crossBorder
        options["truckAxleLoad"] = routeOptions.truckAxleLoad
        return options
    }
    
    class func convertCoordinateToMap(coordinate: CLLocationCoordinate2D) -> [Double] {
        return [coordinate.longitude, coordinate.latitude]
    }
    
    class func convertNavigationRoutes(arguments: [String: Any]) -> ([Route], Int?) {
        if let options = arguments["routeOptions"] as? String, let launcherConfig = arguments["launcherConfig"] as? [String: Any] {
                let routeOptions = convertRouteRequestParams(arguments: options)
                guard let routeOptions = routeOptions else {
                    return ([], nil)
                }
                if let singleRouteJson = launcherConfig["route"] as? String, !singleRouteJson.isEmpty {
                    let singleRoute = modifyRoute(routeOptions: routeOptions, routeJson: singleRouteJson)
                    var routes: [Route] = []
                    if let routeJsons = launcherConfig["routes"] as? [String], !routeJsons.isEmpty {
                        routeJsons.forEach { jsonString in
                            let route = modifyRoute(routeOptions: routeOptions, routeJson: jsonString)
                            routes.append(route)
                        }
                    } else {
                        routes.append(singleRoute)
                    }
                    
                    // Find the index of the singleRoute in routes
                    let routeIndex = routes.firstIndex(where: { $0.shape == singleRoute.shape })
                    
                    // Return the routes and the routeIndex
                    return (routes, routeIndex)
                }
            }
            return ([], nil)
        
    }
    
    class func modifyRoute(routeOptions: NBNavRouteOptions, routeJson: String) -> Route {
        let json = jsonStringToDictionary(routeJson)
        let route = Route.init(json: json, waypoints: routeOptions.waypoints, options: routeOptions)
        route.speechLocale = routeOptions.locale
        route.modifyRoute()

        return route
    }
    
    class func convertDirectionsRoute(arguments: [String: Any]) -> Route? {
        if let options = arguments["routeOptions"] as? String, let routeJson = arguments["route"] as? String {
            let routeOptions = convertRouteRequestParams(arguments: options)
            guard let routeOptions = routeOptions else {
                return nil
            }
            return modifyRoute(routeOptions: routeOptions, routeJson: routeJson)
        }
        return nil
        
    }
    
    class func jsonStringToDictionary(_ jsonString: String) -> [String: Any] {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return [:]
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
            guard let dictionary = json as? [String: Any] else {
                return [:]
            }
            return dictionary
        } catch {
            return [:]
        }
    }
    
    class func convertNavigationOptions(args: [String : Any], routes: [Route], index: Int) -> NavigationOptions {
        var simulate = SimulationMode.onPoorGPS
        var navigationModeStyle: [NbmapNavigation.Style] = [NavStyleManager.customDayStyle, NavStyleManager.customNightStyle]

        if let config = args["launcherConfig"] as? [String : Any] {
            if let isSimulate = config["shouldSimulateRoute"] as? Bool {
                simulate = isSimulate ? .always : .onPoorGPS
            }
            if let themeMode = config["themeMode"] as? String, let useCustom = config["useCustomNavigationStyle"] as? Bool {
                let navigationDayStyle = dayStyle(useCustom)
                let navigationNightStyle = nightStyle(useCustom)
                
                if let mapStyleUrl = config["navigationMapStyleUrl"] as? String {
                    navigationDayStyle.mapStyleURL = URL(string: mapStyleUrl)!
                }
                
                navigationModeStyle =
                themeMode == "light" ? [navigationDayStyle] :
                themeMode == "dark" ? [navigationNightStyle] :
                [navigationDayStyle, navigationNightStyle]
            }
        }
     
        let navigationService = NBNavigationService(routes: routes, routeIndex: index, simulating: simulate)
        
        let navigationOptions = NavigationOptions(styles: navigationModeStyle, navigationService: navigationService)
        return navigationOptions
    }
    
    class func dayStyle(_ useCustomNavigationStyle: Bool) -> Style {
        return useCustomNavigationStyle ? NavStyleManager.customDayStyle : DayStyle()
    }
    
    class func nightStyle(_ useCustomNavigationStyle: Bool) -> Style {
        return useCustomNavigationStyle ? NavStyleManager.customNightStyle : NightStyle()
    }
    
}
