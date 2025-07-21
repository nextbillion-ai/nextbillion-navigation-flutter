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
        'currentLegProgress': {
          'durationRemaining': 600.0,
          'distanceRemaining': 2000.0,
          'distanceTraveled': 1000.0,
          'fractionTraveled': 0.5,
          'currentStepIndex': 2,
          'currentStepProgress': {
            'durationRemaining': 300.0,
            'distanceRemaining': 1000.0,
            'distanceTraveled': 500.0,
            'fractionTraveled': 0.5,
          },
        },
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
      expect(navigationProgress.currentLegProgress?.durationRemaining, 600.0);
      expect(navigationProgress.currentLegProgress?.distanceRemaining, 2000.0);
      expect(navigationProgress.currentLegProgress?.currentStepIndex, 2);
      expect(navigationProgress.currentLegProgress?.currentStepProgress?.durationRemaining, 300.0);
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
        currentLegProgress: CurrentLegProgress(
          durationRemaining: 600.0,
          distanceRemaining: 2000.0,
          distanceTraveled: 1000.0,
          fractionTraveled: 0.5,
          currentStepIndex: 2,
          currentStepProgress: CurrentStepProgress(
            durationRemaining: 300.0,
            distanceRemaining: 1000.0,
            distanceTraveled: 500.0,
            fractionTraveled: 0.5,
          ),
        ),
      );

      // Act
      final json = navigationProgress.toJson();

      // Assert
      expect((json['location'] as Map<String,dynamic>)['latitude'], 12.34);
      expect((json['location'] as Map<String,dynamic>)['longitude'], 56.78);
      expect(json['distanceRemaining'], 1000);
      expect(json['durationRemaining'], 300);
      expect(json['currentLegIndex'], 1);
      expect(json['currentStepIndex'], 2);
      expect(json['distanceTraveled'], 500);
      expect(json['fractionTraveled'], 0.5);
      expect(json['remainingWaypoints'], 3);
      expect(json['currentStepPointIndex'], 4);
      expect(json['isFinalLeg'], true);
      expect((json['currentLegProgress'] as Map<String, dynamic>)['durationRemaining'], 600.0);
      expect((json['currentLegProgress'] as Map<String, dynamic>)['distanceRemaining'], 2000.0);
      expect((json['currentLegProgress'] as Map<String, dynamic>)['currentStepIndex'], 2);
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
        currentLegProgress: CurrentLegProgress(
          durationRemaining: 600.0,
          distanceRemaining: 2000.0,
          distanceTraveled: 1000.0,
          fractionTraveled: 0.5,
          currentStepIndex: 2,
          currentStepProgress: CurrentStepProgress(
            durationRemaining: 300.0,
            distanceRemaining: 1000.0,
            distanceTraveled: 500.0,
            fractionTraveled: 0.5,
          ),
        ),
      );

      // Act
      final stringRepresentation = navigationProgress.toString();

      // Assert
      expect(
        stringRepresentation,
        'NavigationProgress(location: LatLng(12.34, 56.78), distanceRemaining: 1000, durationRemaining: 300, currentLegIndex: 1, currentStepIndex: 2, distanceTraveled: 500, fractionTraveled: 0.5, remainingWaypoints: 3, currentStepPointIndex: 4, isFinalLeg: true, currentLegProgress: CurrentLegProgress(durationRemaining: 600.0, distanceRemaining: 2000.0, distanceTraveled: 1000.0, fractionTraveled: 0.5, currentStepIndex: 2, currentStepProgress: CurrentStepProgress(durationRemaining: 300.0, distanceRemaining: 1000.0, distanceTraveled: 500.0, fractionTraveled: 0.5)))',
      );
    });
  });
}
