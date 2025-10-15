# Changelog

All notable changes to this project will be documented in this file.

## [3.1.1] - 2025-10-15
- Bump iOS Navigation SDK to **3.1.1**. This resolves a crash that occasionally occurs during rerouting

## [3.1.0] - 2025-09-30
### Changed
- **Android Native SDK**: Updated to 2.4.0 (from 2.3.1-beta.1)
- **Build System**: Updated Android Gradle Plugin (AGP) to 8.6.0
- **Dependencies**: Updated `nb_maps_flutter` to version 3.0.2 (3.1.0 available but constrained)
- **Build Configuration**: Improved Gradle cache management and build reliability
- 
### ⚠️ BREAKING CHANGES
- Android **16kb** alignment support
- Update android **minSdkVersion** version from 21 to 23

## [3.0.1] - 2025-09-26
- Fixed `OnNavigationExitCallback` not called when navigation canceled
- 
## [3.0.0] - 2025-09-19 🚀

### ⚠️ BREAKING CHANGES

#### iOS Metal Migration
The iOS navigation native framework has been updated to version 3.0.0 with migration to Metal rendering.
- **Benefit**: Significantly improved rendering performance and modern graphics pipeline

#### Enum Naming Convention Changes
Multiple enums have been updated to follow lowercase naming conventions.

**MyLocationTrackingMode**:
- ⚠️ **Action Required**: Update your code to use lowercase enum values
- **Before**: `MyLocationTrackingMode.Tracking`, `MyLocationTrackingMode.TrackingCompass`, `MyLocationTrackingMode.TrackingGPS`
- **After**: `MyLocationTrackingMode.tracking`, `MyLocationTrackingMode.trackingCompass`, `MyLocationTrackingMode.trackingGPS`

**Map Style Types**:
- **New**: `NBMapStyleType.bright`, `NBMapStyleType.night` (replaces previous style string approach)
- **Usage**: Set via `styleType` property in `NBMap` widget instead of `styleString`

#### Android Performance Optimization
The Android navigation native framework has been updated to version 2.3.0 with major performance improvements.
- **Benefit**: Resolved stuttering issues on long-distance routes

### Added
- **Tile Server Switching**: Added support for switching between different tile servers dynamically
  - `NBNavigation.switchTileServer(server: WellKnownTileServer)`
  - Support for TomTom and MapTiler tile servers
- **Map Style Switching**: Added support for switching map styles at runtime
  - Light/Dark theme switching via `NextbillionMapController.setStyleString()`
  - Dynamic style updates without map recreation
- **Enhanced Example App**: Added interactive buttons in `FullNavigationExample` for:
  - Transportation mode switching (Car → Truck → Bike → Motorcycle)
  - Tile server switching with visual feedback
  - Map style switching with loading indicators

### Fixed
- **Route Request Serialization**: Fixed `avoid` parameter type inconsistency in `RouteRequestParams.toJson()`
  - Ensured both `avoidType` and legacy `avoid` parameters serialize to consistent string arrays
  - Added comprehensive unit tests for avoid parameter handling
- **Long Route Performance**: Resolved stuttering and performance issues on long-distance routes (Android)
- **Build Configuration**: Fixed JVM target compatibility issues between Java and Kotlin compilation

### Changed
- **iOS Native SDK**: Upgraded to 3.0.0 with Metal rendering support
  - **Migration to Metal**: Complete transition from OpenGL to Metal for improved performance
  - **Performance**: Significantly faster rendering and better memory management
  - **Compatibility**: Requires iOS 12.0+ (Metal-compatible devices)
- **Android Native SDK**: Upgraded to 2.4.0 with performance optimizations
  - **Long Route Performance**: Resolved stuttering and lag issues on long-distance routes
  - **Memory Optimization**: Improved memory usage during navigation
- **Dependencies**: Updated `nb_maps_flutter` to version 3.0.2
- **Build System**: Updated Android Gradle configuration for better compatibility
  - Android Gradle Plugin (AGP): Upgraded to 8.6.0
  - Kotlin: Upgraded to 1.9.24
  - Java compilation target: VERSION_11
  - Kotlin JVM target: '11'

### Improved
- **User Experience**: Enhanced visual feedback for all switching operations
- **Error Handling**: Improved error messages and user notifications
- **Code Quality**: Added comprehensive unit tests for route parameter serialization
- **Performance**: Significant performance improvements for long-distance navigation routes
- **Developer Experience**: Enhanced example app with multiple interactive features for testing

### Technical Details
- **iOS Rendering**: Complete migration from OpenGL ES to Metal for better performance and future-proofing
- **Android Optimization**: Optimized route calculation and rendering for long-distance routes (>100km)
- **Memory Management**: Improved memory usage patterns in both platforms
- **Testing Coverage**: Added 35+ unit tests for route parameter serialization and avoid field handling

### Migration Guide
For developers upgrading from 2.x to 3.0.0:

#### Required Code Changes
1. **MyLocationTrackingMode Enum**: Update enum value casing
   ```dart
   // Before (2.x)
   MyLocationTrackingMode.Tracking
   MyLocationTrackingMode.TrackingCompass
   MyLocationTrackingMode.TrackingGPS
   
   // After (3.0.0)
   MyLocationTrackingMode.tracking
   MyLocationTrackingMode.trackingCompass
   MyLocationTrackingMode.trackingGPS
   ```

2. **Map Style Configuration**: Update from string-based to enum-based styling
   ```dart
   // Before (2.x)
   NBMap(
     styleString: isLight ? NbMapStyles.LIGHT : NbMapStyles.DARK,
   )
   
   // After (3.0.0)
   NBMap(
     styleType: isLight ? NBMapStyleType.bright : NBMapStyleType.night,
   )
   ```

#### Platform Requirements
3. **iOS**: Ensure your minimum deployment target is iOS 12.0+ (Metal support required)
4. **Android**: No action required - performance improvements are automatic

#### Testing & Verification
5. **API Compatibility**: All other existing APIs remain compatible
6. **Performance Testing**: Verify navigation performance on your specific use cases
7. **Device Testing**: Test on older iOS devices to ensure Metal compatibility

## [2.7.0] - 2025-08-23

### Added
- Added `currentLegProgress` to `NavigationProgress`, enabling access to ETA for upcoming waypoints via `NBNavigationView.onProgressChange`

### Fixed
- Fixed `avoid` function now correctly handles both `RouteRequestParams.avoidType` and `RouteRequestParams.avoid`
- Fixed all lint issues detected by `flutter_lints`
- Fixed all lint issues checked by `flutter_lint`

### Changed
- Replaced deprecated `PreferenceManager.getDefaultSharedPreferences` with `context.getSharedPreferences` using "NAVIGATION_SHARE_PREFS"
- Upgraded `NextBillionNavigation` to version 2.5.0 — fixed all native SDK lint issues in this release
- Upgraded `ai.nextbillion:nb-navigation-android` from 2.1.0 to 2.2.0 — includes native SDK lint fixes
- Upgraded `nb_maps_flutter` to 2.2.0 — includes native SDK lint fixes

## [2.6.0] - 2025-03-14

### Added
- Added support for bike and motorcycle modes in route generation

### Changed
- Upgraded `nb_maps_flutter` to version 2.1.0 to fix error logs when retrieving image resources

## [2.5.0] - 2025-04-15

### Fixed
- Fixed build error on Flutter 3.29 and above

### Changed
- Upgraded `nb_maps_flutter` version to 2.0.0

## [2.4.0] - 2025-04-10

### Fixed
- Fixed build issue when Xcode upgraded to 16.3 or above

### Changed
- Upgraded iOS native SDK to 2.4.0

## [2.3.2] - 2025-04-10

### Fixed
- Fixed `NBNavigation.fetchRoute` route request error on iOS of the SDK version v2.3.1

## [2.3.1] - 2025-04-09

### Fixed
- Fixed crash issue when origin is very close to destination

### Changed
- Upgraded Android native SDK to 2.0.5

## [2.3.0+1] - 2025-03-13

### Added
- Added missing permission annotations for the Android platform in the README:
  ```xml
  <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION"/>
  <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
  <uses-permission android:name="android.permission.INTERNET" />
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
  ```

## [2.3.0] - 2025-03-13

### Added
- Added support for custom map style on preview screen
- Added `NavigationMap.removeRouteSelectedListener` method to remove the route selection listener
- Added instrumentation enabled by default

### Fixed
- Fixed dissolved route progress not matching the primary route progress
- Fixed crash issue in simulation mode on iOS
- Fixed issue where dissolved route style doesn't work on Android when using `NBNavigationView`
- Fixed alternative route selection issue
- Fixed the issue where the wrong route was launched if the primary route was changed before starting navigation

### Changed
- Upgraded iOS native SDK to 2.3.0
- Refactored README documentation
- Updated iOS PLATFORM_VERSION to 12.0
- Bumped version to 2.3.0 to align with the nb_maps_flutter SDK
- Bumped minimum Flutter version to 3.24.1
- Bumped minimum Android version to 21
- Optimized the off-route detector on iOS
- Refactored `NavigationMap.addRouteSelectedListener`:
  - Removed the LatLng parameter
  - Changed the method to use an internal calculation mechanism instead

### Improved
- Added support for live traffic on the navigation screen

## [2.2.0] - 2025-02-07

### Added
- Added support for the 'avoid' parameter in route request options
- Added `RouteRequestParams.routeType` field in route request parameters (takes effect when `RouteRequestParams.option` is set as `SupportedOption.flexible`)

### Fixed
- Fixed Android navigation screen displaying incorrect route instead of the selected route
- Fixed puck icon jumpiness during rerouting
- Fixed incorrect U-turn display in "Then" step instructions

### Changed
- Updated Android navigation native framework to 1.5.0
- Increased network request timeout to 30 seconds
- Instrumentation enabled by default

## [2.1.0] - 2024-12-16

### Changed
- Adapted to Android Gradle Plugin 8.0 without using the AGP Upgrading Assistant
- Adapted to Android Kotlin Plugin 1.8.0+

## [2.0.0] - 2024-12-13

### ⚠️ BREAKING CHANGES

#### Bitcode Disabled
The iOS navigation native framework has been updated to version v2.1.0, and Bitcode support has been disabled. This change is breaking for projects that require Bitcode.
- ⚠️ **Action Required**: Ensure you update your project settings to account for the disabled Bitcode when integrating this framework version

#### Android Gradle Plugin 8.0+ Support
The Android navigation native framework has been updated to version v1.4.0 and now supports Android Gradle Plugin (AGP) 8.0+.
- ⚠️ **Action Required**: If your project is using AGP 8.0 or above, please upgrade to this version

### Added
- Added support for the 'allow' parameter in route request options
- Added `avoidType` field in route request parameters to accept a `List<String>` as its type, which enhances support for the 'avoid' parameter

### Changed
- Updated iOS navigation native framework to version v2.1.0
- Updated Android navigation native framework to version v1.4.0

## [1.0.1] - 2024-09-06

### Fixed
- Fixed crash issue occurring during navigation in tunnel mode on Android

### Changed
- Updated Android native framework to 1.3.10
- Disabled automatic theme switching in tunnel mode on Android

## [1.0.0] - 2024-09-05 🎉

### Added
- **Major Release**: First stable version of the NextBillion Navigation Flutter SDK

### Fixed
- **Primary Route Selection**: Fixed issue where the selected route was not being used as the primary route (default behavior was always using `routes.first`)
  ```dart
  // New implementation
  NavigationLauncherConfig config = NavigationLauncherConfig(route: selectedRoute, routes: routes);
  ```

### Changed
- Updated Android navigation native framework to 1.3.9
- Updated iOS navigation native framework to 1.6.1
- Upgraded dependency version of NBmaps.xcframework to 1.1.5

### Improved
- **Route Switching Optimization**: Simplified route switching handling by removing unnecessary list operations for better performance
  - **Previous**: When a route was selected, the code moved the selected route to the beginning of the list and redrew the routes
  - **New**: Simplified logic to just set `primaryIndex` to `selectedRouteIndex`
    ```dart
        navNextBillionMap.addRouteSelectedListener(coordinates, (selectedRouteIndex) {
           if (routes.isNotEmpty) {
             primaryIndex = selectedRouteIndex;
           }
        });
      ```

### Removed
- Removed NbmapDirections.xcframework from NbmapCoreNavigation and merged related classes into NbmapCoreNavigation

## [0.7.0] - 2024-07-23

### Added
- Added `showSpeedometer` property to `NavigationLauncherConfig` to support showing the speedometer on the navigation screen
- Added `NBNavigationView.onRerouteFailureCallback` callback to support listening to navigation reroute failure events
- Added `NBNavigationView.onRerouteAlongCallback` callback to support listening to navigation reroute along events

### Fixed
- Fixed speedometer view display issue on `NBNavigationView` for Android
- Fixed speedometer not shown on Android when using `NBNavigationView`
- Fixed `NBNavigationView.onArriveAtWaypoint` callback not triggered on iOS when arriving at waypoint

### Changed
- Updated Android navigation native framework to 1.3.6

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


## [0.1.0] - 2023-07-19 🚀

### Added
- **Initial Release**: NextBillion Navigation Flutter SDK
- **Maps Plugin**: Core mapping functionality
- **Route Fetching**: Support for fetching routes with `RouteRequestParams`
- **Route Visualization**: Support for drawing route lines on MapView
- **Alternative Routes**: 
  - Toggle alternative line visibility
  - Toggle route duration symbol visibility
- **Navigation Launch**: Launch navigation with given route
  - Single route support
  - Multiple routes support (including alternative routes)
  - Theme modes: system (default), light, dark
  - Location layer render mode: default `LocationLayerRenderMode.GPS`
  - Dissolved route line: enabled by default

### Customization Features
- **Route Line Appearance**:
  - Route line shield color
  - Alternative route line shield color
  - Route width and color
  - Alternative route color
  - Route origin marker image
  - Route destination marker image
- **Navigation View Appearance**: Customizable navigation view styling
