part of nb_navigation_flutter;

class Intersection {
  List<int>? bearings;
  List<String>? classes;
  List<dynamic>? entry;
  int? inCount;
  List<Lane>? lanes;
  int? outCount;
  Coordinate? location;

  Intersection({
    this.bearings,
    this.classes,
    this.entry,
    this.inCount,
    this.lanes,
    this.outCount,
    this.location,
  });

  factory Intersection.fromJson(Map<String, dynamic> map) {
    return Intersection(
      bearings: List<int>.from(map['bearings'] ?? []),
      classes: List<String>.from(map['classes'] ?? []),
      entry: List<dynamic>.from(map['entry'] ?? []),
      inCount: map['intersection_in'],
      lanes: List<Lane>.from(map['lanes']?.map(
            (lane) => Lane.fromJson(lane),
          ) ??
          []),
      outCount: map['intersection_out'] ?? 0,
      location: Coordinate.fromJson(map['location'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bearings': bearings,
      'classes': classes,
      'entry': entry,
      'intersection_in': inCount,
      'lanes': lanes?.map((lane) => lane.toJson()).toList(),
      'intersection_out': outCount,
      'location': location?.toJson(),
    };
  }
}

class Lane {
  List<String>? indications;
  bool? valid;
  bool? active;
  String? validIndication;

  Lane({
    this.indications,
    this.valid,
    this.active,
    this.validIndication,
  });

  factory Lane.fromJson(Map<String, dynamic> map) {
    return Lane(
      indications: List<String>.from(map['indications'] ?? []),
      valid: map['valid'],
      active: map['active'],
      validIndication: map['valid_indication'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'indications': indications,
      'valid': valid,
      'active': active,
      'valid_indication': validIndication,
    };
  }
}
