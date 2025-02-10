# Repo structure and design

## Repository structure
1. Model
2. Platform_channels
3. Navigation
4. Utils

### Model
This module contains the DirectionsRoute class, likely representing the data structure for a navigation route.

More details, please refer to the [official documentation](https://docs.nextbillion.ai/docs/navigation/api/navigation) or OSRM’s [documentation](https://project-osrm.org/docs/v5.5.1/api/#result-objects)

### Platform_channels
This module houses all platform-specific bridging logic, including interfaces and implementations for interacting with different platforms.

Beyond the fundamental actions of setMethodChannel and _handleMethodCall, this module offers a comprehensive suite of navigation features, including:

1. Fetching route information
2. Initiating navigation and preview navigation
3. Determining the selected route index
4. Retrieving and setting the routing base URI
5. Obtaining formatted route duration
6. Setting an exit callback for navigation
7. Capturing route duration symbols and waypoints

**fetchRoute**: This method sends a method call to the native side to fetch a route. It sends the routeRequestParams as arguments to the method call. The result of the method call is then passed to the _handleRouteResult method.

**startNavigation**: This method will start the navigation process with a given route. It takes a DirectionsRoute object as an argument and sends a method call to the native side to start the navigation.

**startPreviewNavigation**: This method will start a preview of the navigation process with a given route. It takes a DirectionsRoute object as an argument and sends a method call to the native side to start the preview.

**findSelectedRouteIndex**: This method would likely find the index of the currently selected route. It might send a method call to the native side to retrieve this index.

**getRoutingBaseUri**: This method would likely retrieve the base URI used for routing. It might send a method call to the native side to retrieve this URI.

**setRoutingBaseUri**: This method would likely set the base URI used for routing. It might take a URI as an argument and send a method call to the native side to set this URI.

**getFormattedDuration**: This method will retrieve a formatted string representing the duration of a route. It takes a DirectionsRoute object as an argument and sends a method call to the native side to retrieve this string.

**setOnNavigationExitCallback**: This method will set a callback function to be called when the navigation process exits. It takes a function as an argument and stores it in a variable to be called in the _handleMethodCall method.

**captureRouteDurationSymbol**: This method will capture a symbol representing the duration of a route. It takes a DirectionsRoute object as an argument and sends a method call to the native side to capture this symbol.

**captureRouteWaypoints**: This method will capture the waypoints of a route. It takes a DirectionsRoute object as an argument and sends a method call to the native side to capture these waypoints.
Navigation
Handles interactions with basic maps and the rendering of navigation route lines on the map.

### Utils
This module provides utility functionalities like Dart’s AssetManager for loading assets via Dart’s rootBundle(to improve testability), a time formatter, and a polyline decoder for processing encoded map polyline/geometry.

## Major components and design
### Async initialization of NavNextBillionMap
In the current version of our SDK, we've chosen to utilize an asynchronous static method for initializing NavNextBillionMap. This decision aligns with the current design, where NavNextBillionMap doesn't rely on external dependencies that necessitate asynchronous operations.
```
 NavNextBillionMap._create(this.controller,
      {this.routeLineProperties = const RouteLineProperties()});

  static Future<NavNextBillionMap> create(MapController mapController,
      {RouteLineProperties routeLineProperties =
          const RouteLineProperties()}) async {
    var navMap = NavNextBillionMap._create(mapController,
        routeLineProperties: routeLineProperties);
    navMap.assetManager = AssetManager();
    await navMap.initGeoJsonSource();
    return navMap;
  }
```

However, as our SDK matures and incorporates more complexity, the need for external dependencies, resources, and services may arise. In such scenarios, we'll transition to dependency injection (DI). DI fosters loose coupling within the codebase and enhances testability – both crucial aspects for a robust and maintainable SDK.

This approach provides flexibility. We leverage a simpler approach now while acknowledging the potential need for DI in the future as the SDK evolves.

### Design Choice for NBNavigation Class
In the current design of our Flutter SDK, we opted for a stateless facade instead of a singleton for the NBNavigation class. This decision was made for two key reasons:
1. Simplified Interface: Since our SDK currently doesn't integrate with state management solutions, a stateless facade provides a cleaner and easier-to-use interface for developers.
2. Loose Coupling: The facade pattern isolates the application code from the internal workings of the NBNavigation class. This promotes loose coupling, making the code more maintainable and adaptable to future changes in the underlying system.

Future Enhancements

We acknowledge that the stateless facade approach might not always be the optimal solution. In future iterations of the SDK, we will explore introducing singletons or even better alternatives if:
1. The current design fails to meet developer expectations in terms of functionality or ease of use.
2. The stateless facade hinders effective testing practices.
   
By staying flexible in our design approach, we aim to continuously improve the usability and maintainability of our Flutter SDK.

### Fetch Routes and draw route
Unlike other Flutter Navigation SDKs, Nextbillion's Flutter navigation SDK empowers developers to create a more user-friendly experience.  Our fetchRoute and drawRoute functionalities allow developers to build a dedicated route preview page before users jump into navigation, providing them with clarity and control over their planned journey.

Process of drawing a route

**drawRoute**: This method is responsible for drawing the route on the map. It first checks if the map controller is disposed or if the routes list is empty. If either is true, it returns immediately. Otherwise, it proceeds to clear any existing route on the map, draw the new routes, draw the waypoints for the first route, and draw the duration symbol for the routes.

**clearRoute**: This method clears any existing route on the map. It does this by setting the GeoJSON source of the route layers to an empty feature collection.

**_drawRoutesFeatureCollections**: This method is responsible for drawing the routes on the map. It first checks if the map controller is disposed. If it is, it returns immediately. Otherwise, it proceeds to create a list of GeoJSON features representing the routes. For each route, it decodes the route geometry into a list of LatLng points, creates a LineOptions object with these points, converts this object to GeoJSON, and adds a property indicating whether the route is the primary route. It then adds this GeoJSON to the list of route line features. If the list of route line features is not empty, it sets the GeoJSON source of the route layers to a feature collection containing these features.

**_drawWayPoints**: This method is responsible for drawing the waypoints of the first route on the map. The details of this method are not shown in the provided code, but it likely involves creating a GeoJSON feature for each waypoint and setting the GeoJSON source of the waypoint layer to a feature collection containing these features.

**_drawRouteDurationSymbol**: This method is responsible for drawing the duration symbol for the routes on the map. The details of this method are not shown in the provided code, but it likely involves creating a GeoJSON feature for each route with a property representing the duration of the route, and setting the GeoJSON source of the duration symbol layer to a feature collection containing these features.




