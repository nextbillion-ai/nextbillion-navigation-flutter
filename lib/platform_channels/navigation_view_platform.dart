// ignore_for_file: unnecessary_getters_setters

part of nb_navigation_flutter;

typedef ProgressChangeCallback = void Function(NavigationProgress? progress);
typedef OnNavigationCancellingCallback = void Function();
typedef OnNavigationRunningCallback = void Function();
typedef OnArriveAtWaypointCallback = void Function(Waypoint? atWaypoint);
typedef OnRerouteFromLocationCallback = void Function(LatLng? rereouteFromLocation);
typedef OnRerouteAlongCallback = void Function(DirectionsRoute? route);
typedef OnRerouteFailureCallback = void Function(String? message);

abstract class NBNavigationViewPlatform {

  static NBNavigationViewPlatform Function() createInstance =
      () => MethodChannelNavigationView();

  OnNavigationCancellingCallback? _onNavigationCancellingCallback;
  OnNavigationRunningCallback? _onNavigationRunningCallback;
  OnArriveAtWaypointCallback? _arriveAtWaypointCallback;
  OnRerouteFromLocationCallback? _rerouteFromLocationCallback;
  OnRerouteAlongCallback? _rerouteAlongCallback;
  OnRerouteFailureCallback? _rerouteFailureCallback;

  Future<void> initPlatform(int id);
  Widget buildView(
      Map<String, dynamic> creationParams,
      OnPlatformViewCreatedCallback onPlatformViewCreated);

  void setOnNavigationCancellingCallback(OnNavigationCancellingCallback? callback);
  void setOnNavigationRunningCallback(OnNavigationRunningCallback? callback);
  void setOnArriveAtWaypointCallback(OnArriveAtWaypointCallback? callback);
  void setOnRerouteFromLocationCallback(OnRerouteFromLocationCallback? callback);
  void setOnRerouteAlongCallback(OnRerouteAlongCallback? callback);
  void setOnRerouteFailureCallback(OnRerouteFailureCallback? callback);
  Stream<NavigationProgress?>? get navProgressListener;
  Future<void> stopNavigation();
  void dispose();

}
