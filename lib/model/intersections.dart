part of '../nb_navigation_flutter.dart';

class Intersection {
  List<num>? bearings;
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
      bearings: (map['bearings'] as List?)?.cast<num>().toList() ?? [],
      classes: (map['classes'] as List?)?.whereType<String>().toList() ?? [],
      entry: (map['entry'] as List?)?.whereType<bool>().toList() ?? [],
      inCount: (map['intersection_in'] ?? map['in']) as int? ?? -1,
      lanes: (map['lanes'] as List?)
          ?.map((lane) => Lane.fromJson(lane as Map<String, dynamic>))
          .toList(),
      outCount: (map['intersection_out'] ?? map['out']) as int? ?? -1,
      location: map['location'] != null
          ? Coordinate.fromJson(map['location'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bearings': bearings,
      'classes': classes,
      'entry': entry,
      'intersection_in': _validIndex(inCount),
      'lanes': lanes?.map((lane) => lane.toJson()).toList(),
      'intersection_out': _validIndex(outCount),
      'location': location?.toJson(),
    };
  }

  int _validIndex(int? index) =>
      index != null && index >= 0 && index < (bearings?.length ?? 0)
          ? index
          : -1;
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
      indications: (map['indications'] as List?)
          ?.whereType<String>()
          .toList(), // Ensures only Strings are included
      valid: map['valid'] as bool?,
      active: map['active'] as bool?,
      validIndication: map['valid_indication'] as String?,
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
