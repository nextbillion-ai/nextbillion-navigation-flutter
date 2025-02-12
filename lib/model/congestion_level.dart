part of '../nb_navigation_flutter.dart';

/// A `CongestionLevel` indicates the level of traffic congestion along a road segment
/// relative to the normal flow of traffic along that segment.
/// You can color-code a route line according to the congestion level along each segment of the route.
enum CongestionLevel {
  /// There is not enough data to determine the level of congestion along the road segment.
  unknown,

  /// The road segment has little or no congestion. Traffic is flowing smoothly.
  /// Low congestion levels are conventionally highlighted in green or not highlighted at all.
  low,

  /// The road segment has moderate, stop-and-go congestion. Traffic is flowing but speed is impeded.
  /// Moderate congestion levels are conventionally highlighted in yellow.
  moderate,

  /// The road segment has heavy, bumper-to-bumper congestion. Traffic is barely moving.
  /// Heavy congestion levels are conventionally highlighted in orange.
  heavy,

  /// The road segment has severe congestion. Traffic may be completely stopped.
  /// Severe congestion levels are conventionally highlighted in red.
  severe,
}

extension CongestionLevelExtension on CongestionLevel {
  /// Get a `CongestionLevel` from its string description.
  static CongestionLevel fromDescription(String description) {
    switch (description) {
      case "unknown":
        return CongestionLevel.unknown;
      case lowCongestionPropertyKey:
        return CongestionLevel.low;
      case moderateCongestionPropertyKey:
        return CongestionLevel.moderate;
      case heavyCongestionPropertyKey:
        return CongestionLevel.heavy;
      case severeCongestionPropertyKey:
        return CongestionLevel.severe;
      default:
        return CongestionLevel.unknown;
    }
  }

  static CongestionLevel fromValue(int value) {
    switch (value) {
      case 0:
        return CongestionLevel.unknown;
      case 1:
        return CongestionLevel.low;
      case 2:
        return CongestionLevel.moderate;
      case 3:
        return CongestionLevel.heavy;
      case 4:
        return CongestionLevel.severe;
      default:
        return CongestionLevel.unknown;
    }
  }

  /// Get the string description of the `CongestionLevel`.
  String get description {
    switch (this) {
      case CongestionLevel.unknown:
        return "unknown";
      case CongestionLevel.low:
        return lowCongestionPropertyKey;
      case CongestionLevel.moderate:
        return moderateCongestionPropertyKey;
      case CongestionLevel.heavy:
        return heavyCongestionPropertyKey;
      case CongestionLevel.severe:
        return severeCongestionPropertyKey;
    }
  }
}
