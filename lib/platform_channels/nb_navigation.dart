part of '../nb_navigation_flutter.dart';

/// Stateless facade of the nextbillion navigation platform
mixin NBNavigation {
  static NBNavigationPlatform _nbNavigationPlatform =
      NBNavigationPlatform.instance;

  /// Initializes the NextBillion SDK with the provided [accessKey].
  static Future<void> initNextBillion(String accessKey) async {
    await NextBillion.initNextBillion(accessKey);
  }

  /// allow to set the [NBNavigationPlatform] for testing
  @visibleForTesting
  static void setNBNavigationPlatform(NBNavigationPlatform nbNavigationPlatform) {
    assert(() {
      _nbNavigationPlatform = nbNavigationPlatform;
      return true;
    }(), 'setLocalRootBundleForTesting should only be used in tests.');
  }

  /// Fetches a route based on the provided [routeRequestParams].
  /// The [routeResultCallBack] will be invoked with the result.
  static Future<DirectionsRouteResponse> fetchRoute(
      RouteRequestParams routeRequestParams) async {
    return await _nbNavigationPlatform.fetchRoute(routeRequestParams);
  }

  /// Starts the navigation using the provided [launcherConfig].
  static Future<void> startNavigation(
      NavigationLauncherConfig launcherConfig) async {
    await _nbNavigationPlatform.startNavigation(launcherConfig);
  }

  /// get the base url for navigation related api
  static Future<String?> getRoutingBaseUri() async {
    return await _nbNavigationPlatform.getRoutingBaseUri();
  }

  /// set the base url for navigation related api with the provided [baseUri]
  static Future<void> setRoutingBaseUri(String baseUri) async {
    await _nbNavigationPlatform.setRoutingBaseUri(baseUri);
  }

  /// Returns a formatted string representing a duration.
  ///
  /// This function takes a duration in seconds and returns a human-readable string
  /// that represents that duration. For example, if the duration is 65 seconds,
  /// this function will return "1 min 5 sec".
  ///
  /// @param durationSeconds The duration in seconds to format.
  /// @return A Future that completes with the formatted duration string.
  static Future<String?> getFormattedDuration(num durationSeconds) async {
    return await _nbNavigationPlatform.getFormattedDuration(durationSeconds);
  }

  static Future<void> setOnNavigationExitCallback(
      OnNavigationExitCallback navigationExitCallback) async {
    return await _nbNavigationPlatform
        .setOnNavigationExitCallback(navigationExitCallback);
  }

  /// Start preview navigation screen with given route
  static Future<void> startPreviewNavigation(DirectionsRoute route,
      {String? mapStyle, NavigationThemeMode? themeMode}) async {
    return await _nbNavigationPlatform.startPreviewNavigation(route,
        mapStyle: mapStyle);
  }

  /// Captures a symbol representing the duration of a route.
  ///
  /// This function takes a `DirectionsRoute` and a boolean indicating whether the route
  /// is the primary route. It then calls the `_nbNavigationPlatform.captureRouteDurationSymbol`
  /// method to capture a symbol representing the duration of the route.
  ///
  /// @param route The `DirectionsRoute` for which to capture a duration symbol.
  /// @param isPrimaryRoute A boolean indicating whether the route is the primary route.
  /// @return A Future that completes with the captured symbol as a `Uint8List`, or `null` if the capture failed.
  static Future<Uint8List?> captureRouteDurationSymbol(
      DirectionsRoute route, bool isPrimaryRoute) async {
    return await _nbNavigationPlatform.captureRouteDurationSymbol(
        route, isPrimaryRoute);
  }

  /// Captures a symbol representing the waypoints of a route.
  static Future<Uint8List?> captureRouteWaypoints(int waypointIndex) async {
    return await _nbNavigationPlatform.captureRouteWaypoints(waypointIndex);
  }

  /// Set the user ID for the current user if you need to add a user ID to the navigation request user-agent.
  static Future<void> setUserId(String userId) async {
    await NextBillion.setUserId(userId);
  }

  /// Get the user ID for the current user if you need to add a user ID to the navigation request user-agent.
  static Future<String?> getUserId() async {
    return await NextBillion.getUserId();
  }

  /// Get the NextBillion ID for the current user.
  static Future<String?> getNBId() async {
    return await NextBillion.getNbId();
  }
}
