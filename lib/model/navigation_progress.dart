part of '../nb_navigation_flutter.dart';

class NavigationProgress {
  LatLng? location;
  num? distanceRemaining;
  num? durationRemaining;
  int? currentLegIndex;
  int? currentStepIndex;
  num? distanceTraveled;
  num? fractionTraveled;
  int? remainingWaypoints;
  int? currentStepPointIndex;
  bool? isFinalLeg;

  NavigationProgress({
    this.location,
    this.distanceRemaining,
    this.durationRemaining,
    this.currentLegIndex,
    this.currentStepIndex,
    this.distanceTraveled,
    this.fractionTraveled,
    this.remainingWaypoints,
    this.currentStepPointIndex,
    this.isFinalLeg,
  });

  factory NavigationProgress.fromJson(Map<String, dynamic> json) {
    final locationData = json['location'];
    LatLng? location;
    if (locationData != null && locationData is Map<String, dynamic>) {
      final latitude = (locationData['latitude'] as num?)?.toDouble();
      final longitude = (locationData['longitude'] as num?)?.toDouble();
      if (latitude != null && longitude != null) {
        location = LatLng(
          latitude,  // Safely convert to double
          longitude, // Safely convert to double
        );
      }
    }

    return NavigationProgress(
      location: location,
      distanceRemaining: (json['distanceRemaining'] as num?)?.toDouble(),
      durationRemaining: (json['durationRemaining'] as num?)?.toDouble(),
      currentLegIndex: json['currentLegIndex'] as int?,
      currentStepIndex: json['currentStepIndex'] as int?,
      distanceTraveled: (json['distanceTraveled'] as num?)?.toDouble(),
      fractionTraveled: (json['fractionTraveled'] as num?)?.toDouble(),
      remainingWaypoints: json['remainingWaypoints'] as int?,
      currentStepPointIndex: json['currentStepPointIndex'] as int?,
      isFinalLeg: json['isFinalLeg'] as bool? ?? false, // Defaults to false if null
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'location': {
        "latitude": location?.latitude,
        "longitude": location?.longitude
      },
      'distanceRemaining': distanceRemaining,
      'durationRemaining': durationRemaining,
      'currentLegIndex': currentLegIndex,
      'currentStepIndex': currentStepIndex,
      'distanceTraveled': distanceTraveled,
      'fractionTraveled': fractionTraveled,
      'remainingWaypoints': remainingWaypoints,
      'currentStepPointIndex': currentStepPointIndex,
      'isFinalLeg': isFinalLeg,
    };
  }

  @override
  String toString() {
    return 'NavigationProgress(location: $location, distanceRemaining: $distanceRemaining, durationRemaining: $durationRemaining, currentLegIndex: $currentLegIndex, currentStepIndex: $currentStepIndex, distanceTraveled: $distanceTraveled, fractionTraveled: $fractionTraveled, remainingWaypoints: $remainingWaypoints, currentStepPointIndex: $currentStepPointIndex, isFinalLeg: $isFinalLeg)';
  }
}
