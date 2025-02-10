part of nb_navigation_flutter;

typedef OnNavigationExitCallback = void Function(
    bool shouldRefreshRoute, int remainingWaypoints);

abstract class NBNavigationPlatform {
  static final NBNavigationPlatform _instance = NBNavigationMethodChannel();

  static NBNavigationPlatform get instance => _instance;

  OnNavigationExitCallback? navigationExitCallback;

  Future<DirectionsRouteResponse> fetchRoute(
      RouteRequestParams routeRequestParams);

  Future<void> startNavigation(NavigationLauncherConfig launcherConfig);

  Future<void> startPreviewNavigation(DirectionsRoute route);

  Future<String> getRoutingBaseUri();

  Future<void> setRoutingBaseUri(String baseUri);

  Future<int> findSelectedRouteIndex(
      LatLng clickPoint, List<List<LatLng>> coordinates);

  Future<String> getFormattedDuration(num durationSeconds);

  Future<void> setOnNavigationExitCallback(
      OnNavigationExitCallback navigationExitCallback);

  Future<Uint8List?> captureRouteDurationSymbol(
      DirectionsRoute route, bool isPrimaryRoute);

  Future<Uint8List?> captureRouteWaypoints(int waypointIndex);
}
