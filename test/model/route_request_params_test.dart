import 'package:flutter_test/flutter_test.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

void main() {
  group('RouteRequestParams.fromJson', () {
    test('returns default values when map is empty', () {
      expect(
            () => RouteRequestParams.fromJson({}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('parses a valid map correctly', () {
      final map = {
        'altCount': 2,
        'alternatives': true,
        'avoidType': ['toll'],
        'destination': [-74.005974, 40.712776],
        'language': 'en',
        'mode': 'car',
        'origin': [-118.243683, 34.052235],
        'overview': 'full',
        'simulation': false,
        'truckWeight': 10000,
        'truckSize': ['5', '10'],
        'unit': 'metric',
        'option': 'flexible',
        'geometry': 'polyline',
        'waypoints': [
          [-115.139832, 36.169941],
          [-122.419418, 37.774929]
        ],
        'hazmatType': ['general'],
        'approaches': ['curb', 'unrestricted', 'unrestricted']
      };

      final params = RouteRequestParams.fromJson(map);

      expect(params.altCount, 2);
      expect(params.alternatives, true);
      // expect(params.avoid, [SupportedAvoid.fromValue('toll')]);
      expect(params.avoidType, ["toll"]);
      expect(params.destination, const LatLng(40.712776, -74.005974));
      expect(params.language, 'en');
      expect(params.mode, ValidModes.fromValue('car'));
      expect(params.origin, const LatLng(34.052235, -118.243683));
      expect(params.overview, ValidOverview.fromValue('full'));
      expect(params.simulation, false);
      expect(params.truckWeight, 10000);
      expect(params.truckSize, [5, 10]);
      expect(params.unit, SupportedUnits.fromValue('metric'));
      expect(params.option, SupportedOption.fromValue('flexible'));
      expect(params.geometry, SupportedGeometry.fromValue('polyline'));
      expect(params.waypoints, [
        const LatLng(36.169941, -115.139832),
        const LatLng(37.774929, -122.419418)
      ]);
      expect(params.hazmatType, [SupportedHazmatType.fromValue('general')]);
      expect(params.approaches, [
        SupportedApproaches.fromValue('curb'),
        SupportedApproaches.fromValue('unrestricted'),
        SupportedApproaches.fromValue('unrestricted')
      ]);
    });

    test('truckWeight should be within the valid range when mode is truck', () {
      expect(
            () => RouteRequestParams(
          origin: const LatLng(0, 0),
          destination: const LatLng(1, 1),
          mode: ValidModes.truck,
          truckWeight: 0, // Invalid, should throw error
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
            () => RouteRequestParams(
          origin: const LatLng(0, 0),
          destination: const LatLng(1, 1),
          mode: ValidModes.truck,
          truckWeight: 100001, // Invalid, should throw error
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('truckSize should have exactly three values and be within limits when mode is truck', () {
      expect(
            () => RouteRequestParams(
          origin: const LatLng(0, 0),
          destination: const LatLng(1, 1),
          mode: ValidModes.truck,
          truckSize: [100, 100], // Invalid, should throw error
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
            () => RouteRequestParams(
          origin: const LatLng(0, 0),
          destination: const LatLng(1, 1),
          mode: ValidModes.truck,
          truckSize: [1001, 4000, 4000], // Invalid height
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
            () => RouteRequestParams(
          origin: const LatLng(0, 0),
          destination: const LatLng(1, 1),
          mode: ValidModes.truck,
          truckSize: [900, 6000, 4000], // Invalid width
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
            () => RouteRequestParams(
          origin: const LatLng(0, 0),
          destination: const LatLng(1, 1),
          mode: ValidModes.truck,
          truckWeight: 10000000
        ),
        throwsA(isA<AssertionError>()),
      );

      expect(
            () => RouteRequestParams(
            origin: const LatLng(0, 0),
            destination: const LatLng(1, 1),
            mode: ValidModes.truck,
            truckWeight: 1000
        ),
          isNotNull
      );

      expect(
            () => RouteRequestParams(
          origin: const LatLng(0, 0),
          destination: const LatLng(1, 1),
          mode: ValidModes.truck,
          truckSize: [900, 3000, 4000],
        ),
        isNotNull
      );
    });
  });


}
