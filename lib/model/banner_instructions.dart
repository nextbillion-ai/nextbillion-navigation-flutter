part of nb_navigation_flutter;

class BannerInstructions {
  double? distanceAlongGeometry;
  Primary? primary;
  Primary? secondary;
  Primary? sub;

  BannerInstructions({
    this.distanceAlongGeometry,
    this.primary,
    this.sub,
    this.secondary,
  });

  factory BannerInstructions.fromJson(Map<String, dynamic> map) {
    return BannerInstructions(
      distanceAlongGeometry: map['distanceAlongGeometry'],
      primary: map['primary'] != null
          ? Primary.fromJson(map['primary'] ?? {})
          : null,
      sub: map['sub'] != null ? Primary.fromJson(map['sub'] ?? {}) : null,
      secondary: map['secondary'] != null
          ? Primary.fromJson(map['secondary'] ?? {})
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distanceAlongGeometry': distanceAlongGeometry,
      'primary': primary?.toJson(),
      'sub': sub?.toJson(),
      'secondary': secondary?.toJson(),
    };
  }
}

class Primary {
  List<Component>? components;
  num? degrees;
  String? instruction;
  String? modifier;
  String? text;
  String? type;
  String? drivingSide;

  Primary({
    this.components,
    this.degrees,
    this.instruction,
    this.modifier,
    this.text,
    this.type,
    this.drivingSide,
  });

  factory Primary.fromJson(Map<String, dynamic> map) {
    return Primary(
      components: List<Component>.from(
          map['components']?.map((x) => Component.fromJson(x)) ?? []),
      degrees: map['degrees'],
      instruction: map['instruction'] ?? "",
      modifier: map['modifier'],
      text: map['text'] ?? "",
      type: map['type'] ?? "",
      drivingSide: map['driving_side'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'components': List<Map>.from(components?.map((x) => x.toJson()) ?? {}),
      'degrees': degrees,
      'instruction': instruction,
      'modifier': modifier,
      'text': text,
      'type': type,
      'driving_side': drivingSide,
    };
  }
}

class Component {
  String? countryCode;
  String? text;
  String? type;
  String? subType;
  String? abbreviation;
  num? abbreviationPriority;
  String? imageBaseUrl;
  String? imageUrl;
  List<String>? directions;
  bool? active;
  String? reference;

  Component({
    this.countryCode,
    this.text,
    this.type,
    this.subType,
    this.abbreviation,
    this.abbreviationPriority,
    this.imageBaseUrl,
    this.imageUrl,
    this.directions,
    this.active,
    this.reference,
  });

  factory Component.fromJson(Map<String, dynamic> map) {
    return Component(
      countryCode: map['countryCode'] ?? "",
      text: map['text'] ?? "",
      type: map['type'] ?? "",
      subType: map['subType'] ?? "",
      abbreviation: map['abbr'] ?? "",
      abbreviationPriority: map['abbr_priority'],
      imageBaseUrl: map['imageBaseURL'],
      imageUrl: map['imageURL'],
      directions: map['directions'],
      active: map['active'],
      reference: map['reference'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode,
      'text': text,
      'type': type,
      'subType': subType,
      'abbr': abbreviation,
      'abbr_priority': abbreviationPriority,
      'imageBaseURL': imageBaseUrl,
      'imageURL': imageUrl,
      'directions': directions,
      'reference': reference,
      'active': active,
    };
  }
}
