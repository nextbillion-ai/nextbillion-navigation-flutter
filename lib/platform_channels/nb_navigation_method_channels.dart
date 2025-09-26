part of '../nb_navigation_flutter.dart';

class NBNavigationMethodChannel extends NBNavigationPlatform {
  MethodChannel _channel =
      NBNavigationMethodChannelsFactory.nbNavigationChannel;

  NBNavigationMethodChannel() {
    _channel.setMethodCallHandler(handleMethodCall);
  }

  @visibleForTesting
  void setMethodChannel(MethodChannel channel) {
    _channel = channel;
    _channel.setMethodCallHandler(handleMethodCall);
  }

  @visibleForTesting
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case NBNavigationLauncherMethodID.nbOnNavigationExit:
        final arguments = call.arguments;
        if (arguments is Map) {
          final bool? shouldRefreshRoute =
              arguments["shouldRefreshRoute"] as bool?;
          final int? remainingWaypoints =
              arguments["remainingWaypoints"] as int?;
          if (shouldRefreshRoute != null && remainingWaypoints != null) {
            navigationExitCallback?.call(
                arguments["shouldRefreshRoute"] as bool,
                arguments["remainingWaypoints"] as int);
          }
        }
      default:
        throw MissingPluginException();
    }
  }

  @override
  Future<DirectionsRouteResponse> fetchRoute(
      RouteRequestParams routeRequestParams) async {
    final dynamic result = await _channel.invokeMethod(
        NBRouteMethodID.nbFetchRouteMethod, jsonEncode(routeRequestParams));
    if (result is String) {
      final json = jsonDecode(result) as Map<String, dynamic>;
      return _handleRouteResult(json);
    } else if (result is Map) {
      final Map<String, dynamic> resultMap = Map<String, dynamic>.from(result);
      return _handleRouteResult(resultMap);
    } else {
      throw Exception("Unexpected result type: ${result.runtimeType}");
    }
  }

  DirectionsRouteResponse _handleRouteResult(Map<dynamic, dynamic> result) {
    final List<String> routeJson =
        List<String>.from(result["routeResult"] as List<dynamic>? ?? []);
    final int? errorCode = result["errorCode"] as int?;
    final String? message = result["message"] as String?;

    final Map<String, dynamic> routeRequest =
        (result["routeOptions"] as Map<Object?, Object?>?)?.map(
              (key, value) => MapEntry(key.toString(), value),
            ) ??
            {};

    RouteRequestParams? requestParams;
    if (routeRequest.isNotEmpty) {
      requestParams =
          RouteRequestParams.fromJson(Map<String, dynamic>.from(routeRequest));
    }

    final List<DirectionsRoute> routes = [];
    if (routeJson.isNotEmpty) {
      for (final json in routeJson) {
        final Map<String, dynamic> routeMap =
            jsonDecode(json) as Map<String, dynamic>;
        DirectionsRoute route;
        if (requestParams != null) {
          route = DirectionsRoute.fromJsonWithOption(routeMap, requestParams);
        } else {
          route = DirectionsRoute.fromJson(routeMap);
        }
        routes.add(route);
      }
    }
    return DirectionsRouteResponse(
        directionsRoutes: routes, message: message, errorCode: errorCode);
  }

  @override
  Future<void> startNavigation(NavigationLauncherConfig launcherConfig) async {
    try {
      final Map<String, dynamic> arguments = {};
      if (Platform.isIOS) {
        arguments["routeOptions"] =
            jsonEncode(launcherConfig.route.routeOptions);
      }
      arguments["launcherConfig"] = launcherConfig.toJson();
      await _channel.invokeMethod(
          NBNavigationLauncherMethodID.nbNavigationLauncherMethod, arguments);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Future<void> startPreviewNavigation(DirectionsRoute route,
      {String? mapStyle}) async {
    try {
      final Map<String, dynamic> arguments = {};
      if (Platform.isIOS) {
        arguments["routeOptions"] = jsonEncode(route.routeOptions);
      }
      arguments["route"] = jsonEncode(route);
      arguments["mapStyle"] = mapStyle;
      await _channel.invokeMethod(
          NBNavigationLauncherMethodID.nbPreviewNavigationMethod, arguments);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Future<int?> findSelectedRouteIndex(
      LatLng clickPoint, List<List<LatLng>> coordinates) async {
    final Map<String, dynamic> arguments = {};
    arguments["clickPoint"] = clickPoint.toJson();
    arguments["coordinates"] = coordinates
        .map((coordinate) => coordinate.map((point) => point.toJson()).toList())
        .toList();
    return await _channel.invokeMethod(
        NBRouteMethodID.nbRouteSelectedIndexMethod, arguments);
  }

  @override
  Future<String?> getRoutingBaseUri() async {
    return await _channel
        .invokeMethod(NBNavigationLauncherMethodID.nbGetNavigationUriMethod);
  }

  @override
  Future<void> setRoutingBaseUri(String baseUri) async {
    final Map<String, dynamic> arguments = {};
    arguments["navigationBaseUri"] = baseUri;
    try {
      await _channel.invokeMethod(
          NBNavigationLauncherMethodID.nbSetNavigationUriMethod, arguments);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Future<String?> getFormattedDuration(num durationSeconds) async {
    try {
      return await _channel.invokeMethod(NBRouteMethodID.routeFormattedDuration,
          {"duration": durationSeconds.toDouble()});
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return "";
  }

  @override
  Future<void> setOnNavigationExitCallback(
      OnNavigationExitCallback navigationExitCallback) async {
    try {
      this.navigationExitCallback = navigationExitCallback;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Future<Uint8List?> captureRouteDurationSymbol(
      DirectionsRoute route, bool isPrimaryRoute) async {
    try {
      return await _channel.invokeMethod(
          NBRouteMethodID.navigationCaptureRouteDurationSymbol, {
        "duration": route.duration?.toDouble() ?? 0,
        "isPrimaryRoute": isPrimaryRoute
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return null;
  }

  @override
  Future<Uint8List?> captureRouteWaypoints(int waypointIndex) async {
    try {
      return await _channel.invokeMethod(
          NBRouteMethodID.navigationCaptureRouteWaypoints,
          {"waypointIndex": waypointIndex});
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return null;
  }
}
