part of nb_navigation_flutter;

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
      bearingAfter: map['bearing_after']?.toDouble(),
      bearingBefore: map['bearing_before']?.toDouble(),
      coordinate: Coordinate.fromJson(map['coordinate'] ?? {}),
      instruction: map['instruction'],
      modifier: map['modifier'],
      type: map['maneuver_type'],
      bearing: map['bearing'],
      muted: map['muted'],
      voiceInstructions: List<VoiceInstruction>.from(map['voice_instruction']
              ?.map((vi) => VoiceInstruction.fromJson(vi)) ??
          []),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> maps = {
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
    return Coordinate(
      latitude: map['latitude'],
      longitude: map['longitude'],
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
      instruction: map['instruction'],
      ssmlAnnouncement: map['ssmlAnnouncement'],
      distanceAlongGeometry: map['distance_along_geometry']?.toDouble(),
      unit: map['unit'],
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
