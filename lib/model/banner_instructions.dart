part of '../nb_navigation_flutter.dart';

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
      distanceAlongGeometry: (map['distanceAlongGeometry'] as num?)?.toDouble(),
      primary: map['primary'] is Map<String, dynamic>
          ? Primary.fromJson(map['primary'] as Map<String, dynamic>)
          : null,
      sub: map['sub'] is Map<String, dynamic>
          ? Primary.fromJson(map['sub'] as Map<String, dynamic>)
          : null,
      secondary: map['secondary'] is Map<String, dynamic>
          ? Primary.fromJson(map['secondary'] as Map<String, dynamic>)
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
      components: (map['components'] as List<dynamic>?)
          ?.map((x) => Component.fromJson(x as Map<String, dynamic>))
          .toList() ??
          [],
      degrees: map['degrees'] as num?,
      instruction: map['instruction'] as String? ?? "",
      modifier: map['modifier'] as String?,
      text: map['text'] as String? ?? "",
      type: map['type'] as String? ?? "",
      drivingSide: map['driving_side'] as String?,
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
      countryCode: map['countryCode'] as String? ?? "",
      text: map['text'] as String? ?? "",
      type: map['type'] as String? ?? "",
      subType: map['subType'] as String? ?? "",
      abbreviation: map['abbr'] as String? ?? "",
      abbreviationPriority: map['abbr_priority'] as int?,
      imageBaseUrl: map['imageBaseURL'] as String?,
      imageUrl: map['imageURL'] as String?,
      directions: map['directions'] as List<String>?,
      active: map['active'] as bool?,
      reference: map['reference'] as String?,
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
