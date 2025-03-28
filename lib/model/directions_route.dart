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
      distance: map['distance'] as num?,
      duration: map['duration'] as num?,
      geometry: map['geometry'] as String?,
      legs: (map['legs'] as List?)
          ?.whereType<Map<dynamic, dynamic>>() // Filter only valid maps
          .map((leg) {
        final Map<String, dynamic> convertedMap = leg.cast<String, dynamic>();
        // final Map<String, dynamic> convertedMap = Map<String, dynamic>.from(leg);
        return Leg.fromJson(convertedMap);
      })
          .toList() ??
          [],
      routeIndex: map['routeIndex'] as String?,
      routeOptions: map['routeOptions'] != null
          ? RouteRequestParams.fromJson(
          map['routeOptions'] as Map<String, dynamic>)
          :  throw ArgumentError('routeOptions cannot be null'),
      weight: map['weight'] as num?,
      countryCode: map['countryCode'] as String?,
      weightName: map['weight_name'] as String?,
      voiceLanguage: map['voiceLocale'] as String?,
      congestion: (map['congestion'] as List<dynamic>?)
          ?.map((level) =>
          CongestionLevelExtension.fromValue(level as int))
          .toList() ??
          [],
    );
  }

  factory DirectionsRoute.fromJsonWithOption(Map<String, dynamic> map,RouteRequestParams option) {
    return DirectionsRoute(
      distance: map['distance'] as num?,
      duration: map['duration'] as num?,
      geometry: map['geometry'] as String?,
      legs: (map['legs'] as List?)
          ?.whereType<Map<dynamic, dynamic>>() // Filter only valid maps
          .map((leg) {
        final Map<String, dynamic> convertedMap = leg.cast<String, dynamic>();
        // final Map<String, dynamic> convertedMap = Map<String, dynamic>.from(leg);
        return Leg.fromJson(convertedMap);
      })
          .toList() ??
          [],
      routeIndex: map['routeIndex'] as String?,
      routeOptions: option,
      weight: map['weight'] as num?,
      countryCode: map['countryCode'] as String?,
      weightName: map['weight_name'] as String?,
      voiceLanguage: map['voiceLocale'] as String?,
      congestion: (map['congestion'] as List<dynamic>?)
          ?.map((level) =>
          CongestionLevelExtension.fromValue(level as int))
          .toList() ??
          [],
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
      distance: map['distance'] != null
          ? Distance.fromJson(map['distance'] as Map<String, dynamic>)
          : null,
      duration: map['duration'] != null
          ? TimeDuration.fromJson(map['duration'] as Map<String, dynamic>)
          : null,
      steps: (map['steps'] as List<dynamic>?)
          ?.whereType<Map<dynamic, dynamic>>() // Fi
          .map((step) {
        final Map<String, dynamic> convertedMap = step.cast<String, dynamic>();
        // final Map<String, dynamic> convertedMap = Map<String, dynamic>.from(step);
            return RouteStep.fromJson(convertedMap);
      }).toList() ??
          [],
      summary: map['summary'] as String?,
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
      value: (map['value'] as num?) ?? 0.0,
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
      value: (map['value'] as num?) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
    };
  }
}
