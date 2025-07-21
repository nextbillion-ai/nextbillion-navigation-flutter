import 'package:flutter_test/flutter_test.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

void main() {
  group('CurrentLegProgress', () {
    test('fromJson should return a valid CurrentLegProgress object', () {
      // Arrange
      final json = {
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
      };

      // Act
      final currentLegProgress = CurrentLegProgress.fromJson(json);

      // Assert
      expect(currentLegProgress.durationRemaining, 600.0);
      expect(currentLegProgress.distanceRemaining, 2000.0);
      expect(currentLegProgress.distanceTraveled, 1000.0);
      expect(currentLegProgress.fractionTraveled, 0.5);
      expect(currentLegProgress.currentStepIndex, 2);
      expect(currentLegProgress.currentStepProgress?.durationRemaining, 300.0);
      expect(currentLegProgress.currentStepProgress?.distanceRemaining, 1000.0);
      expect(currentLegProgress.currentStepProgress?.distanceTraveled, 500.0);
      expect(currentLegProgress.currentStepProgress?.fractionTraveled, 0.5);
    });

    test('toJson should return a valid JSON map', () {
      // Arrange
      final currentLegProgress = CurrentLegProgress(
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
      );

      // Act
      final json = currentLegProgress.toJson();

      // Assert
      expect(json['durationRemaining'], 600.0);
      expect(json['distanceRemaining'], 2000.0);
      expect(json['distanceTraveled'], 1000.0);
      expect(json['fractionTraveled'], 0.5);
      expect(json['currentStepIndex'], 2);
      expect((json['currentStepProgress'] as Map<String, dynamic>)['durationRemaining'], 300.0);
      expect((json['currentStepProgress'] as Map<String, dynamic>)['distanceRemaining'], 1000.0);
      expect((json['currentStepProgress'] as Map<String, dynamic>)['distanceTraveled'], 500.0);
      expect((json['currentStepProgress'] as Map<String, dynamic>)['fractionTraveled'], 0.5);
    });

    test('toString should return a valid string representation', () {
      // Arrange
      final currentLegProgress = CurrentLegProgress(
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
      );

      // Act
      final stringRepresentation = currentLegProgress.toString();

      // Assert
      expect(
        stringRepresentation,
        'CurrentLegProgress(durationRemaining: 600.0, distanceRemaining: 2000.0, distanceTraveled: 1000.0, fractionTraveled: 0.5, currentStepIndex: 2, currentStepProgress: CurrentStepProgress(durationRemaining: 300.0, distanceRemaining: 1000.0, distanceTraveled: 500.0, fractionTraveled: 0.5))',
      );
    });
  });
} 