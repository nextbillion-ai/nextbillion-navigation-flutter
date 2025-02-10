import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

abstract class NavigationMap {
  Future<void> initGeoJsonSource();
  Future<void> initRouteLayers();

  /// Draws the route on the map based on the provided [routes].
  /// it clears the previous route before drawing the new one.
  /// and then draws the route line, waypoints, and route duration symbol.
  Future<void> drawRoute(List<DirectionsRoute> routes);

  /// Draws the route on the map based on the provided [routes].
  /// it clears the previous route before drawing the new one.
  /// and then draws the route line, waypoints, and route duration symbol.
  /// This method is used when there are multiple origin and destination routes.
  Future<void> drawIndependentRoutes(List<DirectionsRoute> routes);

  /// Clears the routes from the map.
  Future<void> clearRoute();

  /// Toggles the visibility of the route duration symbol.
  void toggleDurationSymbolVisibilityWith(bool durationSymbolVisible);

  /// Toggles the visibility of the alternative routes.
  Future<void> toggleAlternativeVisibilityWith(bool alternativeVisible);

  /// Adds a listener to the map to listen for route selection.
  void addRouteSelectedListener(
      LatLng clickedPoint, OnRouteSelectedCallback onRouteSelectedCallback);
}
