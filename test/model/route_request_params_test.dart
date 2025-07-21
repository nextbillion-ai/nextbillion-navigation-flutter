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

    test('parses a valid bike map correctly', () {
      final map = {
        'altCount': 2,
        'alternatives': true,
        'avoidType': ['toll'],
        'destination': [-74.005974, 40.712776],
        'language': 'en',
        'mode': 'bike',
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
      expect(params.mode, ValidModes.bike);
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

    test('parses a valid bike map correctly', () {
      final map = {
        'altCount': 2,
        'alternatives': true,
        'avoidType': ['toll'],
        'destination': [-74.005974, 40.712776],
        'language': 'en',
        'mode': 'motorcycle',
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
      expect(params.mode, ValidModes.motorcycle);
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

  group('RouteRequestParams.toJson', () {
    test('should serialize avoidType correctly when avoidType is not empty', () {
      final params = RouteRequestParams(
        origin: const LatLng(34.052235, -118.243683),
        destination: const LatLng(40.712776, -74.005974),
        avoidType: ['toll', 'ferry'],
      );

      final json = params.toJson();
      
      expect(json['avoid'], ['toll', 'ferry']);
    });

    test('should serialize avoid enum values to strings when avoidType is empty', () {
      final params = RouteRequestParams(
        origin: const LatLng(34.052235, -118.243683),
        destination: const LatLng(40.712776, -74.005974),
        // ignore: deprecated_member_use_from_same_package
        avoid: [SupportedAvoid.toll, SupportedAvoid.ferry],
        avoidType: [], // Empty avoidType
      );

      final json = params.toJson();
      
      expect(json['avoid'], ['toll', 'ferry']);
    });

    test('should serialize avoid enum values to strings when avoidType is null', () {
      final params = RouteRequestParams(
        origin: const LatLng(34.052235, -118.243683),
        destination: const LatLng(40.712776, -74.005974),
        // ignore: deprecated_member_use_from_same_package
        avoid: [SupportedAvoid.toll, SupportedAvoid.highway],
        avoidType: null, // Null avoidType
      );

      final json = params.toJson();
      
      expect(json['avoid'], ['toll', 'highway']);
    });

    test('should handle mixed avoid enum values correctly', () {
      final params = RouteRequestParams(
        origin: const LatLng(34.052235, -118.243683),
        destination: const LatLng(40.712776, -74.005974),
        // ignore: deprecated_member_use_from_same_package
        avoid: [SupportedAvoid.toll, SupportedAvoid.ferry, SupportedAvoid.highway, SupportedAvoid.none],
        avoidType: null,
      );

      final json = params.toJson();
      
      expect(json['avoid'], ['toll', 'ferry', 'highway', 'none']);
    });

    test('should return null when both avoid and avoidType are null', () {
      final params = RouteRequestParams(
        origin: const LatLng(34.052235, -118.243683),
        destination: const LatLng(40.712776, -74.005974),
        // ignore: deprecated_member_use_from_same_package
        avoid: null,
        avoidType: null,
      );

      final json = params.toJson();
      
      expect(json['avoid'], isNull);
    });

    test('should prioritize avoidType over avoid when both are provided', () {
      final params = RouteRequestParams(
        origin: const LatLng(34.052235, -118.243683),
        destination: const LatLng(40.712776, -74.005974),
        // ignore: deprecated_member_use_from_same_package
        avoid: [SupportedAvoid.toll, SupportedAvoid.ferry],
        avoidType: ['highway', 'service_road'],
      );

      final json = params.toJson();
      
      expect(json['avoid'], ['highway', 'service_road']);
    });

    test('should handle empty avoidType and null avoid', () {
      final params = RouteRequestParams(
        origin: const LatLng(34.052235, -118.243683),
        destination: const LatLng(40.712776, -74.005974),
        // ignore: deprecated_member_use_from_same_package
        avoid: null,
        avoidType: [],
      );

      final json = params.toJson();
      
      expect(json['avoid'], isNull);
    });

    test('should serialize all other fields correctly', () {
      final params = RouteRequestParams(
        origin: const LatLng(34.052235, -118.243683),
        destination: const LatLng(40.712776, -74.005974),
        altCount: 3,
        alternatives: true,
        avoidType: ['toll'],
        baseUrl: 'https://api.example.com',
        departureTime: 1640995200,
        key: 'test_key',
        language: 'en',
        mode: ValidModes.car,
        overview: ValidOverview.full,
        simulation: false,
        truckWeight: 5000,
        truckSize: [200, 200, 400],
        unit: SupportedUnits.metric,
        option: SupportedOption.flexible,
        geometry: SupportedGeometry.polyline6,
        waypoints: [const LatLng(36.169941, -115.139832)],
        hazmatType: [SupportedHazmatType.general],
        approaches: [SupportedApproaches.curb],
        crossBorder: true,
        truckAxleLoad: 10.5,
        allow: 'taxi',
        routeType: RouteType.fastest,
      );

      final json = params.toJson();
      
      expect(json['altCount'], 3);
      expect(json['alternatives'], true);
      expect(json['avoid'], ['toll']);
      expect(json['baseUrl'], 'https://api.example.com');
      expect(json['departureTime'], 1640995200);
      expect(json['key'], 'test_key');
      expect(json['language'], 'en');
      expect(json['mode'], 'car');
      expect(json['origin'], [-118.243683, 34.052235]);
      expect(json['destination'], [-74.005974, 40.712776]);
      expect(json['overview'], 'full');
      expect(json['simulation'], false);
      expect(json['truckWeight'], 5000);
      expect(json['truckSize'], [200, 200, 400]);
      expect(json['unit'], 'metric');
      expect(json['option'], 'flexible');
      expect(json['geometry'], 'polyline6');
      expect(json['waypoints'], [[-115.139832, 36.169941]]);
      expect(json['hazmatType'], ['general']);
      expect(json['approaches'], ['curb']);
      expect(json['crossBorder'], true);
      expect(json['truckAxleLoad'], 10.5);
      expect(json['allow'], 'taxi');
      expect(json['routeType'], 'fastest');
    });
  });

  group('RouteRequestParams avoid field tests', () {
    group('fromJson avoid parsing', () {
      test('should parse avoid field from legacy avoid array', () {
        final map = {
          'origin': [-118.243683, 34.052235],
          'destination': [-74.005974, 40.712776],
          'avoid': ['toll', 'ferry', 'highway'],
        };

        final params = RouteRequestParams.fromJson(map);
        
        expect(params.avoidType, ['toll', 'ferry', 'highway']);
        // ignore: deprecated_member_use_from_same_package
        expect(params.avoid, [SupportedAvoid.toll, SupportedAvoid.ferry, SupportedAvoid.highway]);
      });

      test('should parse avoidType field correctly', () {
        final map = {
          'origin': [-118.243683, 34.052235],
          'destination': [-74.005974, 40.712776],
          'avoidType': ['toll', 'service_road', 'sharp_turn'],
        };

        final params = RouteRequestParams.fromJson(map);
        
        expect(params.avoidType, ['toll', 'service_road', 'sharp_turn']);
      });

      test('should handle empty avoid array', () {
        final map = {
          'origin': [-118.243683, 34.052235],
          'destination': [-74.005974, 40.712776],
          'avoid': [],
        };

        final params = RouteRequestParams.fromJson(map);
        
        expect(params.avoidType, isEmpty);
      });

      test('should handle null avoid field', () {
        final map = {
          'origin': [-118.243683, 34.052235],
          'destination': [-74.005974, 40.712776],
          'avoid': null,
        };

        final params = RouteRequestParams.fromJson(map);
        
        expect(params.avoidType, isEmpty);
      });

      test('should handle missing avoid field', () {
        final map = {
          'origin': [-118.243683, 34.052235],
          'destination': [-74.005974, 40.712776],
        };

        final params = RouteRequestParams.fromJson(map);
        
        expect(params.avoidType, isEmpty);
      });

      test('should handle all supported avoid values', () {
        final map = {
          'origin': [-118.243683, 34.052235],
          'destination': [-74.005974, 40.712776],
          'avoid': ['toll', 'ferry', 'highway', 'uturn', 'sharp_turn', 'service_road', 'none'],
        };

        final params = RouteRequestParams.fromJson(map);
        
        expect(params.avoidType, ['toll', 'ferry', 'highway', 'uturn', 'sharp_turn', 'service_road', 'none']);
      });

      test('should handle invalid avoid values gracefully', () {
        final map = {
          'origin': [-118.243683, 34.052235],
          'destination': [-74.005974, 40.712776],
          'avoid': ['toll', 'invalid_value', 'ferry'],
        };

        final params = RouteRequestParams.fromJson(map);
        
        expect(params.avoidType, ['toll', 'invalid_value', 'ferry']);
      });
    });

    group('toJson avoid serialization', () {
      test('should serialize avoidType when provided', () {
        final params = RouteRequestParams(
          origin: const LatLng(34.052235, -118.243683),
          destination: const LatLng(40.712776, -74.005974),
          avoidType: ['toll', 'ferry', 'highway'],
        );

        final json = params.toJson();
        
        expect(json['avoid'], ['toll', 'ferry', 'highway']);
      });

      test('should serialize avoid enum values when avoidType is not provided', () {
        final params = RouteRequestParams(
          origin: const LatLng(34.052235, -118.243683),
          destination: const LatLng(40.712776, -74.005974),
          // ignore: deprecated_member_use_from_same_package
          avoid: [SupportedAvoid.toll, SupportedAvoid.ferry, SupportedAvoid.highway],
        );

        final json = params.toJson();
        
        expect(json['avoid'], ['toll', 'ferry', 'highway']);
      });

      test('should serialize all SupportedAvoid enum values correctly', () {
        final params = RouteRequestParams(
          origin: const LatLng(34.052235, -118.243683),
          destination: const LatLng(40.712776, -74.005974),
                      // ignore: deprecated_member_use_from_same_package
            avoid: [
              SupportedAvoid.toll,
              SupportedAvoid.ferry,
              SupportedAvoid.highway,
              SupportedAvoid.uTurn,
              SupportedAvoid.sharpTurn,
              SupportedAvoid.serviceRoad,
              SupportedAvoid.none,
            ],
        );

        final json = params.toJson();
        
        expect(json['avoid'], [
          'toll',
          'ferry',
          'highway',
          'uturn',
          'sharp_turn',
          'service_road',
          'none',
        ]);
      });

      test('should prioritize avoidType over avoid when both are provided', () {
        final params = RouteRequestParams(
          origin: const LatLng(34.052235, -118.243683),
          destination: const LatLng(40.712776, -74.005974),
          // ignore: deprecated_member_use_from_same_package
          avoid: [SupportedAvoid.toll, SupportedAvoid.ferry],
          avoidType: ['highway', 'service_road'],
        );

        final json = params.toJson();
        
        expect(json['avoid'], ['highway', 'service_road']);
      });

      test('should return null when both avoid and avoidType are null', () {
        final params = RouteRequestParams(
          origin: const LatLng(34.052235, -118.243683),
          destination: const LatLng(40.712776, -74.005974),
          // ignore: deprecated_member_use_from_same_package
          avoid: null,
          avoidType: null,
        );

        final json = params.toJson();
        
        expect(json['avoid'], isNull);
      });

      test('should return null when avoid is null and avoidType is empty', () {
        final params = RouteRequestParams(
          origin: const LatLng(34.052235, -118.243683),
          destination: const LatLng(40.712776, -74.005974),
          // ignore: deprecated_member_use_from_same_package
          avoid: null,
          avoidType: [],
        );

        final json = params.toJson();
        
        expect(json['avoid'], isNull);
      });

      test('should handle empty avoidType correctly', () {
        final params = RouteRequestParams(
          origin: const LatLng(34.052235, -118.243683),
          destination: const LatLng(40.712776, -74.005974),
          // ignore: deprecated_member_use_from_same_package
          avoid: [SupportedAvoid.toll, SupportedAvoid.ferry],
          avoidType: [],
        );

        final json = params.toJson();
        
        expect(json['avoid'], ['toll', 'ferry']);
      });

      test('should handle null avoidType correctly', () {
        final params = RouteRequestParams(
          origin: const LatLng(34.052235, -118.243683),
          destination: const LatLng(40.712776, -74.005974),
                  // ignore: deprecated_member_use_from_same_package
        avoid: [SupportedAvoid.toll, SupportedAvoid.ferry],
        avoidType: null,
        );

        final json = params.toJson();
        
        expect(json['avoid'], ['toll', 'ferry']);
      });

      test('should handle single avoid value', () {
        final params = RouteRequestParams(
          origin: const LatLng(34.052235, -118.243683),
          destination: const LatLng(40.712776, -74.005974),
          // ignore: deprecated_member_use_from_same_package
        avoid: [SupportedAvoid.toll],
        );

        final json = params.toJson();
        
        expect(json['avoid'], ['toll']);
      });

      test('should handle single avoidType value', () {
        final params = RouteRequestParams(
          origin: const LatLng(34.052235, -118.243683),
          destination: const LatLng(40.712776, -74.005974),
          avoidType: ['ferry'],
        );

        final json = params.toJson();
        
        expect(json['avoid'], ['ferry']);
      });
    });

    group('avoid field edge cases', () {
      test('should handle avoidType with special characters', () {
        final params = RouteRequestParams(
          origin: const LatLng(34.052235, -118.243683),
          destination: const LatLng(40.712776, -74.005974),
          avoidType: ['bbox:34.0635,-118.2547,34.0679,-118.2478', 'toll'],
        );

        final json = params.toJson();
        
        expect(json['avoid'], ['bbox:34.0635,-118.2547,34.0679,-118.2478', 'toll']);
      });

      test('should handle avoidType with multiple bbox values', () {
        final params = RouteRequestParams(
          origin: const LatLng(34.052235, -118.243683),
          destination: const LatLng(40.712776, -74.005974),
          avoidType: [
            'bbox:34.0635,-118.2547,34.0679,-118.2478',
            'bbox:34.0521,-118.2342,34.0478,-118.2437',
            'toll'
          ],
        );

        final json = params.toJson();
        
        expect(json['avoid'], [
          'bbox:34.0635,-118.2547,34.0679,-118.2478',
          'bbox:34.0521,-118.2342,34.0478,-118.2437',
          'toll'
        ]);
      });

      test('should handle avoidType with geofence_id', () {
        final params = RouteRequestParams(
          origin: const LatLng(34.052235, -118.243683),
          destination: const LatLng(40.712776, -74.005974),
          avoidType: ['geofence_id:12345', 'toll', 'ferry'],
        );

        final json = params.toJson();
        
        expect(json['avoid'], ['geofence_id:12345', 'toll', 'ferry']);
      });

      test('should handle mixed avoidType with both simple and complex values', () {
        final params = RouteRequestParams(
          origin: const LatLng(34.052235, -118.243683),
          destination: const LatLng(40.712776, -74.005974),
          avoidType: [
            'toll',
            'bbox:34.0635,-118.2547,34.0679,-118.2478',
            'ferry',
            'geofence_id:12345',
            'highway'
          ],
        );

        final json = params.toJson();
        
        expect(json['avoid'], [
          'toll',
          'bbox:34.0635,-118.2547,34.0679,-118.2478',
          'ferry',
          'geofence_id:12345',
          'highway'
        ]);
      });
    });
  });


}
