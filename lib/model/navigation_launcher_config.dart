part of nb_navigation_flutter;

enum LocationLayerRenderMode {
  normal,
  compass,
  gps,
}

enum NavigationThemeMode {
  system,
  light,
  dark,
}

class NavigationLauncherConfig {
  /// The selected route for navigation.
  DirectionsRoute route;

  /// All routes return from route request contains alternative routes.
  List<DirectionsRoute>? routes;

  /// The theme mode for the navigation View. Can be
  /// [NavigationThemeMode.system], [NavigationThemeMode.light], [NavigationThemeMode.dark]
  /// The default is NavigationThemeMode.system.
  NavigationThemeMode? themeMode;

  /// The location layer render mode in the Navigation View. Can be
  /// [LocationLayerRenderMode.normal], [LocationLayerRenderMode.compass], [LocationLayerRenderMode.gps]
  /// Default is LocationLayerRenderMode.GPS.
  LocationLayerRenderMode? locationLayerRenderMode;

  /// Indicates whether to simulate the route during Navigation.
  /// Default is false.
  bool? shouldSimulateRoute;

  /// Indicates whether to show the dissolved route line.
  /// Default is true.
  bool? enableDissolvedRouteLine;

  /// Indicates whether to enable the custom style defined in
  /// styles.xml for Android (`CustomNavigationViewLight`, `CustomNavigationViewDark`)
  /// AppDelegate for iOS (`customDayStyle`, `customNightStyle`)
  bool? useCustomNavigationStyle;

  /// Indicates the map style in Navigation view.
  /// Its priority is higher than
  /// the navViewMapStyle of (`CustomNavigationViewLight`, `CustomNavigationViewDark`) set in the styles.xml for Android
  /// the mapStyleURL of (`customDayStyle`, `customNightStyle`) set in the AppDelegate for iOS
  String? navigationMapStyleUrl;

  /// Indicates whether to show the arrive dialog.
  /// If set to true, the arrive dialog will be shown when the user arrives at the waypoints or destination.
  /// If set to false, the arrive dialog will not be shown when the user arrives at the waypoints or destination.
  /// This property is only available for call [NBNavigation.startNavigation] to launch the navigation.
  /// It is not available for [NBNavigationView].If you want to show the arrive dialog in [NBNavigationView],
  /// you need to custom the dialog by yourself in the [NBNavigationView.onArriveAtWaypoint].
  bool? showArriveDialog;

  /// Indicates whether to show the speedometer.
  /// If set to true, the speedometer will be shown during navigation.
  /// If set to false, the speedometer will not be shown during navigation.
  bool? showSpeedometer;
  // double? maxNavCameraTilt;
  // double? minNavCameraTilt;
  // double? maxNavCameraZoom;
  // double? minNavCameraZoom;

  NavigationLauncherConfig({
    required this.route,
    required this.routes,
    this.themeMode = NavigationThemeMode.system,
    this.locationLayerRenderMode = LocationLayerRenderMode.gps,
    this.shouldSimulateRoute,
    this.enableDissolvedRouteLine = true,
    this.useCustomNavigationStyle = true,
    this.navigationMapStyleUrl,
    this.showArriveDialog = true,
    this.showSpeedometer = true,
    // this.maxNavCameraTilt,
    // this.minNavCameraTilt,
    // this.maxNavCameraZoom,
    // this.minNavCameraZoom,
  });

  Map<String, dynamic> toJson() {
    return {
      'route': jsonEncode(route),
      'routes': routes?.map((e) => jsonEncode(e)).toList(),
      'themeMode': themeMode?.description,
      'locationLayerRenderMode': locationLayerRenderMode?.index,
      'shouldSimulateRoute': shouldSimulateRoute,
      'enableDissolvedRouteLine': enableDissolvedRouteLine,
      'useCustomNavigationStyle': useCustomNavigationStyle,
      'navigationMapStyleUrl': navigationMapStyleUrl,
      'showArriveDialog': showArriveDialog,
      'showSpeedometer': showSpeedometer,
      // 'maxNavCameraTilt': maxNavCameraTilt,
      // 'minNavCameraTilt': minNavCameraTilt,
      // 'maxNavCameraZoom': maxNavCameraZoom,
      // 'minNavCameraZoom': minNavCameraZoom,
    };
  }
}
