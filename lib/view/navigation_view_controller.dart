part of nb_navigation_flutter;

class NavigationViewController {
  final NBNavigationViewPlatform _navViewPlatform;
  late StreamSubscription<NavigationProgress?>? _navProgressSubscription;
  late ProgressChangeCallback? onProgressChange;
  late OnNavigationCancellingCallback? onNavigationCancelling;
  late OnArriveAtWaypointCallback? arriveAtWaypointCallback;
  late OnRerouteFromLocationCallback? onRerouteFromLocationCallback;
  late OnRerouteAlongCallback? onRerouteAlongCallback;
  late OnRerouteFailureCallback? onRerouteFailureCallback;

  NavigationViewController({
    required NBNavigationViewPlatform navViewPlatform,
    this.onProgressChange,
    this.onNavigationCancelling,
    this.arriveAtWaypointCallback,
    this.onRerouteFromLocationCallback,
    this.onRerouteAlongCallback,
    this.onRerouteFailureCallback,
  }) : _navViewPlatform = navViewPlatform {
    _navProgressSubscription = _navViewPlatform.navProgressListener?.listen((navProgress) {
      if (onProgressChange != null) {
        onProgressChange!(navProgress);
      }
    });
    if (onNavigationCancelling != null) {
      _navViewPlatform.setOnNavigationCancellingCallback(onNavigationCancelling);
    }
    if (arriveAtWaypointCallback != null) {
      _navViewPlatform.setOnArriveAtWaypointCallback(arriveAtWaypointCallback);
    }
    if (onRerouteFromLocationCallback != null) {
      _navViewPlatform.setOnRerouteFromLocationCallback(onRerouteFromLocationCallback);
    }

    if (onRerouteAlongCallback != null) {
      _navViewPlatform.setOnRerouteAlongCallback(onRerouteAlongCallback);
    }

    if (onRerouteFailureCallback != null) {
      _navViewPlatform.setOnRerouteFailureCallback(onRerouteFailureCallback);
    }
  }

  void dispose() {
    _navProgressSubscription?.cancel();
    _navViewPlatform.stopNavigation();
    _navViewPlatform.dispose();
  }
}
