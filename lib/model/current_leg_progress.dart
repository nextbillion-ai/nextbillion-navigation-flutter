part of '../nb_navigation_flutter.dart';

class CurrentLegProgress {
  num? durationRemaining;
  num? distanceRemaining;
  num? distanceTraveled;
  num? fractionTraveled;
  int? currentStepIndex;
  CurrentStepProgress? currentStepProgress;

  CurrentLegProgress({
    this.durationRemaining,
    this.distanceRemaining,
    this.distanceTraveled,
    this.fractionTraveled,
    this.currentStepIndex,
    this.currentStepProgress,
  });

  factory CurrentLegProgress.fromJson(Map<String, dynamic> json) {
    final currentStepProgressData = json['currentStepProgress'];
    CurrentStepProgress? currentStepProgress;
    if (currentStepProgressData != null && currentStepProgressData is Map<String, dynamic>) {
      currentStepProgress = CurrentStepProgress.fromJson(currentStepProgressData);
    }

    return CurrentLegProgress(
      durationRemaining: (json['durationRemaining'] as num?)?.toDouble(),
      distanceRemaining: (json['distanceRemaining'] as num?)?.toDouble(),
      distanceTraveled: (json['distanceTraveled'] as num?)?.toDouble(),
      fractionTraveled: (json['fractionTraveled'] as num?)?.toDouble(),
      currentStepIndex: json['currentStepIndex'] as int?,
      currentStepProgress: currentStepProgress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'durationRemaining': durationRemaining,
      'distanceRemaining': distanceRemaining,
      'distanceTraveled': distanceTraveled,
      'fractionTraveled': fractionTraveled,
      'currentStepIndex': currentStepIndex,
      'currentStepProgress': currentStepProgress?.toJson(),
    };
  }

  @override
  String toString() {
    return 'CurrentLegProgress(durationRemaining: $durationRemaining, distanceRemaining: $distanceRemaining, distanceTraveled: $distanceTraveled, fractionTraveled: $fractionTraveled, currentStepIndex: $currentStepIndex, currentStepProgress: $currentStepProgress)';
  }
} 