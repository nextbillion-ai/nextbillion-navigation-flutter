##  2.7.0-dev.4 Aug 21, 2025
* Fixed an issue where the avoid function only applied [RouteRequestParams.avoidType] and ignored the [RouteRequestParams.avoid] parameter.
##  2.7.0-dev.3
* Replace deprecated [PreferenceManager.getDefaultSharedPreferences] with [context.getSharedPreferences] using "NAVIGATION_SHARE_PREFS"
##  2.7.0-dev.2
* Upgraded [NextBillionNavigation] to version 2.5.0 — fixed all native SDK lint issues in this release
* Upgraded [ai.nextbillion:nb-navigation-android] from 2.1.0 to 2.2.0 — includes native SDK lint fixes
* Upgraded [nb_maps_flutter] to 2.2.0 — includes native SDK lint fixes
* Fixed all lint issues detected by [flutter_lints]
* Fixed all lint issue check by [flutter_lint]
## v2.6.0, Mar 14, 2025
* Upgraded [nb_maps_flutter] to version 2.1.0 to fix error logs when retrieving image resources.
* Added support for bike and motorcycle modes in route generation.

## v2.5.0, Apr 15, 2025
* Upgrade [nb_maps_flutter] version to 2.0.0 to fix build error on flutter 3.29 and above

## v2.4.0, Apr 10, 2025
* Upgrade iOS native SDK to 2.4.0 to fix the build issue when Xcode upgrade to 16.3 or above

## v2.3.2, Apr 10, 2025
* Fixed: Fix  [NBNavigation.fetchRoute] route request error on iOS of the sdk version of v2.3.1

## v2.3.1, Apr 9, 2025
* Upgrade Android native SDK to 2.0.5 to fix the crash issue when origin is very close to destination

## v2.3.0+1, Mar 13, 2025
* Add the missing permission annotation for the Android platform in the README
  ```
  <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION"/>
  <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
  <uses-permission android:name="android.permission.INTERNET" />
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
  ```

## v2.3.0, Mar 13, 2025
* Upgrade the iOS native SDK to 2.3.0 to fix the following issues :
  * Dissolved route progress not matching the primary route progress
  * Support live traffic on the navigation screen
  * Fix crash issue in simulation mode on iOS
* Refactor README
* Update iOS PLATFORM_VERSION to 12.0
* Bump the version to 2.3.0 to align with the nb_maps_flutter SDK
* Bump the minimum flutter version to 3.24.1
* Bump the minimum android version to 21
* Fix issue where dissolved route style doesn't work on Android when using [NBNavigationView].
  * Support custom map style on preview screen
  * Fix crash issue in simulation mode on iOS
  * Optimize the off-route detector on iOS
  * Instrumentation enabled by default
* Fix alternative route selection issue
  * Refactor NavigationMap.addRouteSelectedListener:
    * Removed the LatLng parameter.
    * Changed the method to use an internal calculation mechanism instead.
  * Add `NavigationMap.removeRouteSelectedListener`:
    * Introduced a method to remove the route selection listener.
  * Resolved the issue where the wrong route was launched if the primary route was changed before starting navigation

## v2.2.0, Feb 7, 2025
* Support for the 'avoid' parameter in route request options
* Add an [RouteRequestParams.routeType] field in the route request parameters,it will take effect when [RouteRequestParams.option] set as [SupportedOption.flexible]
* Fix the android navigation screen display incorrect route instead of the selected route
* Update the android navigation native framework to 1.5.0 to fix the follow issue 
  * Instrumentation enabled by default
  * Fixed puck icon jumpiness during rerouting
  * Increased network request timeout to 30 seconds
  * Fixed incorrect U-turn display in "Then" step instructions

## v2.1.0, Dec 16, 2024
* Adapting to Android Gradle Plugin 8.0 Without Using the AGP Upgrading Assistant
* Adapting to Android Kotlin Plugin 1.8.0+

## v2.0.0, Dec 13, 2024
### Breaking Changes
#### Bitcode Disabled:
The iOS navigation native framework has been updated to version v2.1.0, and Bitcode support has been disabled. This change is breaking for projects that require Bitcode.
- Ensure you update your project settings to account for the disabled Bitcode when integrating this framework version.
#### Android Gradle Plugin 8.0+ Support:
The Android navigation native framework has been updated to version v1.4.0 and now supports Android Gradle Plugin (AGP) 8.0+.
- If your project is using AGP 8.0 or above, please upgrade to this version.
### Changes
* Updated the iOS navigation native framework to version v2.1.0.
* Updated the Android navigation native framework to version v1.4.0.
* Added support for the 'allow' parameter in route request options.
* Add an avoidType field in the route request parameters to accept a List<String> as its type, which enhances support for the 'avoid' parameter.

## v1.0.1, Sept 6, 2024
* Update android native framework to 1.3.10
  * Disable automatic theme switching in tunnel mode on Android to fix the crash issue occurring during navigation
  
## v1.0.0, Sept 5, 2024
* Update the android navigation native framework to 1.3.9
* Update the iOS navigation native framework to 1.6.1
  * Remove NbmapDirections.xcframework from NbmapCoreNavigation and merged related classes into NbmapCoreNavigation.
  * Upgrade the dependency version of NBmaps.xcframework to 1.1.5
* Optimization: Simplified Route Switching Handling, by removing unnecessary list operations, the new code is more efficient.
  * Previous Implementation:
    * When a route was selected, the code moved the selected route to the beginning of the list and redrew the routes.
  * New Implementation:
    * Simplified the logic to just set primaryIndex to selectedRouteIndex.
      ```
        navNextBillionMap.addRouteSelectedListener(coordinates, (selectedRouteIndex) {
           if (routes.isNotEmpty) {
             primaryIndex = selectedRouteIndex;
           }
        });
      ```
* Bug Fix: Primary Route Selection
  * Issue: The selected route was not being used as the primary route; the default behavior was always using routes.first.
  * Fix: Updated the configuration to support the selected route as the primary route.
    ```
      NavigationLauncherConfig config = NavigationLauncherConfig(route: selectedRoute, routes: routes);
    ```

## v0.7.0, July 23, 2024
* Update the android navigation native framework to 1.3.6 to fix the speedometer view shown issue on the [NBNavigationView]
  * Fix speedometer not shown on Android when use [NBNavigationView] 
* Add [showSpeedometer] property to [NavigationLauncherConfig] to support showing the speedometer on the navigation screen
* Fix [NBNavigationView.onArriveAtWaypoint] callback not triggered on iOS when arrive at waypoint
* Add [NBNavigationView.onRerouteFailureCallback] callback to support listening to the navigation reroute failure event
* Add [NBNavigationView.onRerouteAlongCallback] callback to support listening to the navigation reroute along event

## v0.6.4, July 17, 2024
* Fix [DirectionsRoute.fromJson] issue
  * Error: type 'Map<dynamic,dynamic>' is not a subtype of type 'Map<String,dynamic>' in type cast
* Add [NavNextBillionMap.drawIndependentRoutes] method to support drawing a list of independent routes on the map

## v0.6.3, July 11, 2024
* Updated the android navigation native framework to 1.3.5
  * Fix the speedometer format issue on the navigation screen
## v0.6.2, July 4, 2024
* Updated the iOS navigation native framework to 1.5.1
* Fix a iOS crash issue when on tap the  area outside the arrival dialog view
  * Error: [NbmapNavigation.ArrivedViewController handleDismissTapWithSender:]: unrecognized selector sent to instance
  * 
## v0.6.1, July 1, 2024
* Introduce NBNavigationView widget to support Embedding NavigationView in Flutter app
  * NBNavigationView({
    super.key,
    required this.navigationOptions,
    this.onNavigationViewReady,
    this.onProgressChange,
    this.onNavigationCancelling,
    this.onArriveAtWaypoint,
    this.onRerouteFromLocation,
    })
* Updated the android navigation native framework to 1.3.4
* Updated iOS navigation native framework to 1.5.0


## v0.5.4, June 4, 2024
* Updated dependencies to support new user-agent format in the network requests
  * Updated the nb_maps_flutter dependency to 0.4.2
  * Updated the android navigation native framework to 1.3.3 
  * Updated iOS navigation native framework from 1.3.3 to 1.4.8

## v0.5.3, June 5, 2024
* Updated the nb_maps_flutter dependency to 0.4.1
* Add avoid options
  * SupportedAvoid.uTurn
  * SupportedAvoid.sharpTurn
  * SupportedAvoid.serviceRoad

## v0.5.2, June 4, 2024
* Add route request params
  * hazmatType
  * approaches

## v0.5.1, May 29, 2024
* Updated the nb_maps_flutter dependency to 0.4.0
* Fix state error exception when the widget is disposed
* Error: This NextbillionMapController has already been disposed. This happens if flutter disposes a NBMap and you try to use its Controller afterwards.
  
## v0.5.0, May 28, 2024
* Added Unit Tests
* Supporting set user id (HTTP Request's User-Agent)
  * NBNavigation.setUserId(userId)
* Supporting get the current nbid
  * NBNavigation.getNBId()
  
## v0.4.5, May 16, 2024
* Configure the minimum flutter version to 3.3.0
* Fix the build error
  * Error: No named parameter with the name 'size'
  
## v0.4.3, May 15, 2024
* Configure the minimum flutter version to 3.22.0 and fix the build error
  * Error: No named parameter with the name 'size'

## v0.4.1, May 14, 2024
* Refactor the way to return route results from NBNavigation.fetchRoute()
  * Remove the route result callback from NBNavigation.fetchRoute()
  * Return the route result with `Future<DirectionsRouteResponse>`
* Refactor NavNextbillionMap constructor
  * Remove the unnecessary await from constructor 
  * Use factory to initialize NavNextbillionMap constructor

## v0.4.0, May 10, 2024
* Update the android navigation native framework to 1.3.0
* Update nb_maps_flutter dependency to 0.3.5

## v0.3.6, May 8, 2024
* Update nb_maps_flutter dependency to 0.3.4
* Remove unnecessary await in the NavNextbillionMap

## v0.3.4, Apr 24, 2024
* Update nb_maps_flutter dependency to 0.3.1

## v0.3.3, Apr 10, 2024
* Remove the restriction on the initialization timing of the NavNextBillionMap object


## v0.3.2, Apr 9, 2024
* Update the android navigation native framework to 1.2.5
* Update iOS navigation native framework from 1.3.3


## v0.3.1, Dec 11, 2023
* Update the android navigation native framework to 1.2.0
* Update iOS navigation native framework from 1.2.12
* Add avoid none option in route request params
  * SupportedAvoid.none to avoid noting during the route.


## v0.3.0, Nov 28, 2023
* Update the android navigation native framework to 1.1.8
* Update nb_maps_flutter Plugin to 0.3.0


## v0.2.1, Nov 8, 2023
* Update the android navigation native framework to 1.1.5
* Update iOS navigation native framework from 1.2.11
* Support previewing navigation processes based on a given route
  * NBNavigation.startPreviewNavigation(route)
* Support to specify the callback that will be executed when user exit navigation
  * NBNavigation.setOnNavigationExitCallback(callback)


## v0.2.0, Sept 26, 2023
* Update the android navigation native framework to 1.0.7
* Update iOS navigation native framework from 1.2.6
* Update nb_maps_flutter dependency to 0.2.0
* Change the route request params geometryType to geometry
  * routeRequestParams.geometry = SupportedGeometry.polyline6
* Support animate map camera into bounds with route points
  *  var latLngBounds = LatLngBounds.fromMultiLatLng(multiPoints);
     controller?.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, top: 50, left: 50, right: 50, bottom: 50));


## v0.1.8, Sept 15, 2023
* Update nb_maps_flutter dependency from 0.1.5 to 0.1.6
* Update the route wayPoint label style


## v0.1.7, Sep 05, 2023
* Update the android navigation native framework from 1.0.5 to 1.0.6
* Update iOS navigation native framework from 1.2.1 to 1.2.3
  * Fix voice spoken issue
  * Fix lane voice instructions issue
* Refactor the way to custom navigation style (iOS)
* Fix sometimes destination icon missing issue (Android)


## v0.1.6, August 17, 2023
* Update nb_maps_flutter dependency from 0.1.1 to 0.1.5
* Update the android navigation native framework from 1.0.0 to 1.0.5
* Update iOS navigation native framework from 1.1.5 to 1.2.1
* Update the default map style
* Support to custom the routing baseUri


## v0.1.5, August 03, 2023
* Update the location coordinate type in RouteRequestParams
* Complete the route result module
* Update iOS framework


## v0.1.4, July 24, 2023
* Fix Navigation Reroute issue
* Add permissions annotation


## v0.1.0, July 19, 2023
* Maps Plugin
* Support fetch route
  * RouteRequestParams
* Support draw route line on MapView
* Support alternative routes
  * Toggle alternative line visibility
  * Toggle Route duration symbol visibility
* Launch Navigation with given route
  * route
  * routes (all routes contain alternative routes)
  * themeMode: system(default), light, dark
  * locationLayerRenderMode: default LocationLayerRenderMode.GPS
  * enableDissolvedRouteLine: default true
* Customize Route line appearance
  * route line Shield Color
  * alternative Route line ShieldColor
  * route width
  * route color
  * alternative route color
  * route origin marker image
  * route destination marker image
* Customize Navigation View appearance
