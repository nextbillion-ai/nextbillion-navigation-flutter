import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nb_navigation_flutter/navigation/nb_map_controller_wrapper.dart';
import 'package:nb_navigation_flutter/util/asset_manager.dart';
import 'package:test/test.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';
import 'package:flutter_test/flutter_test.dart' as flutter_test;

import 'nb_navigation_map_test.mocks.dart';

@GenerateNiceMocks([MockSpec<MapController>(), MockSpec<IAssetManager>()])
@GenerateMocks([NBNavigationPlatform])
void main() {
  group('NavNextBillionMap', () {
    late NavNextBillionMap navNextBillionMap;
    late MockMapController mockMapController;
    late MockIAssetManager mockAssetManager;

    setUp(() async {
      mockMapController = MockMapController();
      mockAssetManager = MockIAssetManager();
      navNextBillionMap = await NavNextBillionMap.createWithAssetManager(
          mockMapController, mockAssetManager);
    });

    test('should create NavNextBillionMap', () {
      expect(navNextBillionMap, isNotNull);
    });

    test('should add route selected listener', () {
      LatLng origin = const LatLng(1.312533169133601, 103.75986708439264);
      LatLng dest = const LatLng(1.310473772283314, 103.77982271935586);

      navNextBillionMap.addRouteSelectedListener(origin, (selectedRouteIndex) {
        expect(selectedRouteIndex, equals(0));
      });

      navNextBillionMap.addRouteSelectedListener(dest, (selectedRouteIndex) {
        expect(selectedRouteIndex, equals(0));
      });
    });

    test('should add route selected listener', () {
      LatLng origin = const LatLng(1.312533169133601, 103.75986708439264);
      LatLng dest = const LatLng(1.310473772283314, 103.77982271935586);

      navNextBillionMap.addRouteSelectedListener(origin, (selectedRouteIndex) {
        expect(selectedRouteIndex, equals(0));
      });

      navNextBillionMap.addRouteSelectedListener(dest, (selectedRouteIndex) {
        expect(selectedRouteIndex, equals(0));
      });
    });

    test('should get route line properties', () {
      const routeLineStyle = RouteLineProperties(
          routeDefaultColor: Color(0xFFE97F2F),
          routeScale: 1.0,
          alternativeRouteScale: 1.0,
          routeShieldColor: Color(0xFF54E910),
          durationSymbolPrimaryBackgroundColor: Color(0xFFE97F2F));

      expect(routeLineStyle.routeDefaultColor, equals(const Color(0xFFE97F2F)));
      expect(routeLineStyle.routeScale, equals(1.0));
      expect(routeLineStyle.alternativeRouteScale, equals(1.0));
      expect(routeLineStyle.routeShieldColor, equals(const Color(0xFF54E910)));
      expect(routeLineStyle.durationSymbolPrimaryBackgroundColor,
          equals(const Color(0xFFE97F2F)));
    });
    test('should create NavNextBillionMap', () {
      expect(navNextBillionMap, isNotNull);
      expect(navNextBillionMap.controller, equals(mockMapController));
    });

    test(
        'initGeoJsonSource will be called twice together with factor method createWithAssetManager',
        () async {
      when(mockMapController.disposed).thenReturn(false);
      await navNextBillionMap.initGeoJsonSource();

      verify(mockMapController.removeSource(routeShieldSourceId)).called(2);
      verify(mockMapController.removeSource(routeSourceId)).called(2);
      verify(mockMapController.removeSource(waypointSourceId)).called(2);
      verify(mockMapController.removeSource(routeDurationSourceId)).called(2);

      verify(mockMapController.removeLayer(routeShieldLayerId)).called(2);
      verify(mockMapController.removeLayer(routeLayerId)).called(2);
      verify(mockMapController.removeLayer(waypointLayerId)).called(2);
      verify(mockMapController.removeLayer(routeDurationLayerId)).called(2);
    });

    test('should initialize route layers', () async {
      when(mockMapController.disposed).thenReturn(false);

      when(mockMapController.findBelowLayerId(
              [nbmapLocationId, highwayShieldLayerId, nbmapAnnotationId]))
          .thenAnswer((_) async => 'belowLayer');

      await navNextBillionMap.initRouteLayers();

      //1 from factor method createWithAssetManager, 1 from initRouteLayers
      verify(mockMapController.findBelowLayerId(any)).called(2);

      verify(mockMapController.addLineLayer(
              routeShieldSourceId, routeShieldLayerId, any,
              belowLayerId: 'belowLayer'))
          .called(1);

      verify(mockMapController.addLineLayer(routeSourceId, routeLayerId, any,
              belowLayerId: 'belowLayer'))
          .called(1);

      verify(mockMapController.addSymbolLayer(any, any, any)).called(2);
    });

    test('should return if routes are empty', () async {
      when(mockMapController.disposed).thenReturn(false);
      expect(
            () async => await navNextBillionMap.drawRoute([]),
        flutter_test.throwsAssertionError,
      );
    });

    test('should drawRoute if routes are not empty', () async {
      NBNavigationPlatform mockNBNavigationPlatform =
          MockNBNavigationPlatform();
      NBNavigation.setNBNavigationPlatform(mockNBNavigationPlatform);

      WidgetsFlutterBinding.ensureInitialized();
      final file = File('test/navigation/route.json');
      final jsonString = await file.readAsString();
      Map<String, dynamic> json = jsonDecode(jsonString);
      DirectionsRoute route = DirectionsRoute.fromJson(json);
      List<DirectionsRoute> routes = [route];

      Uint8List expectedResponse = Uint8List(0);

      when(mockNBNavigationPlatform.captureRouteDurationSymbol(route, true))
          .thenAnswer((_) async => expectedResponse);

      when(mockMapController.disposed).thenReturn(false);
      await navNextBillionMap.drawRoute(routes);

      //1: buildFeatureCollection(reversed), 2:buildFeatureCollection([])
      verify(mockMapController.setGeoJsonSource(routeShieldSourceId, any))
          .called(2);
    });

    test('should drawIndependentRoutes if routes are not empty', () async {
      NBNavigationPlatform mockNBNavigationPlatform =
      MockNBNavigationPlatform();
      NBNavigation.setNBNavigationPlatform(mockNBNavigationPlatform);

      WidgetsFlutterBinding.ensureInitialized();
      final file = File('test/navigation/route.json');
      final jsonString = await file.readAsString();
      Map<String, dynamic> json = jsonDecode(jsonString);
      DirectionsRoute route = DirectionsRoute.fromJson(json);
      List<DirectionsRoute> routes = [route];

      Uint8List expectedResponse = Uint8List(0);

      when(mockNBNavigationPlatform.captureRouteDurationSymbol(route, true))
          .thenAnswer((_) async => expectedResponse);

      when(mockMapController.disposed).thenReturn(false);
      await navNextBillionMap.drawIndependentRoutes(routes);

      //1: buildFeatureCollection(reversed), 2:buildFeatureCollection([])
      verify(mockMapController.setGeoJsonSource(routeShieldSourceId, any))
          .called(2);
    });

    test('should drawRoute with full overview if routes is not empty',
        () async {
      NBNavigationPlatform mockNBNavigationPlatform =
          MockNBNavigationPlatform();
      NBNavigation.setNBNavigationPlatform(mockNBNavigationPlatform);

      WidgetsFlutterBinding.ensureInitialized();
      final file = File('test/navigation/route_full_overview.json');
      final jsonString = await file.readAsString();
      Map<String, dynamic> json = jsonDecode(jsonString);
      DirectionsRoute route = DirectionsRoute.fromJson(json);
      List<DirectionsRoute> routes = [route];

      Uint8List expectedResponse = Uint8List(0);

      when(mockNBNavigationPlatform.captureRouteDurationSymbol(route, true))
          .thenAnswer((_) async => expectedResponse);

      when(mockMapController.disposed).thenReturn(false);
      await navNextBillionMap.drawRoute(routes);

      //1: buildFeatureCollection(reversed), 2:buildFeatureCollection([])
      verify(mockMapController.setGeoJsonSource(routeShieldSourceId, any))
          .called(2);
    });

    test('should drawIndependentRoutes with full overview if routes is not empty',
            () async {
          NBNavigationPlatform mockNBNavigationPlatform =
          MockNBNavigationPlatform();
          NBNavigation.setNBNavigationPlatform(mockNBNavigationPlatform);

          WidgetsFlutterBinding.ensureInitialized();
          final file = File('test/navigation/route_full_overview.json');
          final jsonString = await file.readAsString();
          Map<String, dynamic> json = jsonDecode(jsonString);
          DirectionsRoute route = DirectionsRoute.fromJson(json);
          List<DirectionsRoute> routes = [route];

          Uint8List expectedResponse = Uint8List(0);

          when(mockNBNavigationPlatform.captureRouteDurationSymbol(route, true))
              .thenAnswer((_) async => expectedResponse);

          when(mockMapController.disposed).thenReturn(false);
          await navNextBillionMap.drawIndependentRoutes(routes);

          //1: buildFeatureCollection(reversed), 2:buildFeatureCollection([])
          verify(mockMapController.setGeoJsonSource(routeShieldSourceId, any))
              .called(2);
        });

    test('should add route selected listener', () {
      LatLng clickedPoint = const LatLng(1.0, 2.0);
      navNextBillionMap.addRouteSelectedListener(clickedPoint,
          (selectedRouteIndex) {
        //TODO: need to add two or more routes to test this
      });
    }, skip: true);

    test('should toggle alternative visibility', () async {
      when(mockMapController.disposed).thenReturn(false);
      await navNextBillionMap.toggleAlternativeVisibilityWith(true);
      //TODO: need to add two or more routes to test this
    }, skip: true);

    test('should toggle duration symbol visibility', () {
      when(mockMapController.disposed).thenReturn(false);
      navNextBillionMap.toggleDurationSymbolVisibilityWith(true);

      verify(mockMapController.setVisibility(routeDurationLayerId, true))
          .called(1);
    });

    test('should clear the currently displayed route', () async {
      when(mockMapController.disposed).thenReturn(false);
      await navNextBillionMap.clearRoute();

      verify(mockMapController.setGeoJsonSource(
          routeShieldSourceId, buildFeatureCollection([]))).called(1);
      verify(mockMapController.setGeoJsonSource(
          routeSourceId, buildFeatureCollection([]))).called(1);
      verify(mockMapController.setGeoJsonSource(
          waypointSourceId, buildFeatureCollection([]))).called(1);
      verify(mockMapController.setGeoJsonSource(
          routeDurationSourceId, buildFeatureCollection([]))).called(1);
    });
  });
}
