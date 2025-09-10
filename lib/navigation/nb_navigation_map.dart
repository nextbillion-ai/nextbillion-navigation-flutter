part of '../nb_navigation_flutter.dart';

typedef OnRouteSelectedCallback = void Function(int selectedRouteIndex);

class NavNextBillionMap implements NavigationMap {
  late MapController controller;
  late IAssetManager assetManager;

  MapRouteLayerProvider routeLayerProvider = MapRouteLayerProvider();
  Map<String, LayerProperties> routeLayers = {};

  RouteLineProperties routeLineProperties;
  List<List<LatLng>> routeLines = [];

  OnRouteSelectedCallback? _onRouteSelectedCallback;
  OnRouteSelectedCallback? get onRerouteFailureCallback =>
      _onRouteSelectedCallback;

  bool _isIndependentRoute = false;
  int _primaryRouteIndex = 0;
  final List<DirectionsRoute> _routes = [];

  NavNextBillionMap._create(this.controller,
      {this.routeLineProperties = const RouteLineProperties()});

  static Future<NavNextBillionMap> create(NextbillionMapController controller,
      {RouteLineProperties routeLineProperties =
          const RouteLineProperties()}) async {
    final MapController mapController = NextbillionMapControllerWrapper(controller);
    final navMap = NavNextBillionMap._create(mapController,
        routeLineProperties: routeLineProperties);
    navMap.assetManager = AssetManager();
    await navMap.initGeoJsonSource();
    return navMap;
  }

  @visibleForTesting
  static Future<NavNextBillionMap> createWithAssetManager(
      MapController mapController, IAssetManager assetManager,
      {RouteLineProperties routeLineProperties =
          const RouteLineProperties()}) async {
    final navMap = NavNextBillionMap._create(mapController,
        routeLineProperties: routeLineProperties);
    navMap.assetManager = assetManager;
    await navMap.initGeoJsonSource();
    return navMap;
  }

  @override
  Future<void> initGeoJsonSource() async {
    if (controller.disposed) {
      return;
    }
    await _removePreviousSource();
    await _prepareSources();
    await _loadAssetImage();
    await initRouteLayers();
    _addListeners();
  }

  Future<void> _removePreviousSource() async {
    if (controller.disposed) {
      return;
    }
    await safeRemoveLayer(routeShieldLayerId);
    await safeRemoveLayer(routeLayerId);
    await safeRemoveLayer(waypointLayerId);
    await safeRemoveLayer(routeDurationLayerId);

    await safeRemoveSource(routeShieldSourceId);
    await safeRemoveSource(routeSourceId);
    await safeRemoveSource(waypointSourceId);
    await safeRemoveSource(routeDurationSourceId);
  }

  Future<void> _prepareSources() async {
    if (controller.disposed) {
      return;
    }

    await safeAddGeoJsonSource(routeShieldSourceId, buildFeatureCollection([]));
    await safeAddGeoJsonSource(routeSourceId, buildFeatureCollection([]));
    await safeAddGeoJsonSource(waypointSourceId, buildFeatureCollection([]));
    await safeAddGeoJsonSource(
        routeDurationSourceId, buildFeatureCollection([]));
  }

  Future<void> _loadAssetImage() async {
    if (controller.disposed) {
      return;
    }
    final origin = await assetManager.load(routeLineProperties.originMarkerName);
    if (controller.disposed) {
      return;
    }
    final destination =
        await assetManager.load(routeLineProperties.destinationMarkerName);
    if (controller.disposed) {
      return;
    }
    await controller.addImage(originMarkerName, origin);
    if (controller.disposed) {
      return;
    }
    await controller.addImage(destinationMarkerName, destination);
  }

  /// add route shield layer, route layer, waypoint layer and route duration layer
  @override
  Future<void> initRouteLayers() async {
    if (controller.disposed) {
      return;
    }
    final String? belowLayer = await controller.findBelowLayerId(
        [nbmapLocationId, highwayShieldLayerId, nbmapAnnotationId]);

    final LineLayerProperties routeShieldLayer =
        routeLayerProvider.initializeRouteShieldLayer(
      routeLineProperties.routeScale,
      routeLineProperties.alternativeRouteScale,
      routeLineProperties.routeShieldColor,
      routeLineProperties.alternativeRouteShieldColor,
    );

    if (controller.disposed) {
      return;
    }
    await controller.addLineLayer(
        routeShieldSourceId, routeShieldLayerId, routeShieldLayer,
        belowLayerId: belowLayer);

    routeLayers[routeShieldLayerId] = routeShieldLayer;

    final LineLayerProperties routeLayer = routeLayerProvider.initializeRouteLayer(
      routeLineProperties.routeScale,
      routeLineProperties.alternativeRouteScale,
      routeLineProperties.routeDefaultColor,
      routeLineProperties.alternativeRouteDefaultColor,
      routeLineProperties.routeModerateColor,
      routeLineProperties.routeHeavyColor,
      routeLineProperties.routeSevereColor,
      routeLineProperties.alternativeRouteModerateColor,
      routeLineProperties.alternativeRouteHeavyColor,
      routeLineProperties.alternativeRouteSevereColor,
    );

    if (controller.disposed) {
      return;
    }
    await controller.addLineLayer(routeSourceId, routeLayerId, routeLayer,
        belowLayerId: belowLayer);

    routeLayers[routeLayerId] = routeLayer;

    final SymbolLayerProperties wayPointLayer = routeLayerProvider
        .initializeWayPointLayer(originMarkerName, destinationMarkerName);
    if (controller.disposed) {
      return;
    }
    await controller.addSymbolLayer(
        waypointSourceId, waypointLayerId, wayPointLayer);

    final SymbolLayerProperties durationSymbolLayer =
        routeLayerProvider.initializeDurationSymbolLayer();

    if (controller.disposed) {
      return;
    }
    await controller.addSymbolLayer(
        routeDurationSourceId, routeDurationLayerId, durationSymbolLayer,
        belowLayerId: nbmapWaynameLayer);

    routeLayers[routeDurationLayerId] = durationSymbolLayer;
  }

  /// Draws the route on the map based on the provided [routes].
  /// it clears the previous route before drawing the new one.
  /// and then draws the route line, waypoints, and route duration symbol.
  /// The [primaryRouteIndex] parameter is used to determine the primary route to be drawn. Default is 0.
  @override
  Future<void> drawRoute(List<DirectionsRoute> routes,
      {int primaryRouteIndex = 0}) async {
    assert(primaryRouteIndex >= 0 && primaryRouteIndex < routes.length,
        "primaryRouteIndex should be between 0 and routes.length - 1 inclusive.");

    if (controller.disposed) {
      return;
    }

    if (routes.isEmpty) {
      return;
    }

    await clearRoute();
    _routes.addAll(routes);
    _primaryRouteIndex = primaryRouteIndex;
    _isIndependentRoute = false;
    await _drawRoutesFeatureCollections();
    await _drawWayPoints();
    await _drawRouteDurationSymbol();
  }

  /// Draws the route on the map based on the provided [routes].
  /// it clears the previous route before drawing the new one.
  /// and then draws the route line, waypoints, and route duration symbol.
  /// This method is used when there are multiple origin and destination routes.
  /// The [primaryRouteIndex] parameter is used to determine the primary route to be drawn. Default is 0.
  @override
  Future<void> drawIndependentRoutes(List<DirectionsRoute> routes,
      {int primaryRouteIndex = 0}) async {
    assert(primaryRouteIndex >= 0 && primaryRouteIndex < routes.length,
        "primaryRouteIndex should be between 0 and routes.length - 1 inclusive.");

    if (controller.disposed) {
      return;
    }

    if (routes.isEmpty) {
      return;
    }

    await clearRoute();
    _routes.addAll(routes);
    _primaryRouteIndex = primaryRouteIndex;
    _isIndependentRoute = true;
    await _drawRoutesFeatureCollections();
    await _drawWayPointsWithRoutes();
    await _drawRouteDurationSymbol();
  }

  Future<void> _drawRoutesFeatureCollections() async {
    if (controller.disposed) {
      return;
    }
    final List<Map<String, dynamic>> routeLineFeatures = [];
    final List<Map<String, dynamic>> primaryRouteFeatures = [];

    for (int i = 0; i < _routes.length; i++) {
      final DirectionsRoute route = _routes[i];
      final bool isPrimary = i == _primaryRouteIndex;

      final List<Map<String, dynamic>> geoJson =
          _buildCongestionFeatureCollection(route, isPrimary);

      if (isPrimary) {
        primaryRouteFeatures.addAll(geoJson);
      } else {
        routeLineFeatures.addAll(geoJson);
      }
    }

    // Add the primary route's GeoJSON features at the beginning
    routeLineFeatures.insertAll(0, primaryRouteFeatures);

    if (routeLineFeatures.isEmpty) {
      return;
    }

    final List<Map<String, dynamic>> reversed = routeLineFeatures.reversed.toList();
    await safeSetGeoJsonSource(
        routeShieldSourceId, buildFeatureCollection(reversed));
    await safeSetGeoJsonSource(routeSourceId, buildFeatureCollection(reversed));
  }

  List<Map<String, dynamic>> _buildCongestionFeatureCollection(
      DirectionsRoute route, bool isPrimary) {
    final List<Map<String, dynamic>> routeCollectionFeatures = [];
    final List<LatLng> line =
        decode(route.geometry ?? '', _getDecodePrecision(route.routeOptions));
    routeLines.add(line);
    // LineOptions lineOptions = LineOptions(geometry: line);
    // Map<String, dynamic> geoJson = Line("routeLine", lineOptions).toGeoJson();
    // routeCollectionFeatures.add(geoJson);

    // geoJson["properties"][primaryRoutePropertyKey] = isPrimary ? "true" : "false";
    final List<Map<String, dynamic>> congestionGeoJson =
        _buildCongestionFeatureFromRoute(line, route.congestion, isPrimary);
    routeCollectionFeatures.addAll(congestionGeoJson);
    return routeCollectionFeatures;
  }

  List<Map<String, dynamic>> _buildCongestionFeatureFromRoute(
    List<LatLng> coordinates,
    List<CongestionLevel>? congestion,
    bool isPrimary,
  ) {
    final List<Map<String, dynamic>> congestionFeatures = [];

    if (congestion == null ||
        congestion.isEmpty ||
        congestion.length > coordinates.length - 1) {
      final Map<String, dynamic> json =
          Line("routeLine", LineOptions(geometry: coordinates)).toGeoJson();
      final Map<String, dynamic> properties = json["properties"] as Map<String, dynamic>;
      properties[primaryRoutePropertyKey] = isPrimary ? "true" : "false";
      json["properties"] = properties;
      congestionFeatures.add(json);
      return congestionFeatures;
    }

    List<LatLng> segmentCoordinates = [coordinates[0]];
    CongestionLevel currentCongestionLevel = congestion[0];

    for (int i = 0; i < congestion.length; i++) {
      final CongestionLevel congestionLevel = congestion[i];
      segmentCoordinates.add(coordinates[i + 1]);

      if (i == congestion.length - 1 ||
          currentCongestionLevel != congestionLevel) {
        final Map<String, dynamic> geoJson =
            Line("routeLine", LineOptions(geometry: segmentCoordinates))
                .toGeoJson();
        geoJson["properties"] = {
          congestionPropertyKey: currentCongestionLevel.description,
          primaryRoutePropertyKey: isPrimary.toString()
        };
        congestionFeatures.add(geoJson);

        if (i != congestion.length - 1) {
          segmentCoordinates = [coordinates[i + 1]];
          currentCongestionLevel = congestionLevel;
        }
      }
    }

    return congestionFeatures;
  }

  int _getDecodePrecision(RouteRequestParams? routeOptions) {
    return routeOptions?.geometry == SupportedGeometry.polyline
        ? precision
        : precision6;
  }

  Future<void> _drawWayPoints() async {
    if (controller.disposed) {
      return;
    }
    if (_routes.isEmpty) {
      return;
    }
    final route = _routes[_primaryRouteIndex];
    final List<Map<String, dynamic>> wayPoints = [];
    final Coordinate origin = route.legs.first.steps!.first.maneuver!.coordinate!;
    final Coordinate destination = route.legs.last.steps!.last.maneuver!.coordinate!;
    final originGeo = _generateWaypointSymbolGeo(origin, originMarkerName);
    wayPoints.add(originGeo);

    if (route.legs.length > 1) {
      for (int i = 0; i < route.legs.length - 1; i++) {
        final Leg leg = route.legs[i];
        final Coordinate? destination = leg.steps?.last.maneuver?.coordinate;
        if (destination != null) {
          final String waypointName = "$destinationMarkerName${i + 1}";
          final wayPointGeo =
              _generateWaypointSymbolGeo(destination, waypointName);
          wayPoints.add(wayPointGeo);
          if (controller.disposed) {
            return;
          }
          await _buildWaypointNumberView(waypointName, i + 1);
        }
      }
    }

    final desGeo = _generateWaypointSymbolGeo(destination, destinationMarkerName);
    wayPoints.add(desGeo);

    await safeSetGeoJsonSource(
        waypointSourceId, buildFeatureCollection(wayPoints));
  }

  Future<void> _drawWayPointsWithRoutes() async {
    if (controller.disposed) {
      return;
    }

    final List<Map<String, dynamic>> wayPoints = [];
    final DirectionsRoute primaryRoute = _routes[_primaryRouteIndex];
    final Coordinate origin =
        primaryRoute.legs.first.steps!.first.maneuver!.coordinate!;
    final Coordinate destination =
        primaryRoute.legs.last.steps!.last.maneuver!.coordinate!;

    _addWaypoint(wayPoints, origin, originMarkerName);
    _addIntermediaryWaypoints(wayPoints, primaryRoute);
    _addWaypoint(wayPoints, destination, destinationMarkerName);

    for (final route in _routes) {
      final Coordinate? startCoordinate =
          route.legs.first.steps?.first.maneuver?.coordinate;
      final Coordinate? endCoordinate =
          route.legs.last.steps?.last.maneuver?.coordinate;

      if (!_coordinatesEqual(startCoordinate, origin)) {
        _addWaypoint(wayPoints, startCoordinate, originMarkerName);
      }

      if (!_coordinatesEqual(endCoordinate, destination)) {
        _addWaypoint(wayPoints, endCoordinate, destinationMarkerName);
      }
    }

    await safeSetGeoJsonSource(
        waypointSourceId, buildFeatureCollection(wayPoints));
  }

  void _addWaypoint(List<Map<String, dynamic>> wayPoints,
      Coordinate? coordinate, String markerName) {
    if (coordinate != null) {
      final waypointGeo = _generateWaypointSymbolGeo(coordinate, markerName);
      wayPoints.add(waypointGeo);
    }
  }

  Future<void> _addIntermediaryWaypoints(
      List<Map<String, dynamic>> wayPoints, DirectionsRoute route) async {
    for (int i = 0; i < route.legs.length - 1; i++) {
      final Leg leg = route.legs[i];
      final Coordinate? destination = leg.steps?.last.maneuver?.coordinate;
      if (destination != null) {
        final String waypointName = "$destinationMarkerName${i + 1}";
        _addWaypoint(wayPoints, destination, waypointName);
        if (controller.disposed) {
          return;
        }
        await _buildWaypointNumberView(waypointName, i + 1);
      }
    }
  }

  bool _coordinatesEqual(Coordinate? coord1, Coordinate? coord2) {
    if (coord1 == null || coord2 == null) {
      return false;
    }
    return coord1.latitude == coord2.latitude &&
        coord1.longitude == coord2.longitude;
  }

  Map<String, dynamic> _generateWaypointSymbolGeo(
      Coordinate coordinate, String propertiesValue) {
    final SymbolOptions coordinateSymbol = SymbolOptions(
        geometry: LatLng(coordinate.latitude, coordinate.longitude));
    final Map<String, dynamic> coordinateGeo = coordinateSymbol.toGeoJson();
    final Map<String, dynamic> properties = coordinateGeo["properties"] as Map<String, dynamic>;
    properties[waypointPropertyKey] = propertiesValue;
    coordinateGeo["properties"] = properties;
    return coordinateGeo;
  }

  Future<void> _buildWaypointNumberView(String waypointName, int index) async {
    if (controller.disposed) {
      return;
    }
    final image = await NBNavigation.captureRouteWaypoints(index);
    if (controller.disposed) {
      return;
    }
    if (image != null) {
      await controller.addImage(waypointName, image);
    }
  }

  Future<void> _drawRouteDurationSymbol() async {
    if (controller.disposed) {
      return;
    }
    final List<Map<String, dynamic>> durationSymbols = [];
    for (int i = 0; i < _routes.length; i++) {
      final DirectionsRoute route = _routes[i];
      final bool isPrimary = i == _primaryRouteIndex;
      final List<LatLng> line =
          decode(route.geometry ?? '', _getDecodePrecision(route.routeOptions));
      final LatLng centerPoint = line[line.length ~/ 2];
      final SymbolOptions durationSymbol = SymbolOptions(
          geometry: LatLng(centerPoint.latitude, centerPoint.longitude));
      final Map<String, dynamic> geoJson = durationSymbol.toGeoJson();
      final Map<String, dynamic> properties = geoJson["properties"] as Map<String, dynamic>;
      properties[primaryRoutePropertyKey] =
          isPrimary ? "true" : "false";
      final String durationSymbolKey = "ROUTE_DURATION_SYMBOL_ICON_KEY$i";
      properties[routeDurationSymbolIconKey] = durationSymbolKey;
      geoJson["properties"] = properties;
      durationSymbols.add(geoJson);
      if (controller.disposed) {
        return;
      }
      await _setRouteDurationSymbol(durationSymbolKey, i, route);
    }
    await safeSetGeoJsonSource(
        routeDurationSourceId, buildFeatureCollection(durationSymbols));
  }

  Future<void> _setRouteDurationSymbol(
      String durationSymbolKey, int index, DirectionsRoute route) async {
    if (controller.disposed) {
      return;
    }
    final image = await NBNavigation.captureRouteDurationSymbol(
        route, index == _primaryRouteIndex);

    if (controller.disposed) {
      return;
    }
    if (image != null) {
      await controller.addImage(durationSymbolKey, image);
    }
  }

  /// Adds a listener for route selection.
  /// The [clickedPoint] represents the point clicked on the map.
  /// The [onRouteSelectedCallback] will be invoked when a route is selected.
  @override
  void addRouteSelectedListener(
      OnRouteSelectedCallback onRouteSelectedCallback) {
    _onRouteSelectedCallback = onRouteSelectedCallback;
  }

  /// Removes the listener for route selection.
  @override
  void removeRouteSelectedListener() {
    _onRouteSelectedCallback = null;
  }

  /// Toggles the visibility of alternative routes on the map.
  /// The [alternativeVisible] parameter determines whether alternative routes should be visible or not.
  @override
  Future<void> toggleAlternativeVisibilityWith(bool alternativeVisible) async {
    if (controller.disposed) {
      return;
    }

    for (final entry in routeLayers.entries) {
      if (entry.key == routeShieldLayerId ||
          entry.key == routeLayerId ||
          entry.key == routeDurationLayerId) {
        if (alternativeVisible) {
          if (controller.disposed) {
            return;
          }
          Platform.isIOS
              ? await controller
                  .setFilter(entry.key, ['<=', primaryRoutePropertyKey, 'true'])
              : await controller.setFilter(entry.key, ['literal', true]);
        } else {
          if (controller.disposed) {
            return;
          }
          await controller
              .setFilter(entry.key, ['==', primaryRoutePropertyKey, 'true']);
        }
      }
    }
  }

  /// Toggles the visibility of the duration symbol on the map.
  /// The [durationSymbolVisible] parameter determines whether the duration symbol should be visible or not.
  @override
  void toggleDurationSymbolVisibilityWith(bool durationSymbolVisible) {
    if (controller.disposed) {
      return;
    }
    controller.setVisibility(routeDurationLayerId, durationSymbolVisible);
  }

  /// Clears the currently displayed route from the map.
  @override
  Future<void> clearRoute() async {
    await clearSources();
    routeLines.clear();
    _primaryRouteIndex = 0;
    _routes.clear();
    _isIndependentRoute = false;
  }

  Future<void> clearSources() async {
    if (controller.disposed) {
      return;
    }
    await safeSetGeoJsonSource(routeShieldSourceId, buildFeatureCollection([]));
    await safeSetGeoJsonSource(routeSourceId, buildFeatureCollection([]));
    await safeSetGeoJsonSource(waypointSourceId, buildFeatureCollection([]));
    await safeSetGeoJsonSource(
        routeDurationSourceId, buildFeatureCollection([]));
  }

  void _addListeners() {
    if (controller.disposed) {
      return;
    }
    controller.onFeatureTapped.add((id, point, coordinates) {
      if (id == "routeLine") {
        _findRouteSelectedIndex(coordinates);
      }
    });
  }

  void _findRouteSelectedIndex(LatLng clickedPoint) {
    if (routeLines.length < 2) {
      return;
    }
    NBNavigationPlatform.instance
        .findSelectedRouteIndex(clickedPoint, routeLines)
        .then((routeIndex) {
      if (routeIndex != null && routeIndex != _primaryRouteIndex) {
        if (routeIndex >= 0 && routeIndex < routeLines.length) {
          _primaryRouteIndex = routeIndex;
        }
        if (_isIndependentRoute) {
          drawIndependentRoutes(List.from(_routes),
              primaryRouteIndex: _primaryRouteIndex);
        } else {
          drawRoute(List.from(_routes), primaryRouteIndex: _primaryRouteIndex);
        }
        if (_onRouteSelectedCallback != null) {
          _onRouteSelectedCallback?.call(routeIndex);
        }
      }
    });
  }

  Future safeRemoveLayer(String layerId) async {
    if (!controller.disposed) {
      await controller.removeLayer(layerId);
    }
  }

  Future safeRemoveSource(String sourceId) async {
    if (!controller.disposed) {
      await controller.removeSource(sourceId);
    }
  }

  Future safeAddGeoJsonSource(
      String sourceId, Map<String, dynamic> geoJson) async {
    if (!controller.disposed) {
      await controller.addGeoJsonSource(sourceId, geoJson);
    }
  }

  Future safeSetGeoJsonSource(
      String sourceId, Map<String, dynamic> geoJson) async {
    if (!controller.disposed) {
      await controller.setGeoJsonSource(sourceId, geoJson);
    }
  }

  /// Returns the primary route index.
  int retrievePrimaryRouteIndex() {
    return _primaryRouteIndex;
  }

  /// Returns the list of routes.
  List<DirectionsRoute> retrieveRoutes() {
    return _routes;
  }
}
