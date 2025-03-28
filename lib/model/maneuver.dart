part of '../nb_navigation_flutter.dart';

class Maneuver {
  num? bearingAfter;
  num? bearingBefore;
  num? bearing;
  Coordinate? coordinate;
  String? instruction;
  String? modifier;
  String? type;
  bool? muted;
  List<VoiceInstruction>? voiceInstructions;

  Maneuver({
    this.bearingAfter,
    this.bearingBefore,
    this.coordinate,
    this.instruction,
    this.modifier,
    this.type,
    this.voiceInstructions,
    this.bearing,
    this.muted,
  });


  factory Maneuver.fromJson(Map<String, dynamic> map) {
    return Maneuver(
      bearingAfter: (map['bearing_after'] as num?)?.toDouble(),
      bearingBefore: (map['bearing_before'] as num?)?.toDouble(),
      bearing: (map['bearing'] as num?)?.toDouble(),
      coordinate: map['coordinate'] is Map<String, dynamic>
          ? Coordinate.fromJson(map['coordinate'] as Map<String, dynamic>)
          : null,
      instruction: map['instruction'] as String?,
      modifier: map['modifier'] as String?,
      type: map['maneuver_type'] as String?,
      muted: map['muted'] as bool?,
      voiceInstructions: (map['voice_instruction'] is List)
          ? (map['voice_instruction'] as List)
          .map((vi) => VoiceInstruction.fromJson(vi as Map<String, dynamic>))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> maps = {
      'bearing_after': bearingAfter,
      'bearing_before': bearingBefore,
      'coordinate': coordinate?.toJson(),
      'instruction': instruction,
      'maneuver_type': type,
      'bearing': bearing,
      'muted': muted,
      'voice_instruction': voiceInstructions?.map((vi) => vi.toJson()).toList(),
    };

    if (modifier != null && modifier!.isNotEmpty) {
      maps["modifier"] = modifier;
    }

    return maps;
  }
}

class Coordinate {
  double latitude;
  double longitude;

  Coordinate({required this.latitude, required this.longitude});

  factory Coordinate.fromJson(Map<String, dynamic> map) {
    final latitude = num.tryParse(map['latitude'].toString())?.toDouble();
    final longitude = num.tryParse(map['longitude'].toString())?.toDouble();
    if (latitude == null || longitude == null) {
      throw ArgumentError('Invalid latitude or longitude value');
    }
    return Coordinate(
      latitude: latitude,
      longitude: longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude};
  }
}

class VoiceInstruction {
  String? instruction;
  String? ssmlAnnouncement;
  double? distanceAlongGeometry;
  String? unit;

  VoiceInstruction({
    this.instruction,
    this.ssmlAnnouncement,
    this.distanceAlongGeometry,
    this.unit,
  });

  factory VoiceInstruction.fromJson(Map<String, dynamic> map) {
    return VoiceInstruction(
      instruction: map['instruction'] as String?,
      ssmlAnnouncement: map['ssmlAnnouncement'] as String?,
      distanceAlongGeometry: (map['distance_along_geometry'] as num?)?.toDouble(),
      unit: map['unit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instruction': instruction,
      'ssmlAnnouncement': ssmlAnnouncement,
      'distance_along_geometry': distanceAlongGeometry,
      'unit': unit,
    };
  }
}
