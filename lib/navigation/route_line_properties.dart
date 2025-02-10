part of nb_navigation_flutter;

class RouteLineProperties {
  /// The color of the shield icon for the route.
  final Color routeShieldColor;

  /// The color of the shield icon for alternative routes.
  final Color alternativeRouteShieldColor;

  /// The scale factor for the route line.
  final double routeScale;

  /// The scale factor for alternative route lines.
  final double alternativeRouteScale;

  /// The default color of the route line.
  final Color routeDefaultColor;

  /// The default color of alternative route lines.
  final Color alternativeRouteDefaultColor;

  /// The asset image name of the route origin marker.
  final String originMarkerName;

  /// The asset image name of the route destination marker.
  final String destinationMarkerName;

  /// The background color of the primary route's duration symbol.
  final Color durationSymbolPrimaryBackgroundColor;

  /// The background color of the alternative route's duration symbol.
  final Color durationSymbolAlternativeBackgroundColor;

  /// The text style for the primary route's duration symbol.
  final TextStyle durationSymbolPrimaryTextStyle;

  /// The text style for alternative route's duration symbols.
  final TextStyle durationSymbolAlternativeTextStyle;

  /// The color of the route line for moderate traffic.
  final Color routeModerateColor;

  /// The color of the route line for heavy traffic.
  final Color routeHeavyColor;

  /// The color of the route line for severe traffic.
  final Color routeSevereColor;

  /// The color of the alternative route line for moderate traffic.
  final Color alternativeRouteModerateColor;

  /// The color of the alternative route line for heavy traffic.
  final Color alternativeRouteHeavyColor;

  /// The color of the alternative route line for severe traffic.
  final Color alternativeRouteSevereColor;

  const RouteLineProperties({
    this.routeShieldColor = const Color(0xFF7588E9),
    this.alternativeRouteShieldColor = const Color(0xFF52779D),
    this.routeScale = 0.7,
    this.alternativeRouteScale = 0.7,
    this.routeDefaultColor = const Color(0xFF7588E9),
    this.alternativeRouteDefaultColor = const Color(0xFF828BBC),
    this.routeModerateColor = const Color(0xFFF3A64F),
    this.routeHeavyColor = const Color(0xFFEF1B1B),
    this.routeSevereColor = const Color(0xFF8F2447),
    this.alternativeRouteModerateColor = const Color(0xFFBFA087),
    this.alternativeRouteHeavyColor = const Color(0xFFB58282),
    this.alternativeRouteSevereColor = const Color(0xFF924148),
    this.originMarkerName =
        "packages/nb_navigation_flutter/assets/ic_route_origin.png",
    this.destinationMarkerName =
        "packages/nb_navigation_flutter/assets/ic_route_destination.png",
    this.durationSymbolPrimaryBackgroundColor = const Color(0xFF7588E9),
    this.durationSymbolAlternativeBackgroundColor = Colors.white,
    this.durationSymbolPrimaryTextStyle = const TextStyle(
      color: Colors.white,
      fontSize: 11,
    ),
    this.durationSymbolAlternativeTextStyle = const TextStyle(
      color: Colors.black,
      fontSize: 11,
    ),
  });
}
