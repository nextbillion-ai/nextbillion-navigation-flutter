part of nb_navigation_flutter;

class NBNavigationMethodChannel extends NBNavigationPlatform {
  MethodChannel _channel =
      NBNavigationMethodChannelsFactory.nbNavigationChannel;

  NBNavigationMethodChannel() {
    _channel.setMethodCallHandler(handleMethodCall);
  }

  @visibleForTesting
  void setMethodChanenl(MethodChannel channel) {
    _channel = channel;
    _channel.setMethodCallHandler(handleMethodCall);
  }

  @visibleForTesting
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case NBNavigationLauncherMethodID.nbOnNavigationExit:
        var arguments = call.arguments;
        bool? shouldRefreshRoute = arguments["shouldRefreshRoute"];
        int? remainingWaypoints = arguments["remainingWaypoints"];
        if (shouldRefreshRoute != null && remainingWaypoints != null) {
          navigationExitCallback?.call(
              arguments["shouldRefreshRoute"], arguments["remainingWaypoints"]);
        }
        break;
      default:
        throw MissingPluginException();
    }
  }

  @override
  Future<DirectionsRouteResponse> fetchRoute(
      RouteRequestParams routeRequestParams) async {
    Map<dynamic, dynamic> result = await _channel.invokeMethod(
        NBRouteMethodID.nbFetchRouteMethod, jsonEncode(routeRequestParams));
    return _handleRouteResult(result);
  }

  DirectionsRouteResponse _handleRouteResult(Map<dynamic, dynamic> result) {
    List<String> routeJson = List<String>.from(result["routeResult"] ?? []);
    int? errorCode = result["errorCode"];
    String? message = result["message"];
    Map<dynamic, dynamic> routeRequest = result["routeOptions"] ?? {};
    RouteRequestParams? requestParams;

    if (routeRequest.isNotEmpty) {
      requestParams =
          RouteRequestParams.fromJson(json.decode(json.encode(routeRequest)));
    }

    List<DirectionsRoute> routes = [];
    if (routeJson.isNotEmpty) {
      for (var json in routeJson) {
        DirectionsRoute route = DirectionsRoute.fromJson(jsonDecode(json));
        if (requestParams != null) {
          route.routeOptions = requestParams;
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
      Map<String, dynamic> arguments = {};
      if (Platform.isIOS) {
        arguments["routeOptions"] =
            jsonEncode(launcherConfig.route.routeOptions);
      }
      arguments["launcherConfig"] = launcherConfig.toJson();
      await _channel.invokeMethod(
          NBNavigationLauncherMethodID.nbNavigationLauncherMethod, arguments);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  Future<void> startPreviewNavigation(DirectionsRoute route) async {
    try {
      Map<String, dynamic> arguments = {};
      if (Platform.isIOS) {
        arguments["routeOptions"] = jsonEncode(route.routeOptions);
      }
      arguments["route"] = jsonEncode(route);

      await _channel.invokeMethod(
          NBNavigationLauncherMethodID.nbPreviewNavigationMethod, arguments);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  Future<int> findSelectedRouteIndex(
      LatLng clickPoint, List<List<LatLng>> coordinates) async {
    Map<String, dynamic> arguments = {};
    arguments["clickPoint"] = clickPoint.toJson();
    arguments["coordinates"] = coordinates
        .map((coordinate) => coordinate.map((point) => point.toJson()).toList())
        .toList();
    return await _channel.invokeMethod(
        NBRouteMethodID.nbRouteSelectedIndexMethod, arguments);
  }

  @override
  Future<String> getRoutingBaseUri() async {
    return await _channel
        .invokeMethod(NBNavigationLauncherMethodID.nbGetNavigationUriMethod);
  }

  @override
  Future<void> setRoutingBaseUri(String baseUri) async {
    Map<String, dynamic> arguments = {};
    arguments["navigationBaseUri"] = baseUri;
    try {
      await _channel.invokeMethod(
          NBNavigationLauncherMethodID.nbSetNavigationUriMethod, arguments);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  Future<String> getFormattedDuration(num durationSeconds) async {
    try {
      return await _channel.invokeMethod(NBRouteMethodID.routeFormattedDuration,
          {"duration": durationSeconds.toDouble()});
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e.toString());
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
        print(e.toString());
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
        print(e.toString());
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
        print(e.toString());
      }
    }
    return null;
  }
}
