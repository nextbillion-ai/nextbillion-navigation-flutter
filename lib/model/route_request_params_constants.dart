part of '../nb_navigation_flutter.dart';

enum SupportedUnits {
  /// Imperial units (e.g., miles, feet).
  imperial,

  /// Metric units (e.g., kilometers, meters).
  metric;

  static SupportedUnits fromValue(String? s) =>
      switch (s) { "imperial" => imperial, "metric" => metric, _ => metric };
}

enum ValidModes {
  /// Travel mode: car.
  car,

  /// Travel mode: truck.
  truck,

  /// Travel mode: bike.
  bike,

  /// Travel mode: motorcycle.
  motorcycle;

  static ValidModes fromValue(String? s) => switch (s) {
        "car" => car,
        "truck" => truck,
        "bike" => bike,
        "motorcycle" => motorcycle,
        _ => car
      };
}

enum SupportedAvoid {
  /// Avoid tolls during the route.
  toll,

  /// Avoid ferries during the route.
  ferry,

  /// Avoid highways during the route.
  highway,

  /// Avoid uTurn during the route.
  uTurn,

  /// Avoid sharpTurn during the route.
  sharpTurn,

  /// Avoid serviceRoad during the route.
  serviceRoad,

  /// Avoid noting during the route.
  none;

  static SupportedAvoid fromValue(String? s) => switch (s) {
        "toll" => toll,
        "ferry" => ferry,
        "highway" => highway,
        "uturn" => uTurn,
        "sharp_turn" => sharpTurn,
        "service_road" => serviceRoad,
        "none" => none,
        _ => ferry
      };
}

enum ValidOverview {
  /// Show a full overview of the route with all details.
  full,

  /// Show a simplified overview of the route.
  simplified,

  /// Show no overview (only the route's geometry).
  none;

  static ValidOverview fromValue(String? s) => switch (s) {
        "full" => full,
        "simplified" => simplified,
        "false" => none,
        _ => full
      };
}

enum SupportedGeometry {
  /// Use polyline format for route geometry.
  polyline,

  /// Use polyline6 format for route geometry.
  polyline6;

  static SupportedGeometry fromValue(String? s) => switch (s) {
        "polyline" => polyline,
        "polyline6" => polyline6,
        _ => polyline6
      };
}

enum SupportedOption {
  flexible,
  fast;

  static SupportedOption? fromValue(String? s) => switch (s) {
        "flexible" => flexible,
        "fast" => fast,
        _ => fast,
      };
}

enum SupportedHazmatType {
  general,
  circumstantial,
  explosive,
  harmfulToWater;

  static SupportedHazmatType? fromValue(String? s) => switch (s) {
        "general" => general,
        "circumstantial" => circumstantial,
        "explosive" => explosive,
        "harmful_to_water" => harmfulToWater,
        _ => null,
      };
}

enum SupportedApproaches {
  curb,
  unrestricted;

  static SupportedApproaches? fromValue(String? s) => switch (s) {
        "curb" => curb,
        "unrestricted" => unrestricted,
        _ => null,
      };
}

extension EnumExtension on Enum {
  String get description {
    if (this == ValidOverview.none) {
      return "false";
    }
    if (this == SupportedHazmatType.harmfulToWater) {
      return "harmful_to_water";
    }
    if (this == SupportedAvoid.uTurn) {
      return "uturn";
    }
    if (this == SupportedAvoid.sharpTurn) {
      return "sharp_turn";
    }
    if (this == SupportedAvoid.serviceRoad) {
      return "service_road";
    }
    if (this == SupportedPrefer.truckRoute) {
      return "truck_route";
    }
    if (this == SupportedTruckType.rigidTruck) {
      return "rigid_truck";
    }
    if (this == SupportedTruckType.semiTrailer) {
      return "semi_trailer";
    }
    if (this == SupportedTruckType.bDouble) {
      return "b_double";
    }
    if (this == SupportedTruckType.roadTrain) {
      return "road_train";
    }
    if (this == SupportedTruckType.genericTruck) {
      return "generic_truck";
    }
    return toString().split('.').last;
  }
}

enum RouteType {
  /// Route type: fastest.
  fastest,

  /// Route type: shortest.
  shortest;

  static RouteType fromValue(String? s) =>
      switch (s) { "fastest" => fastest, "shortest" => shortest, _ => fastest };

  String get description {
    if (this == RouteType.shortest) {
      return "shortest";
    }
    return "fastest";
  }
}

enum SupportedPrefer {
  /// Prioritizes truck-friendly roads when calculating routes.
  /// This configuration aims to maximize truck-friendly road inclusion in the final route.
  /// It is effective only when option=flexible and mode=truck.
  /// Please note that the truck_type setting is ineffective without this parameter.
  truckRoute;

  static SupportedPrefer? fromValue(String? s) => switch (s) {
        "truck_route" => truckRoute,
        _ => null,
      };

  String get description => "truck_route";
}

enum SupportedTruckType {
  /// Rigid truck type.
  rigidTruck,

  /// Semi-trailer truck type.
  semiTrailer,

  /// B-double truck type.
  bDouble,

  /// Road train truck type.
  roadTrain,

  /// Generic truck type.
  genericTruck;

  static SupportedTruckType? fromValue(String? s) => switch (s) {
        "rigid_truck" => rigidTruck,
        "semi_trailer" => semiTrailer,
        "b_double" => bDouble,
        "road_train" => roadTrain,
        "generic_truck" => genericTruck,
        _ => null,
      };
}
