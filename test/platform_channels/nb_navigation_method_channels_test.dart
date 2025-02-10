import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

import 'nb_navigation_method_channels_test.mocks.dart';

@GenerateMocks([MethodChannel])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MethodChannel channel;
  late NBNavigationMethodChannel nbNavMethodChannel;
  late DirectionsRoute route;

  setUp(() async {
    channel = MockMethodChannel();
    nbNavMethodChannel = NBNavigationMethodChannel();
    nbNavMethodChannel.setMethodChanenl(channel);

    final file = File('test/navigation/route.json');
    final jsonString = await file.readAsString();
    Map<String, dynamic> json = jsonDecode(jsonString);
    route = DirectionsRoute.fromJson(json);
  });

  tearDown(() {});

  test('fetchRoute should return DirectionsRouteResponse', () async {
    LatLng origin = const LatLng(1.312533169133601, 103.75986708439264);
    LatLng dest = const LatLng(1.310473772283314, 103.77982271935586);

    final routeRequestParams =
        RouteRequestParams(origin: origin, destination: dest);

    final expectedResponse = DirectionsRouteResponse(
      directionsRoutes: [],
      message: 'Test message',
      errorCode: 0,
    );

    when(channel.invokeMethod<Map<String, dynamic>>('route/fetchRoute', any))
        .thenAnswer((_) async => {
              'directionsRoutes': [],
              'message': 'Test message',
              'errorCode': 0,
            });

    final response = await nbNavMethodChannel.fetchRoute(routeRequestParams);

    expect(response.message, equals(expectedResponse.message));
    expect(response.errorCode, equals(expectedResponse.errorCode));
    expect(
        response.directionsRoutes, equals(expectedResponse.directionsRoutes));
  });

  test('setOnNavigationExitCallback sets the correct callback', () {
    bool callbackCalled = false;
    void callback(bool shouldRefreshRoute, int remainingWaypoints) {
      callbackCalled = true;
    }

    nbNavMethodChannel.setOnNavigationExitCallback(callback);
    nbNavMethodChannel.navigationExitCallback!.call(true, 0);

    expect(callbackCalled, true);
  });

  test('handleMethodCall should call navigationExitCallback', () async {
    bool expectedShouldRefreshRoute = false;
    int expectedRemainingWaypoints = 0;
    void callback(bool shouldRefreshRoute, int remainingWaypoints) {
      expectedShouldRefreshRoute = shouldRefreshRoute;
      expectedRemainingWaypoints = remainingWaypoints;
    }

    nbNavMethodChannel.setOnNavigationExitCallback(callback);
    final arguments = {
      'shouldRefreshRoute': true,
      'remainingWaypoints': 1,
    };

    nbNavMethodChannel.handleMethodCall(
        MethodCall(NBNavigationLauncherMethodID.nbOnNavigationExit, arguments));

    expect(expectedRemainingWaypoints, 1);
    expect(expectedShouldRefreshRoute, true);
  });

  test('handleMethodCall throws MissingPluginException for unknown method',
      () async {
    const call = MethodCall('unknownMethod');

    expect(() async => await nbNavMethodChannel.handleMethodCall(call),
        throwsA(isA<MissingPluginException>()));
  });

  //Assume Platform.IOS == false;
  test('startNavigation should invoke method on channel', () async {
    List<DirectionsRoute> routes = [route];
    final launcherConfig =
        NavigationLauncherConfig(route: route, routes: routes);
    // final routeOptions = RouteRequestParams.fromJson({});
    final arguments = {
      'launcherConfig': launcherConfig.toJson(),
    };

    when(channel.invokeMethod<Map<String, dynamic>>(
            NBNavigationLauncherMethodID.nbNavigationLauncherMethod, arguments))
        .thenAnswer((_) async => {});

    await nbNavMethodChannel.startNavigation(launcherConfig);

    verify(channel.invokeMethod(
        NBNavigationLauncherMethodID.nbNavigationLauncherMethod, arguments));
  });

  test('startPreviewNavigation should invoke method on channel', () async {
    final arguments = {
      'route': jsonEncode(route),
    };

    when(channel.invokeMethod<Map<String, dynamic>>(
            NBNavigationLauncherMethodID.nbPreviewNavigationMethod, arguments))
        .thenAnswer((_) async => {});

    await nbNavMethodChannel.startPreviewNavigation(route);

    verify(channel.invokeMethod(
        NBNavigationLauncherMethodID.nbPreviewNavigationMethod, arguments));
  });

  test('findSelectedRouteIndex should return index', () async {
    const expectedIndex = 0;
    LatLng clickPoint = const LatLng(1.0, 2.0);
    List<List<LatLng>> coordinates = [
      [const LatLng(1.0, 2.0), const LatLng(1.0, 2.0)]
    ];

    when(channel.invokeMethod<int>('route/findSelectedRouteIndex', any))
        .thenAnswer((_) async => expectedIndex);

    final index = await nbNavMethodChannel.findSelectedRouteIndex(
        clickPoint, coordinates);

    expect(index, equals(expectedIndex));
  });

  test('getRoutingBaseUri should return uri', () async {
    const expectedUri = 'testUri';

    when(channel.invokeMethod<String>(
            NBNavigationLauncherMethodID.nbGetNavigationUriMethod))
        .thenAnswer((_) async => expectedUri);

    final uri = await nbNavMethodChannel.getRoutingBaseUri();

    expect(uri, equals(expectedUri));
  });

  test('getFormattedDuration should return formatted duration', () async {
    const expectedDuration = '1 min';

    when(channel.invokeMethod<String>(NBRouteMethodID.routeFormattedDuration,
        {"duration": 60.toDouble()})).thenAnswer((_) async => expectedDuration);

    final duration = await nbNavMethodChannel.getFormattedDuration(60);

    expect(duration, equals(expectedDuration));
  });

  test('captureRouteDurationSymbol should return Uint8List', () async {
    final expectedResponse = Uint8List(0);

    when(channel.invokeMethod<Uint8List>('capture/routeDurationSymbol', any))
        .thenAnswer((_) async => expectedResponse);

    final response =
        await nbNavMethodChannel.captureRouteDurationSymbol(route, true);

    expect(response, equals(expectedResponse));
  });

  test('captureRouteWaypoints should return Uint8List', () async {
    final expectedResponse = Uint8List(0);

    when(channel.invokeMethod<Uint8List>(
            NBRouteMethodID.navigationCaptureRouteWaypoints, any))
        .thenAnswer((_) async => expectedResponse);

    final response = await nbNavMethodChannel.captureRouteWaypoints(0);

    expect(response, equals(expectedResponse));
  });

  test('captureRouteWaypoints handles PlatformException correctly', () async {
    const waypointIndex = 1;
    final exception = PlatformException(code: 'test');

    when(channel.invokeMethod(
      NBRouteMethodID.navigationCaptureRouteWaypoints,
      any,
    )).thenThrow(exception);

    final result =
        await nbNavMethodChannel.captureRouteWaypoints(waypointIndex);

    verify(channel.invokeMethod(
      NBRouteMethodID.navigationCaptureRouteWaypoints,
      {"waypointIndex": waypointIndex},
    )).called(1);

    expect(result, null);
  });

  test('setRoutingBaseUri calls the correct method on the method channel', () {
    const uri = 'test_uri';

    when(channel.invokeMethod(
        NBNavigationLauncherMethodID.nbSetNavigationUriMethod,
        {'navigationBaseUri': uri})).thenAnswer((realInvocation) async => null);
    nbNavMethodChannel.setRoutingBaseUri(uri);

    verify(channel.invokeMethod(
        NBNavigationLauncherMethodID.nbSetNavigationUriMethod,
        {'navigationBaseUri': uri})).called(1);
  });
}
