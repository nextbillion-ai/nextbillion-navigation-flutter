part of '../nb_navigation_flutter.dart';

class CurrentStepProgress {
  num? durationRemaining;
  num? distanceRemaining;
  num? distanceTraveled;
  num? fractionTraveled;

  CurrentStepProgress({
    this.durationRemaining,
    this.distanceRemaining,
    this.distanceTraveled,
    this.fractionTraveled,
  });

  factory CurrentStepProgress.fromJson(Map<String, dynamic> json) {
    return CurrentStepProgress(
      durationRemaining: (json['durationRemaining'] as num?)?.toDouble(),
      distanceRemaining: (json['distanceRemaining'] as num?)?.toDouble(),
      distanceTraveled: (json['distanceTraveled'] as num?)?.toDouble(),
      fractionTraveled: (json['fractionTraveled'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'durationRemaining': durationRemaining,
      'distanceRemaining': distanceRemaining,
      'distanceTraveled': distanceTraveled,
      'fractionTraveled': fractionTraveled,
    };
  }

  @override
  String toString() {
    return 'CurrentStepProgress(durationRemaining: $durationRemaining, distanceRemaining: $distanceRemaining, distanceTraveled: $distanceTraveled, fractionTraveled: $fractionTraveled)';
  }
} 