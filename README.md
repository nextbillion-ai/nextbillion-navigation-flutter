# Nextbillion Navigation Flutter

[![codecov](https://codecov.io/github/nextbillion-ai/nextbillion-navigation-flutter/graph/badge.svg?token=70S2KSAQ8Q)](https://codecov.io/github/nextbillion-ai/nextbillion-navigation-flutter)

## License

This project is licensed under the BSD 3-Clause "New" or "Revised" License - see the [LICENSE](LICENSE) file for details.

### Third-Party Licenses

This project includes third-party components with their own licenses. See the [NOTICE](NOTICE) file for details.

## Instroduction
![IMG_0378](https://github.com/nextbillion-ai/nb-navigation-flutter/assets/100656364/870d9039-cea0-453e-a06c-adaada65cc8e)

## Prerequisites
* Access Key
* Android minSdkVersion 23+
* iOS 12+
* Flutter 3.22+
## Initialization
### Add Dependency
Add the following dependency to your project pubspec.yaml file to use the NB Navigation Flutter Plugin add the dependency to the pubspec.yaml (change the version to actual version that you want to use):
```
dependencies:
  nb_navigation_flutter: {version}
```
### Configure the iOS and Android project
#### iOS
* In the build settings, locate "**Build Libraries for Distribution**" and ensure it is set to "**No**".
  <img width="1061" src="https://github.com/nextbillion-ai/nb-navigation-flutter/assets/100656364/641c31b7-3d9a-4337-b5e5-f7808cd0c737">
#### Android
* Important :If you want to use the NavigationView, you need to to make the `MainActivity` extend `FlutterFragmentActivity` instead of `FlutterActivity` in the Android project.
  ```
  import io.flutter.embedding.android.FlutterFragmentActivity
  
  class MainActivity: FlutterFragmentActivity() {
  
  }
  ```
### Import the Package and Initialize the SDK
Import the navigation plugin in your code
```
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';
```  
Configure the NB Maps Token at the beginning of your app: 
```
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

class _NavigationDemoState extends State<NavigationDemo> {
  @override
  void initState() {
    super.initState();
    NextBillion.initNextBillion(YOUR_ACCESS_KEY);
  }
}
```

### Required Permissions
You need to grant location permission in order to use the location component of the NB Navigation Flutter Plugin, declare the permission for both platforms:

#### Android
Add the following permissions to the manifest:
```
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION"/> 
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.INTERNET" />
```

##### Requesting Location Runtime Permissions (Foreground and Background) in Android 6.0 and Above

For Android 6.0 (API 23) and above, you need to dynamically request permissions. Below is how to request location permissions using the `permission_handler` , including foreground and background permissions:
```
import 'package:permission_handler/permission_handler.dart';

Future<void> checkAndRequestLocationPermissions() async {
  // Request foreground location permission
  PermissionStatus status = await Permission.location.request();
  
  if (status.isGranted) {
    // If foreground location permission is granted, further request background location permission
    // This permission is needed for Android 10 and above, if you need to continue updating navigation data when the app goes to the background
    PermissionStatus backgroundStatus = await Permission.locationAlways.request();

    if (!backgroundStatus.isGranted) {
      // If background location permission is denied, notify the user and exit
      print("Background location permission is required.");
      return;
    }
  } else {
    // If foreground location permission is denied, notify the user
    print("Foreground location permission is required.");
    return;
  }
}
```
##### Requesting Notification Runtime Permission in Android 13 and Above
For Android 13 (API 33) and above, you need to dynamically request notification permissions if you want to show notifications while the app is in the background:

```
Future<void> checkAndRequestNotificationPermission() async {
  // Check notification permission status
  PermissionStatus status = await Permission.notification.status;

  if (!status.isGranted) {
    // Request notification permission
    status = await Permission.notification.request();
    if (status.isGranted) {
      print("Notification permission granted.");
    } else {
      print("Notification permission denied.");
    }
  } else {
    print("Notification permission already granted.");
  }
}
```

#### iOS
Add the following to the Runner/Info.plist to explain why you need access to the location data:
```
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>  
  <string>[Your explanation here]</string>
<key>NSLocationWhenInUseUsageDescription</key>  
  <string>[Your explanation here]</string> 
```

## Usage
### NB Maps
If you need to use Maps related functions, for example: Display a Map widget, please refer to NB [Flutter Maps Plugin](https://pub.dev/packages/nb_maps_flutter)

### Observe and Tracking User Location
* Add the callback onUserLocationUpdated(UserLocation location)
* Animate camera to user location within `onStyleLoadedCallback`
```
void _onMapCreated(NextbillionMapController controller) {
    this.controller = controller;
  }

_onUserLocationUpdate(UserLocation location) {
    currentLocation = location;
  }

_onStyleLoadedCallback() {
    if (currentLocation != null) {
      controller?.animateCamera(CameraUpdate.newLatLngZoom(currentLocation!.position, 14), duration: Duration(milliseconds: 400));
    }
  }

NBMap(
     onMapCreated: _onMapCreated,
     onStyleLoadedCallback: _onStyleLoadedCallback,
     initialCameraPosition: const CameraPosition(
            target: LatLng(0, 0),
            zoom: 14.0,
          ),
     trackCameraPosition: true,
     myLocationEnabled: true,
     myLocationTrackingMode: MyLocationTrackingMode.tracking,
     onUserLocationUpdated: _onUserLocationUpdate,
)
```
### Fetch Routes
You can request routes with RouteRequestParams using NBNavigation, for the supported params, please refer to [Navigation API](https://docs.nextbillion.ai/docs/navigation/api/navigation)
 
* Create RouteRequestParams
```
RouteRequestParams requestParams = RouteRequestParams(
      origin: origin,
      destination: dest,
      // waypoints: [waypoint1, waypoint2],
      // language: 'en',
      // alternatives: true,
      // overview: ValidOverview.simplified,
      // avoid: [SupportedAvoid.toll, SupportedAvoid.ferry],
      // option: SupportedOption.flexible,
      // unit: SupportedUnits.imperial,
      // mode: ValidModes.car,
      // geometry: SupportedGeometry.polyline,
    );
```
* Fetch routes
Fetch route with requestParams using NBNavigation.fetchRoute(), and obtain the route result from `Future<DirectionsRouteResponse>`.
  ```
  DirectionsRouteResponse routeResponse = await NBNavigation.fetchRoute(requestParams);
  ```


* Draw routes

  After getting the routes, you can draw routes on the map view using `NavNextBillionMap`, If you need to use Maps related functions, for example: Display a Map widget, please refer to NB [Flutter Maps Plugin](https://pub.dev/packages/nb_maps_flutter)

  Create `NavNextBillionMap` with `NextbillionMapController` in NBMap widget's `onStyleLoadedCallback` callback:
  ```
  void _onMapCreated(NextbillionMapController controller) {
      this.controller = controller;
  }
  
  void _onStyleLoaded() {
      if (controller != null) async {
        navNextBillionMap = await NavNextBillionMap.create(controller!);
      }
    }
  ```

* Draw routes
  ```
  navNextBillionMap.drawRoute(routes);
  ```

* Fit Map camera to route points
  ```
  void fitCameraToBounds(List<DirectionsRoute> routes) {
      List<LatLng> multiPoints = [];
      for (var route in routes) {
         var routePoints = decode(route.geometry ?? '', _getDecodePrecision(route.routeOptions));
         multiPoints.addAll(routePoints);
      }
      if (multiPoints.isNotEmpty) {
        var latLngBounds = LatLngBounds.fromMultiLatLng(multiPoints);
        controller?.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, top: 50, left: 50, right: 50, bottom: 50));
      }
    }
  
    int _getDecodePrecision(RouteRequestParams? routeOptions) {
      return routeOptions?.geometry == SupportedGeometry.polyline ? PRECISION : PRECISION_6;
    }
  ```

* Clear routes
  ```
   navNextBillionMap.clearRoute();
  ```

* Toggle Alternative route visibility
  ```
   navNextBillionMap.toggleAlternativeVisibilityWith(visible);
  ```

* Toggle RouteDurationSymbol visibility
  ```
   navNextBillionMap.toggleDurationSymbolVisibilityWith(visible);
  ```

## Start navigation
We provide two ways to start navigation: `NavigationLauncherConfig` and `NBNavigationView` to launch the navigation UI.
### Start navigation with `NavigationLauncherConfig`
`NavigationLauncherConfig` is a configuration class that provides the necessary settings for launching the navigation UI. You can customize the navigation experience by setting the route, theme mode, and other options.

#### NavigationLauncherConfig constructor
```
NavigationLauncherConfig({
    required this.route,
    required this.routes,
    this.themeMode = NavigationThemeMode.system,
    this.shouldSimulateRoute = false,
    this.enableDissolvedRouteLine = true,
    this.navigationMapStyleUrl = NbNavigationStyles.nbMapCustomMapLightStyle,
    this.useCustomNavigationStyle = false,
    this.locationLayerRenderMode = LocationLayerRenderMode.GPS,
    this.showArriveDialog = true,
  });
```
#### Parameters
* route: The selected route for directions
* routes: A list of available routes
* themeMode: The theme mode for navigation UI, default value is system
  * system: following system mode
  * light
  * dark
* locationLayerRenderMode: The rendering mode for the location layer, default value is LocationLayerRenderMode.GPS
* shouldSimulateRoute:  Whether to simulate the route during navigation, default value is false
* enableDissolvedRouteLine: Whether to enable the dissolved route line during navigation, default value is true
* navigationMapStyleUrl:  The map style URL for navigation UI. If you don't have access to the TomTom map style, you need to set the value as `NbNavigationStyles.nbMapCustomMapLightStyle` or `NbNavigationStyles.nbMapCustomMapDarkStyle`.
* useCustomNavigationStyle: Whether to use custom navigation style, default value is false
* locationLayerRenderMode: The rendering mode for the location layer, default value is LocationLayerRenderMode.GPS
* showArriveDialog: Whether to show the arrive dialog when arriving at the destination, default value is true, only available for NavigationLauncherConfig

#### Example Usage
```
NavigationLauncherConfig config = NavigationLauncherConfig(route: routes.first, routes: routes, shouldSimulateRoute: true);

NBNavigation.startNavigation(config);
```

### Launch Embedded NavigationView
`NBNavigationView` is a customizable navigation view widget designed to provide seamless navigation experiences in your Flutter application. It offers various configuration options to cater to different navigation requirements, such as theme modes, location layer render modes, and custom styles.

#### NBNavigationView constructor
  ```
  const NBNavigationView({
    super.key,
    required this.navigationOptions,
    this.onNavigationViewReady,
    this.onProgressChange,
    this.onNavigationCancelling,
    this.onArriveAtWaypoint,
    this.onRerouteFromLocation,
  });
  ```
#### Parameters

By utilizing the *NavigationLauncherConfig* class, you can customize the navigation experience to meet your specific needs, from theme settings to location layer modes and custom styles. 
* navigationOptions (required): This parameter provides the necessary configuration for the navigation view.
* onNavigationViewReady: A callback that is triggered when the navigation view is ready.
* onProgressChange: A callback that is triggered when there is a change in the navigation progress.
* onNavigationCancelling: A callback that is triggered when navigation is being canceled.
* onArriveAtWaypoint: A callback that is triggered when arriving at a waypoint.
* onRerouteFromLocation: A callback that is triggered when rerouting from a specific location.
  
### Example Usage
```
NBNavigationView(
  navigationOptions: NavigationLauncherConfig(
    route: selectedRoute,
    routes: allRoutes,
    themeMode: NavigationThemeMode.system,
  ),
  onNavigationViewReady: (controller) {
    // Handle navigation view ready
  },
  onProgressChange: (progress) {
    // Handle progress change
  },
  onNavigationCancelling: () {
    // Handle navigation canceling
  },
  onArriveAtWaypoint: (waypoint) {
    // Handle arriving at waypoint
  },
  onRerouteFromLocation: (location) {
    // Handle rerouting from location
  },
);
```

## UI Components
You can customize the styles of Navigation View

### Android
Add Custom style named `CustomNavigationViewLight` in your android project styles.xml with `parent = "NavigationViewLight"`
```
<style name="CustomNavigationViewLight" parent="NavigationViewLight">
//customize your navigation style
<item name="navViewBannerBackground">@color/color</item>
<item name="navViewBannerPrimaryText">@color/color</item>
...
</style>


<style name="CustomNavigationViewDark" parent="NavigationViewDark">
<item name="navViewBannerBackground">@color/colorAccent</item>

</style>
```

### iOS
Import nb_navigation_flutter in the AppDelegate of  your ios project, customize the Navigation View Style by extending `DayStyle` and `NightStyle`
```
import nb_navigation_flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        customStyle()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
     func customStyle() {
        NavStyleManager.customDayStyle = CustomDayStyle()
        NavStyleManager.customNightStyle = CustomNightStyle()
    }
}
```
```
import NbmapNavigation

class CustomDayStyle: DayStyle {
    required init() {
        super.init()
    }
    
    override func apply() {
        super.apply()
        ArrivalTimeLabel.appearance().font = UIFont.systemFont(ofSize: 18, weight: .medium).adjustedFont
        ArrivalTimeLabel.appearance().normalTextColor = #color
        BottomBannerContentView.appearance().backgroundColor = #color
    }
}

class CustomNightStyle: NightStyle {
    required init() {
        super.init()
    }
    
    override func apply() {
        super.apply()
        NavigationMapView.appearance().trafficUnknownColor = UIColor.green
    }
}
```

## Running the example code
Please refer to the [RUN_EXAMPLE_CODE.md](https://github.com/nextbillion-ai/nb-navigation-flutter/blob/main/doc/RUN_EXAMPLE_CODE.md)


