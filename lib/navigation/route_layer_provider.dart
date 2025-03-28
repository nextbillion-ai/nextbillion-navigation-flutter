part of '../nb_navigation_flutter.dart';

class MapRouteLayerProvider {
  LineLayerProperties initializeRouteShieldLayer(
      double routeScale,
      double alternativeRouteScale,
      Color routeShieldColor,
      Color alternativeRouteShieldColor) {
    return LineLayerProperties(
      lineCap: "round",
      lineJoin: "round",
      lineWidth: [
        Expressions.interpolate,
        ['exponential', 1.5],
        [Expressions.zoom],
        10,
        7,
        14,
        list(10.5, routeScale, alternativeRouteScale),
        16.6,
        list(15.5, routeScale, alternativeRouteScale),
        19,
        list(24, routeScale, alternativeRouteScale),
        22,
        list(29, routeScale, alternativeRouteScale),
      ],
      lineColor: [
        Expressions.match,
        [Expressions.get, primaryRoutePropertyKey],
        "true",
        routeShieldColor.toHexStringRGB(),
        alternativeRouteShieldColor.toHexStringRGB(),
      ],
    );
  }

  LineLayerProperties initializeRouteLayer(
      double routeScale,
      double alternativeRouteScale,
      Color routeDefaultColor,
      Color alternativeRouteDefaultColor,
      Color routeModerateColor,
      Color routeHeavyColor,
      Color routeSevereColor,
      Color alternativeRouteModerateColor,
      Color alternativeRouteHeavyColor,
      Color alternativeRouteSevereColor) {
    return LineLayerProperties(
      lineCap: "round",
      lineJoin: "round",
      lineWidth: [
        Expressions.interpolate,
        ['exponential', 1.5],
        [Expressions.zoom],
        4,
        list(3, routeScale, alternativeRouteScale),
        10,
        list(4, routeScale, alternativeRouteScale),
        13,
        list(6, routeScale, alternativeRouteScale),
        16,
        list(10, routeScale, alternativeRouteScale),
        19,
        list(14, routeScale, alternativeRouteScale),
        22,
        list(18, routeScale, alternativeRouteScale),
      ],
      lineColor: [
        Expressions.match,
        [Expressions.get, primaryRoutePropertyKey],
        "true",
        [
          Expressions.match,
          [Expressions.get, congestionPropertyKey],
          lowCongestionPropertyKey,
          routeDefaultColor.toHexStringRGB(),
          moderateCongestionPropertyKey,
          routeModerateColor.toHexStringRGB(),
          heavyCongestionPropertyKey,
          routeHeavyColor.toHexStringRGB(),
          severeCongestionPropertyKey,
          routeSevereColor.toHexStringRGB(),
          routeDefaultColor.toHexStringRGB(),
        ],
        [
          Expressions.match,
          [Expressions.get, congestionPropertyKey],
          lowCongestionPropertyKey,
          alternativeRouteDefaultColor.toHexStringRGB(),
          moderateCongestionPropertyKey,
          alternativeRouteModerateColor.toHexStringRGB(),
          heavyCongestionPropertyKey,
          alternativeRouteHeavyColor.toHexStringRGB(),
          severeCongestionPropertyKey,
          alternativeRouteSevereColor.toHexStringRGB(),
          alternativeRouteDefaultColor.toHexStringRGB(),
        ],
      ],
    );
  }

  SymbolLayerProperties initializeWayPointLayer(
      String originMarkerName, String destinationMarkerName) {
    final sizeAndroid = [0.8, 1.2, 1.6, 2.8];
    final sizeIos = [0.6, 0.8, 1.0, 2.2];
    final size = Platform.isAndroid ? sizeAndroid : sizeIos;
    return SymbolLayerProperties(
        iconImage: [
          Expressions.get,
          waypointPropertyKey
        ],
        iconSize: [
          Expressions.interpolate,
          ['exponential', 1.5],
          [Expressions.zoom],
          0,
          size[0],
          10,
          size[1],
          12,
          size[2],
          22,
          size[3],
        ],
        iconPitchAlignment: 'map',
        iconAllowOverlap: true,
        iconIgnorePlacement: true);
  }

  SymbolLayerProperties initializeDurationSymbolLayer() {
    final size = [0.8, 0.9, 0.9, 1.1];
    return SymbolLayerProperties(
        iconImage: [Expressions.get, routeDurationSymbolIconKey],
        iconSize: [
          Expressions.interpolate,
          ['exponential', 1.5],
          [Expressions.zoom],
          0,
          size[0],
          10,
          size[1],
          12,
          size[2],
          22,
          size[3],
        ],
        iconAllowOverlap: true,
        symbolPlacement: 'point',
        iconRotationAlignment: 'viewport',
        iconTranslateAnchor: 'viewport',
        iconAnchor: [
          Expressions.match,
          [Expressions.get, primaryRoutePropertyKey],
          "true",
          'top-left',
          'top-right'
        ]);
  }

  List<Object> list(
      double base, double routeScale, double alternativeRouteScale) {
    return [
      Expressions.multiply,
      base,
      [
        Expressions.match,
        [Expressions.get, primaryRoutePropertyKey],
        'true',
        routeScale,
        alternativeRouteScale
      ],
    ];
  }
}
