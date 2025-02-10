part of nb_navigation_flutter;

class DirectionsRouteResponse {
  String? message;
  int? errorCode;
  List<DirectionsRoute> directionsRoutes;

  DirectionsRouteResponse(
      {this.message, this.errorCode, this.directionsRoutes = const []});
}
