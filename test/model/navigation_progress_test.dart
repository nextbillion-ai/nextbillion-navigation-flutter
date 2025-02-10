import 'package:flutter_test/flutter_test.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

void main() {
  group('NavigationProgress', () {
    test('fromJson should return a valid NavigationProgress object', () {
      // Arrange
      final json = {
        'location': {
          'latitude': 12.34,
          'longitude': 56.78,
        },
        'distanceRemaining': 1000,
        'durationRemaining': 300,
        'currentLegIndex': 1,
        'currentStepIndex': 2,
        'distanceTraveled': 500,
        'fractionTraveled': 0.5,
        'remainingWaypoints': 3,
        'currentStepPointIndex': 4,
        'isFinalLeg': true,
      };

      // Act
      final navigationProgress = NavigationProgress.fromJson(json);

      // Assert
      expect(navigationProgress.location?.latitude, 12.34);
      expect(navigationProgress.location?.longitude, 56.78);
      expect(navigationProgress.distanceRemaining, 1000);
      expect(navigationProgress.durationRemaining, 300);
      expect(navigationProgress.currentLegIndex, 1);
      expect(navigationProgress.currentStepIndex, 2);
      expect(navigationProgress.distanceTraveled, 500);
      expect(navigationProgress.fractionTraveled, 0.5);
      expect(navigationProgress.remainingWaypoints, 3);
      expect(navigationProgress.currentStepPointIndex, 4);
      expect(navigationProgress.isFinalLeg, true);
    });

    test('toJson should return a valid JSON map', () {
      // Arrange
      final navigationProgress = NavigationProgress(
        location: const LatLng(12.34, 56.78),
        distanceRemaining: 1000,
        durationRemaining: 300,
        currentLegIndex: 1,
        currentStepIndex: 2,
        distanceTraveled: 500,
        fractionTraveled: 0.5,
        remainingWaypoints: 3,
        currentStepPointIndex: 4,
        isFinalLeg: true,
      );

      // Act
      final json = navigationProgress.toJson();

      // Assert
      expect(json['location']['latitude'], 12.34);
      expect(json['location']['longitude'], 56.78);
      expect(json['distanceRemaining'], 1000);
      expect(json['durationRemaining'], 300);
      expect(json['currentLegIndex'], 1);
      expect(json['currentStepIndex'], 2);
      expect(json['distanceTraveled'], 500);
      expect(json['fractionTraveled'], 0.5);
      expect(json['remainingWaypoints'], 3);
      expect(json['currentStepPointIndex'], 4);
      expect(json['isFinalLeg'], true);
    });

    test('toString should return a valid string representation', () {
      // Arrange
      final navigationProgress = NavigationProgress(
        location: const LatLng(12.34, 56.78),
        distanceRemaining: 1000,
        durationRemaining: 300,
        currentLegIndex: 1,
        currentStepIndex: 2,
        distanceTraveled: 500,
        fractionTraveled: 0.5,
        remainingWaypoints: 3,
        currentStepPointIndex: 4,
        isFinalLeg: true,
      );

      // Act
      final stringRepresentation = navigationProgress.toString();

      // Assert
      expect(
        stringRepresentation,
        'NavigationProgress(location: LatLng(12.34, 56.78), distanceRemaining: 1000, durationRemaining: 300, currentLegIndex: 1, currentStepIndex: 2, distanceTraveled: 500, fractionTraveled: 0.5, remainingWaypoints: 3, currentStepPointIndex: 4, isFinalLeg: true)',
      );
    });
  });
}
