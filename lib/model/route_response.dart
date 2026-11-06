part of '../nb_navigation_flutter.dart';

class DirectionsRouteResponse {
  String? message;
  int? errorCode;
  List<DirectionsRoute> directionsRoutes;
  NavigationRouteSource? routeSource;
  Map<String, dynamic>? errorDetails;

  DirectionsRouteResponse(
      {this.message,
      this.errorCode,
      this.directionsRoutes = const [],
      this.routeSource,
      this.errorDetails});
}
