part of nb_navigation_flutter;

class MethodChannelNavigationView extends NBNavigationViewPlatform {
  MethodChannel? _channel;
  EventChannel? _eventChannel;

  static bool useHybridComposition = false;
  static const String viewType = 'FlutterNBNavigationView';
  static const StandardMessageCodec _decoder = StandardMessageCodec();

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onNavigationCancelling':
        if (_onNavigationCancellingCallback != null) {
          _onNavigationCancellingCallback!();
        }
        break;
      case 'onNavigationReady':
        if (_onNavigationRunningCallback != null) {
          _onNavigationRunningCallback!();
        }
        break;
      case 'onArriveAtWaypoint':
        if (_arriveAtWaypointCallback != null) {
          _arriveAtWaypointCallback!(_parseWaypoint(call.arguments));
        }
        break;
      case 'willRerouteFromLocation':
        if (_rerouteFromLocationCallback != null) {
          _rerouteFromLocationCallback!(_parseLocation(call.arguments));
        }
        break;
      case 'onRerouteAlong':
        if (_rerouteAlongCallback != null) {
          if (call.arguments == null) {
            _rerouteAlongCallback!(null);
            return;
          }
          Map<String, dynamic> json = jsonDecode(call.arguments);
          _rerouteAlongCallback!(DirectionsRoute.fromJson(json));
        }
        break;
      case 'onRerouteFailure':
        if (_rerouteFailureCallback != null) {
          _rerouteFailureCallback!(call.arguments);
        }
        break;
      default:
        throw MissingPluginException();
    }
  }

  @override
  Future<void> initPlatform(int id) async {
    _channel = MethodChannel('flutter_nb_navigation/$id');
    _eventChannel = EventChannel('flutter_nb_navigation/$id/events');
    _channel?.setMethodCallHandler(handleMethodCall);
  }

  @visibleForTesting
  MethodChannel? getMethodChannel() => _channel;

  @visibleForTesting
  EventChannel? getEventChannel() => _eventChannel;

  @override
  Widget buildView(Map<String, dynamic> creationParams, OnPlatformViewCreatedCallback onPlatformViewCreated) {
    if (Platform.isAndroid) {
      return PlatformViewLink(
        viewType: viewType,
        surfaceFactory: (context, controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (params) {
          return PlatformViewsService.initExpensiveAndroidView(
            id: params.id,
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () {
              params.onFocusChanged(true);
            },
          )
            ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
            ..addOnPlatformViewCreatedListener(onPlatformViewCreated)
            ..create();
        },
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: viewType,
        onPlatformViewCreated: onPlatformViewCreated,
        creationParams: creationParams,
        creationParamsCodec: _decoder,
      );
    } else {
      return Container();
    }
  }

  @override
  Stream<NavigationProgress?>? get navProgressListener =>
      _eventChannel?.receiveBroadcastStream().map((dynamic progressMap) => _parseProgress(progressMap));

  NavigationProgress? _parseProgress(Map<dynamic, dynamic>? progressMap) {
    var jsonMap = jsonDecode(jsonEncode(progressMap));
    if (progressMap != null) {
      return NavigationProgress.fromJson(jsonMap);
    }
    return null;
  }

  @override
  void setOnNavigationCancellingCallback(OnNavigationCancellingCallback? callback) {
    _onNavigationCancellingCallback = callback;
  }

  @override
  void setOnNavigationRunningCallback(OnNavigationRunningCallback? callback) {
    _onNavigationRunningCallback = callback;
  }

  @override
  void setOnArriveAtWaypointCallback(OnArriveAtWaypointCallback? callback) {
    _arriveAtWaypointCallback = callback;
  }

  @override
  void setOnRerouteFromLocationCallback(OnRerouteFromLocationCallback? callback) {
    _rerouteFromLocationCallback = callback;
  }

  Waypoint? _parseWaypoint(Map<dynamic, dynamic>? waypointMap) {
    var jsonMap = jsonDecode(jsonEncode(waypointMap));
    if (waypointMap != null) {
      return Waypoint.fromJson(jsonMap);
    }
    return null;
  }

  LatLng? _parseLocation(Map<dynamic, dynamic>? locationMap) {
    var jsonMap = jsonDecode(jsonEncode(locationMap));
    if (locationMap != null) {
      return LatLng(
        jsonMap['location']["latitude"],
        jsonMap['location']["longitude"],
      );
    }
    return null;
  }

  @override
  Future<void> stopNavigation() async {
    try {
      await _channel?.invokeMethod("stopNavigation");
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    _channel = null;
    _eventChannel = null;
  }

  @override
  void setOnRerouteAlongCallback(OnRerouteAlongCallback? callback) {
    _rerouteAlongCallback = callback;
  }

  @override
  void setOnRerouteFailureCallback(OnRerouteFailureCallback? callback) {
    _rerouteFailureCallback = callback;
  }
}
