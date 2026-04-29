import 'package:flutter_test/flutter_test.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

void main() {
  group('DirectionsRoute roadInfo', () {
    final baseRouteJson = {
      'distance': 1000.0,
      'duration': 200.0,
      'geometry': 'encodedGeometry',
      'legs': <Map<String, dynamic>>[],
      'routeIndex': '0',
      'routeOptions': {
        'origin': [103.75986708439264, 1.312533169133601],
        'destination': [103.77982271935586, 1.310473772283314],
      },
      'weight': 100.0,
      'weight_name': 'routability',
    };

    test('fromJson should parse road_info when present', () {
      final json = {
        ...baseRouteJson,
        'road_info': {
          'max_speed': [
            {'offset': 0.0, 'length': 2.0, 'value': 40.0},
            {'offset': 2.0, 'length': 1.0, 'value': 60.0},
          ]
        },
      };

      final route = DirectionsRoute.fromJson(json);

      expect(route.roadInfo, isNotNull);
      expect(route.roadInfo!['max_speed'], isA<List>());
      expect((route.roadInfo!['max_speed'] as List).length, 2);
      expect((route.roadInfo!['max_speed'] as List)[0]['value'], 40.0);
      expect((route.roadInfo!['max_speed'] as List)[1]['value'], 60.0);
    });

    test('fromJson should handle missing road_info', () {
      final route = DirectionsRoute.fromJson(baseRouteJson);

      expect(route.roadInfo, isNull);
    });

    test('fromJsonWithOption should parse road_info when present', () {
      final json = {
        ...baseRouteJson,
        'road_info': {
          'max_speed': [
            {'offset': 0.0, 'length': 3.0, 'value': 50.0},
          ]
        },
      };

      final routeOptions = RouteRequestParams(
        origin: const LatLng(1.312533169133601, 103.75986708439264),
        destination: const LatLng(1.310473772283314, 103.77982271935586),
      );

      final route = DirectionsRoute.fromJsonWithOption(json, routeOptions);

      expect(route.roadInfo, isNotNull);
      expect(route.roadInfo!['max_speed'], isA<List>());
      expect((route.roadInfo!['max_speed'] as List).length, 1);
      expect((route.roadInfo!['max_speed'] as List)[0]['value'], 50.0);
    });

    test('toJson should include road_info when present', () {
      final roadInfoData = {
        'max_speed': [
          {'offset': 0.0, 'length': 2.0, 'value': 40.0},
          {'offset': 2.0, 'length': 1.0, 'value': 60.0},
        ]
      };

      final route = DirectionsRoute(
        distance: 1000.0,
        duration: 200.0,
        geometry: 'encodedGeometry',
        legs: [],
        routeIndex: '0',
        roadInfo: roadInfoData,
      );

      final json = route.toJson();

      expect(json['road_info'], isNotNull);
      expect(json['road_info']['max_speed'], isA<List>());
      expect((json['road_info']['max_speed'] as List).length, 2);
    });

    test('toJson should have null road_info when not set', () {
      final route = DirectionsRoute(
        distance: 1000.0,
        duration: 200.0,
        geometry: 'encodedGeometry',
        legs: [],
        routeIndex: '0',
      );

      final json = route.toJson();

      expect(json['road_info'], isNull);
    });

    test('road_info should be preserved through fromJson -> toJson round trip', () {
      final roadInfoData = {
        'max_speed': [
          {'offset': 0.0, 'length': 2.0, 'value': 40.0},
          {'offset': 2.0, 'length': 1.0, 'value': 60.0},
          {'offset': 3.0, 'length': 2.0, 'value': 80.0},
        ]
      };

      final json = {
        ...baseRouteJson,
        'road_info': roadInfoData,
      };

      final route = DirectionsRoute.fromJson(json);
      final outputJson = route.toJson();

      expect(outputJson['road_info'], isNotNull);
      final maxSpeed = outputJson['road_info']['max_speed'] as List;
      expect(maxSpeed.length, 3);
      expect(maxSpeed[0]['value'], 40.0);
      expect(maxSpeed[1]['value'], 60.0);
      expect(maxSpeed[2]['value'], 80.0);
    });
  });
}
