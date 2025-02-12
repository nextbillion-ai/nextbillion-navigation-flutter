part of '../nb_navigation_flutter.dart';

class DirectionsRoute {
  num? distance;
  num? duration;
  String? geometry;
  List<Leg> legs;
  String? routeIndex;
  RouteRequestParams? routeOptions;
  num? weight;
  String? weightName;
  String? countryCode;
  String? voiceLanguage;
  List<CongestionLevel>? congestion;

  DirectionsRoute({
    this.distance,
    this.duration,
    this.geometry,
    required this.legs,
    this.routeIndex,
    this.routeOptions,
    this.weight,
    this.countryCode,
    this.weightName,
    this.voiceLanguage,
    this.congestion,
  });

  factory DirectionsRoute.fromJson(Map<String, dynamic> map) {
    return DirectionsRoute(
      distance: map['distance'] ?? 0.0,
      duration: map['duration'] ?? 0.0,
      geometry: map['geometry'] ?? '',
      legs: List<Leg>.from(map['legs']?.map((leg) => Leg.fromJson(leg)) ?? []),
      routeIndex: map['routeIndex'] ?? '',
      routeOptions: RouteRequestParams.fromJson(map['routeOptions'] ?? {}),
      weight: map['weight'],
      countryCode: map['countryCode'],
      weightName: map['weight_name'],
      voiceLanguage: map['voiceLocale'],
      congestion: List<CongestionLevel>.from(map['congestion']
              ?.map((level) => CongestionLevelExtension.fromValue(level)) ??
          []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distance': distance,
      'duration': duration,
      'geometry': geometry,
      'legs': legs.map((x) => x.toJson()).toList(),
      'routeIndex': routeIndex,
      'routeOptions': routeOptions?.toJson(),
      'weight': weight,
      'countryCode': countryCode,
      'weight_name': weightName,
      'voiceLocale': voiceLanguage,
      "congestion":
          congestion?.map((congestion) => congestion.index).toList() ?? [],
    };
  }
}

class Leg {
  Distance? distance;
  TimeDuration? duration;
  List<RouteStep>? steps;
  String? summary;

  Leg({this.distance, this.duration, this.steps, this.summary});

  factory Leg.fromJson(Map<String, dynamic> map) {
    return Leg(
      distance: Distance.fromJson(map['distance'] ?? {}),
      duration: TimeDuration.fromJson(map['duration'] ?? {}),
      steps: List<RouteStep>.from(
          map['steps']?.map((step) => RouteStep.fromJson(step)) ?? []),
      summary: map['summary'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distance': distance?.toJson(),
      'duration': duration?.toJson(),
      'steps': steps?.map((x) => x.toJson()).toList(),
      'summary': summary,
    };
  }
}

class Distance {
  num? value;

  Distance({
    this.value,
  });

  factory Distance.fromJson(Map<String, dynamic> map) {
    return Distance(
      value: map['value'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }
}

class TimeDuration {
  num? value;

  TimeDuration({
    this.value,
  });

  factory TimeDuration.fromJson(Map<String, dynamic> map) {
    return TimeDuration(
      value: map['value'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }
}
