part of nb_navigation_flutter;

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
    return NavigationProgress(
      location: json['location'] != null
          ? LatLng(
        json['location']["latitude"],
        json['location']["longitude"],
      )
          : null,
      distanceRemaining: json['distanceRemaining'],
      durationRemaining: json['durationRemaining'],
      currentLegIndex: json['currentLegIndex'],
      currentStepIndex: json['currentStepIndex'],
      distanceTraveled: json['distanceTraveled'],
      fractionTraveled: json['fractionTraveled'],
      remainingWaypoints: json['remainingWaypoints'],
      currentStepPointIndex: json['currentStepPointIndex'],
      isFinalLeg: json['isFinalLeg'],
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
