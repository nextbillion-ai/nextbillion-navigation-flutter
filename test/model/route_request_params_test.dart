import 'package:flutter_test/flutter_test.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

void main() {
  group('RouteRequestParams.fromJson', () {
    test('returns default values when map is empty', () {
      final params = RouteRequestParams.fromJson({});

      expect(params.origin, const LatLng(0, 0));
      expect(params.destination, const LatLng(0, 0));
    });

    test('parses a valid map correctly', () {
      final map = {
        'altCount': 2,
        'alternatives': true,
        'avoid': ['toll'],
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
      expect(params.avoid, [SupportedAvoid.fromValue('toll')]);
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
  });
}
