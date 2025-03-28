import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

import 'nb_navigation_test.mocks.dart';

// ignore_for_file: unnecessary_string_interpolations
@GenerateMocks([NBNavigationPlatform, MethodChannel])
void main() {
  late NBNavigationPlatform mockNBNavigationPlatform;

  setUp(() {
    mockNBNavigationPlatform = MockNBNavigationPlatform();
    NBNavigation.setNBNavigationPlatform(mockNBNavigationPlatform);
  });

  test('fetchRoute should return DirectionsRouteResponse', () async {
    const origin = LatLng(1.312533169133601, 103.75986708439264);
    const dest = LatLng(1.310473772283314, 103.77982271935586);
    final routeRequestParams =
        RouteRequestParams(origin: origin, destination: dest);
    final expectedResponse = DirectionsRouteResponse(
      directionsRoutes: [],
      message: 'Test message',
      errorCode: 0,
    );

    when(mockNBNavigationPlatform.fetchRoute(routeRequestParams))
        .thenAnswer((_) async => expectedResponse);

    final response = await NBNavigation.fetchRoute(routeRequestParams);

    expect(response.message, equals(expectedResponse.message));
    expect(response.errorCode, equals(expectedResponse.errorCode));
    expect(
        response.directionsRoutes, equals(expectedResponse.directionsRoutes));
  });

  test('startNavigation should invoke method on platform', () async {
    final Map<String, dynamic> routeJson = <String, dynamic>{
      'distance': 0,
      'duration': 0,
      'geometry': '',
      'weight': 0,
      'weight_name': '',
    };

    final List<DirectionsRoute> routes = [DirectionsRoute.fromJson(routeJson)];
    final launcherConfig =
        NavigationLauncherConfig(route: routes.first, routes: routes);

    await NBNavigation.startNavigation(launcherConfig);

    verify(mockNBNavigationPlatform.startNavigation(launcherConfig)).called(1);
  });

  test('getRoutingBaseUri should return base uri', () async {
    const baseUri = 'https://api.nextbillion.io';

    when(mockNBNavigationPlatform.getRoutingBaseUri())
        .thenAnswer((_) async => baseUri);

    final response = await NBNavigation.getRoutingBaseUri();

    expect(response, equals(baseUri));
  });

  test('setRoutingBaseUri should set base uri', () async {
    const baseUri = 'https://api.nextbillion.io';

    await NBNavigation.setRoutingBaseUri(baseUri);

    verify(mockNBNavigationPlatform.setRoutingBaseUri(baseUri)).called(1);
  });

  test('getFormattedDuration should return formatted duration', () async {
    const durationSeconds = 0;

    when(mockNBNavigationPlatform.getFormattedDuration(durationSeconds))
        .thenAnswer((_) async => '0');

    final response = await NBNavigation.getFormattedDuration(durationSeconds);

    expect(response, equals('0'));
  });

  test('setOnNavigationExitCallback should set callback', () async {
    void callback(bool shouldRefreshRoute, int remainingWaypoints) {}

    await NBNavigation.setOnNavigationExitCallback(callback);

    verify(mockNBNavigationPlatform.setOnNavigationExitCallback(callback))
        .called(1);
  });

  test('startPreviewNavigation should start preview navigation', () async {
    final  Map<String, dynamic> routeJson = <String, dynamic>{
      'distance': 0,
      'duration': 0,
      'geometry': '',
      'weight': 0,
      'weight_name': '',
    };

    final route = DirectionsRoute.fromJson(routeJson);

    await NBNavigation.startPreviewNavigation(route);

    verify(mockNBNavigationPlatform.startPreviewNavigation(route)).called(1);
  });

  test('captureRouteDurationSymbol should return route duration symbol',
      () async {
    final Map<String, dynamic> routeJson = <String, dynamic>{
      'distance': 0,
      'duration': 0,
      'geometry': '',
      'weight': 0,
      'weight_name': '',
    };

    final route = DirectionsRoute.fromJson(routeJson);

    final Uint8List expectedResponse = Uint8List(0);

    when(mockNBNavigationPlatform.captureRouteDurationSymbol(route, true))
        .thenAnswer((_) async => expectedResponse);

    final response = await NBNavigation.captureRouteDurationSymbol(route, true);

    expect(response, equals(expectedResponse));
  });

  test('captureRouteWaypoints should return route waypoints', () async {
    const waypointIndex = 0;

    final Uint8List expectedResponse = Uint8List(0);

    when(mockNBNavigationPlatform.captureRouteWaypoints(waypointIndex))
        .thenAnswer((_) async => expectedResponse);

    final response = await NBNavigation.captureRouteWaypoints(waypointIndex);

    expect(response, equals(expectedResponse));
  });

  group('Test NextBillion', () {
    late MethodChannel mockChannel;

    setUp(() {
      mockChannel = MockMethodChannel();
      NextBillion.setMockMethodChannel(mockChannel);
    });

    test('Verify setUserId', () async {
      const String userId = 'userId';
      when(mockChannel.invokeMethod('nextbillion/set_user_id', any))
          .thenAnswer((_) async {
        return null;
      });

      await NBNavigation.setUserId(userId);

      verify(mockChannel
          .invokeMethod('nextbillion/set_user_id', {userId: userId})).called(1);
    });

    test('Verify getUserId', () async {
      const String userId = 'userId';
      when(mockChannel.invokeMethod('nextbillion/get_user_id', any))
          .thenAnswer((_) async {
        return userId;
      });
      //nextbillion/get_user_id
      final String? returnedUserId = await NBNavigation.getUserId();
      expect(returnedUserId, userId);
    });

    test('Verify Init nextbillion', () async {
      const String accessKey = 'accessKey';
      when(mockChannel.invokeMethod('nextbillion/init_nextbillion', any))
          .thenAnswer((_) async {
        return null;
      });
      //"nextbillion/init_nextbillion
      await NBNavigation.initNextBillion(accessKey);
      verify(mockChannel.invokeMethod(
          'nextbillion/init_nextbillion', {accessKey: accessKey})).called(1);
    });

    test('Verify getNBId', () async {
      const String nbid = 'nbid';
      when(mockChannel.invokeMethod('nextbillion/get_nb_id', any))
          .thenAnswer((_) async {
        return nbid;
      });

      final String? returnedNbId = await NBNavigation.getNBId();
      expect(returnedNbId, nbid);
    });
  });
}
