part of '../nb_navigation_flutter.dart';

class MethodChannelNavigationView extends NBNavigationViewPlatform {
  MethodChannel? _channel;
  EventChannel? _eventChannel;

  static bool useHybridComposition = false;
  static const String viewType = 'FlutterNBNavigationView';
  static const StandardMessageCodec _decoder = StandardMessageCodec();

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onNavigationCancelling':
        _onNavigationCancellingCallback?.call();
      case 'onNavigationReady':
        _onNavigationRunningCallback?.call();
      case 'onArriveAtWaypoint':
        _arriveAtWaypointCallback?.call(_parseWaypoint(call.arguments));
      case 'willRerouteFromLocation':
        _rerouteFromLocationCallback?.call(_parseLocation(call.arguments));
      case 'onRerouteAlong':
        if (_rerouteAlongCallback != null) {
          if (call.arguments == null) {
            _rerouteAlongCallback!(null);
            return;
          }
          if (call.arguments is String || call.arguments is Map) {
            final Map<String, dynamic>? json = call.arguments is String
                ? jsonDecode(call.arguments as String) as Map<String, dynamic>?
                : _offlineMap(call.arguments);
            if (json != null) {
              _rerouteAlongCallback?.call(DirectionsRoute.fromJson(json));
            }
          }
          return;
        }
      case 'onRerouteFailure':
        _rerouteFailureCallback?.call(call.arguments as String?);
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
  Widget buildView(Map<String, dynamic> creationParams,
      OnPlatformViewCreatedCallback onPlatformViewCreated) {
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
  Stream<NavigationProgress?>? get navProgressListener => _eventChannel
      ?.receiveBroadcastStream()
      .map((dynamic progressMap) => _parseProgress(progressMap));

  NavigationProgress? _parseProgress(dynamic progressMap) {
    final jsonMap =
        jsonDecode(jsonEncode(progressMap)) as Map<String, dynamic>?;
    if (jsonMap != null) {
      return NavigationProgress.fromJson(jsonMap);
    }

    return null;
  }

  @override
  void setOnNavigationCancellingCallback(
      OnNavigationCancellingCallback? callback) {
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
  void setOnRerouteFromLocationCallback(
      OnRerouteFromLocationCallback? callback) {
    _rerouteFromLocationCallback = callback;
  }

  Waypoint? _parseWaypoint(dynamic waypointMap) {
    final jsonMap = jsonDecode(jsonEncode(waypointMap));
    if (jsonMap != null && jsonMap is Map<String, dynamic>) {
      return Waypoint.fromJson(jsonMap);
    }
    return null;
  }

  LatLng? _parseLocation(dynamic locationMap) {
    dynamic value = locationMap;
    if (value is String) {
      value = jsonDecode(value);
    }
    if (value is Map && value['location'] is Map) {
      value = value['location'];
    }
    if (value is Map<dynamic, dynamic>) {
      final jsonMap = value.cast<String, dynamic>();
      return LatLng(
        (jsonMap["latitude"] as num).toDouble(),
        (jsonMap["longitude"] as num).toDouble(),
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
        print(e);
      }
    } on MissingPluginException {
      // The platform view may already have been removed by the host lifecycle.
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
