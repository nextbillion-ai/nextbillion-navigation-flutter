part of nb_navigation_flutter;

class Waypoint {
  LatLng? arrivedWaypointLocation;
  int? arrivedWaypointIndex;

  Waypoint({
    this.arrivedWaypointLocation,
    this.arrivedWaypointIndex,
  });

  factory Waypoint.fromJson(Map<String, dynamic> json) {
    return Waypoint(
      arrivedWaypointLocation: json['location'] != null
          ? LatLng(
              json['location']["latitude"],
              json['location']["longitude"],
            )
          : null,
      arrivedWaypointIndex: json['arrivedWaypointIndex'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': {"latitude": arrivedWaypointLocation?.latitude, "longitude": arrivedWaypointLocation?.longitude},
      'arrivedWaypointIndex': arrivedWaypointIndex,
    };
  }

  @override
  String toString() {
    return 'NavigationProgress(location: $arrivedWaypointLocation, arrivedWaypointIndex: $arrivedWaypointIndex)';
  }
}
