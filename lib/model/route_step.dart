part of '../nb_navigation_flutter.dart';

class RouteStep {
  List<BannerInstructions>? bannerInstructions;
  String? drivingSide;
  String? geometry;
  List<Intersection>? intersections;
  Maneuver? maneuver;
  String? name;
  Distance? distance;
  TimeDuration? duration;
  RoadShield? roadShield;
  List<VoiceInstruction>? voiceInstructions;
  String? reference;

  RouteStep({
    this.bannerInstructions,
    this.drivingSide,
    this.geometry,
    this.intersections,
    this.maneuver,
    this.name,
    this.distance,
    this.duration,
    this.roadShield,
    this.voiceInstructions,
    this.reference,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      bannerInstructions: json['bannerInstructions'] != null
          ? (json['bannerInstructions'] as List)
          .map((e) => BannerInstructions.fromJson(
          (e as Map<dynamic, dynamic>).cast<String, dynamic>()))
          .toList()
          : null,
      drivingSide: json['driving_side'] as String?,
      geometry: json['geometry'] as String?,
      intersections: json['intersections'] != null
          ? (json['intersections'] as List)
          .map((intersection) => Intersection.fromJson(
          (intersection as Map<dynamic, dynamic>).cast<String, dynamic>()))
          .toList()
          : null,
      maneuver: json['maneuver'] != null
          ? Maneuver.fromJson(
          (json['maneuver'] as Map<dynamic, dynamic>).cast<String, dynamic>())
          : null,
      name: json['name'] as String?,
      distance: json['distance'] != null
          ? Distance.fromJson(
          (json['distance'] as Map<dynamic, dynamic>).cast<String, dynamic>())
          : null,
      duration: json['duration'] != null
          ? TimeDuration.fromJson(
          (json['duration'] as Map<dynamic, dynamic>).cast<String, dynamic>())
          : null,
      roadShield: json['road_shield_type'] != null
          ? RoadShield.fromJson(
          (json['road_shield_type'] as Map<dynamic, dynamic>).cast<String, dynamic>())
          : null,
      reference: json['reference'] as String?,
      voiceInstructions: json['voiceInstructions'] != null
          ? (json['voiceInstructions'] as List)
          .map((vi) => VoiceInstruction.fromJson(
          (vi as Map<dynamic, dynamic>).cast<String, dynamic>()))
          .toList()
          : null,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'bannerInstructions':
          bannerInstructions?.map((vi) => vi.toJson()).toList(),
      'driving_side': drivingSide,
      'geometry': geometry,
      'intersections':
          intersections?.map((intersection) => intersection.toJson()).toList(),
      'maneuver': maneuver?.toJson(),
      'name': name,
      'distance': distance?.toJson(),
      'duration': duration?.toJson(),
      'road_shield_type': roadShield?.toJson(),
      'reference': reference,
      'voiceInstructions': voiceInstructions?.map((vi) => vi.toJson()).toList(),
    };
  }
}

class RoadShield {
  String? imageUrl;
  String? label;

  RoadShield({
    this.imageUrl,
    this.label,
  });

  factory RoadShield.fromJson(Map<String, dynamic> map) {
    return RoadShield(
      imageUrl: map['image_url'] as String?,
      label: map['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'label': label,
    };
  }
}
