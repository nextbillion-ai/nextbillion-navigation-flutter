import 'package:flutter_test/flutter_test.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

void main() {
  group('Waypoint', () {
    test('fromJson should return a valid Waypoint object', () {
      // Arrange
      final json = {
        'location': {
          'latitude': 12.34,
          'longitude': 56.78,
        },
        'arrivedWaypointIndex': 1,
      };

      // Act
      final waypoint = Waypoint.fromJson(json);

      // Assert
      expect(waypoint.arrivedWaypointLocation?.latitude, 12.34);
      expect(waypoint.arrivedWaypointLocation?.longitude, 56.78);
      expect(waypoint.arrivedWaypointIndex, 1);
    });

    test('toJson should return a valid JSON map', () {
      // Arrange
      final waypoint = Waypoint(
        arrivedWaypointLocation: const LatLng(12.34, 56.78),
        arrivedWaypointIndex: 1,
      );

      // Act
      final json = waypoint.toJson();

      // Assert
      expect(json['location']['latitude'], 12.34);
      expect(json['location']['longitude'], 56.78);
      expect(json['arrivedWaypointIndex'], 1);
    });

    test('toString should return a valid string representation', () {
      // Arrange
      final waypoint = Waypoint(
        arrivedWaypointLocation: const LatLng(12.34, 56.78),
        arrivedWaypointIndex: 1,
      );

      // Act
      final stringRepresentation = waypoint.toString();

      // Assert
      expect(
        stringRepresentation,
        'NavigationProgress(location: LatLng(12.34, 56.78), arrivedWaypointIndex: 1)',
      );
    });
  });
}
