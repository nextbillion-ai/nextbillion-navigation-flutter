part of '../nb_navigation_flutter.dart';

class Waypoint {
  LatLng? arrivedWaypointLocation;
  int? arrivedWaypointIndex;

  Waypoint({
    this.arrivedWaypointLocation,
    this.arrivedWaypointIndex,
  });

  factory Waypoint.fromJson(Map<String, dynamic> json) {
    final locationData = json['location'] as Map<String, dynamic>?;

    return Waypoint(
      arrivedWaypointLocation: locationData != null
          ? LatLng(
        locationData["latitude"] as double,
        locationData["longitude"] as double,
      )
          : null,
      arrivedWaypointIndex: json['arrivedWaypointIndex'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': {
        "latitude": arrivedWaypointLocation?.latitude,
        "longitude": arrivedWaypointLocation?.longitude
      },
      'arrivedWaypointIndex': arrivedWaypointIndex,
    };
  }

  @override
  String toString() {
    return 'NavigationProgress(location: $arrivedWaypointLocation, arrivedWaypointIndex: $arrivedWaypointIndex)';
  }
}
