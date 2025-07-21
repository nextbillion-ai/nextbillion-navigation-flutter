import 'package:flutter_test/flutter_test.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

void main() {
  group('CurrentStepProgress', () {
    test('fromJson should return a valid CurrentStepProgress object', () {
      // Arrange
      final json = {
        'durationRemaining': 300.0,
        'distanceRemaining': 1000.0,
        'distanceTraveled': 500.0,
        'fractionTraveled': 0.5,
      };

      // Act
      final currentStepProgress = CurrentStepProgress.fromJson(json);

      // Assert
      expect(currentStepProgress.durationRemaining, 300.0);
      expect(currentStepProgress.distanceRemaining, 1000.0);
      expect(currentStepProgress.distanceTraveled, 500.0);
      expect(currentStepProgress.fractionTraveled, 0.5);
    });

    test('toJson should return a valid JSON map', () {
      // Arrange
      final currentStepProgress = CurrentStepProgress(
        durationRemaining: 300.0,
        distanceRemaining: 1000.0,
        distanceTraveled: 500.0,
        fractionTraveled: 0.5,
      );

      // Act
      final json = currentStepProgress.toJson();

      // Assert
      expect(json['durationRemaining'], 300.0);
      expect(json['distanceRemaining'], 1000.0);
      expect(json['distanceTraveled'], 500.0);
      expect(json['fractionTraveled'], 0.5);
    });

    test('toString should return a valid string representation', () {
      // Arrange
      final currentStepProgress = CurrentStepProgress(
        durationRemaining: 300.0,
        distanceRemaining: 1000.0,
        distanceTraveled: 500.0,
        fractionTraveled: 0.5,
      );

      // Act
      final stringRepresentation = currentStepProgress.toString();

      // Assert
      expect(
        stringRepresentation,
        'CurrentStepProgress(durationRemaining: 300.0, distanceRemaining: 1000.0, distanceTraveled: 500.0, fractionTraveled: 0.5)',
      );
    });
  });
}
