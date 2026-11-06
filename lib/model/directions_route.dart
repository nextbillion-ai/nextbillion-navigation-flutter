part of '../nb_navigation_flutter.dart';

class DirectionsRoute {
  Map<String, dynamic>? _nativeJson;
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
  Map<String, dynamic>? roadInfo;

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
    this.roadInfo,
  });

  factory DirectionsRoute.fromJson(Map<String, dynamic> map) {
    return DirectionsRoute(
      distance: map['distance'] as num?,
      duration: map['duration'] as num?,
      geometry: map['geometry'] as String?,
      legs: (map['legs'] as List?)
              ?.whereType<Map<dynamic, dynamic>>() // Filter only valid maps
              .map((leg) {
            final Map<String, dynamic> convertedMap =
                leg.cast<String, dynamic>();
            return Leg.fromJson(convertedMap);
          }).toList() ??
          [],
      routeIndex: map['routeIndex'] as String?,
      routeOptions: map['routeOptions'] != null
          ? RouteRequestParams.fromJson(
              map['routeOptions'] as Map<String, dynamic>)
          : throw ArgumentError('routeOptions cannot be null'),
      weight: map['weight'] as num?,
      countryCode: map['countryCode'] as String?,
      weightName: map['weight_name'] as String?,
      voiceLanguage: map['voiceLocale'] as String?,
      congestion: (map['congestion'] as List<dynamic>?)
              ?.map((level) => CongestionLevelExtension.fromValue(level as int))
              .toList() ??
          [],
      roadInfo:
          (map['road_info'] as Map<dynamic, dynamic>?)?.cast<String, dynamic>(),
    ).._nativeJson = _copyRouteJson(map);
  }

  factory DirectionsRoute.fromJsonWithOption(
      Map<String, dynamic> map, RouteRequestParams option) {
    return DirectionsRoute(
      distance: map['distance'] as num?,
      duration: map['duration'] as num?,
      geometry: map['geometry'] as String?,
      legs: (map['legs'] as List?)
              ?.whereType<Map<dynamic, dynamic>>() // Filter only valid maps
              .map((leg) {
            final Map<String, dynamic> convertedMap =
                leg.cast<String, dynamic>();
            return Leg.fromJson(convertedMap);
          }).toList() ??
          [],
      routeIndex: map['routeIndex'] as String?,
      routeOptions: option,
      weight: map['weight'] as num?,
      countryCode: map['countryCode'] as String?,
      weightName: map['weight_name'] as String?,
      voiceLanguage: map['voiceLocale'] as String?,
      congestion: (map['congestion'] as List<dynamic>?)
              ?.map((level) => CongestionLevelExtension.fromValue(level as int))
              .toList() ??
          [],
      roadInfo:
          (map['road_info'] as Map<dynamic, dynamic>?)?.cast<String, dynamic>(),
    ).._nativeJson = _copyRouteJson(map);
  }

  Map<String, dynamic> toJson() {
    return _mergeRouteJson(_nativeJson, {
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
      'road_info': roadInfo,
    });
  }
}

// Retain native annotations and future SDK fields through a Dart round trip.
// Merge modeled values recursively so application edits still take effect.
Map<String, dynamic> _copyRouteJson(Map<String, dynamic> map) =>
    (_copyRouteValue(map) as Map).cast<String, dynamic>();

dynamic _copyRouteValue(dynamic value) {
  if (value is Map) {
    return value.map(
        (dynamic key, dynamic item) => MapEntry(key, _copyRouteValue(item)));
  }
  if (value is List) return value.map(_copyRouteValue).toList();
  return value;
}

Map<String, dynamic> _mergeRouteJson(
    Map<String, dynamic>? original, Map<String, dynamic> updated) {
  dynamic merge(dynamic old, dynamic value) {
    if (value is Map) {
      return <String, dynamic>{
        if (old is Map) ...old.cast<String, dynamic>(),
        for (final entry in value.entries)
          entry.key as String:
              merge(old is Map ? old[entry.key] : null, entry.value),
      };
    }
    if (value is List) {
      return [
        for (var index = 0; index < value.length; index++)
          merge(old is List && index < old.length ? old[index] : null,
              value[index])
      ];
    }
    return value;
  }

  return (merge(_copyRouteValue(original), updated) as Map)
      .cast<String, dynamic>();
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
            final Map<String, dynamic> convertedMap =
                step.cast<String, dynamic>();
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
