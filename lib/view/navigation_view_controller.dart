part of '../nb_navigation_flutter.dart';

class NavigationViewController {
  final NBNavigationViewPlatform _navViewPlatform;
  Future<void>? _disposal;
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
    _navProgressSubscription =
        _navViewPlatform.navProgressListener?.listen((navProgress) {
      onProgressChange?.call(navProgress);
    });
    if (onNavigationCancelling != null) {
      _navViewPlatform
          .setOnNavigationCancellingCallback(onNavigationCancelling);
    }
    if (arriveAtWaypointCallback != null) {
      _navViewPlatform.setOnArriveAtWaypointCallback(arriveAtWaypointCallback);
    }
    if (onRerouteFromLocationCallback != null) {
      _navViewPlatform
          .setOnRerouteFromLocationCallback(onRerouteFromLocationCallback);
    }

    if (onRerouteAlongCallback != null) {
      _navViewPlatform.setOnRerouteAlongCallback(onRerouteAlongCallback);
    }

    if (onRerouteFailureCallback != null) {
      _navViewPlatform.setOnRerouteFailureCallback(onRerouteFailureCallback);
    }
  }

  Future<void> dispose() => _disposal ??= _dispose();

  Future<void> _dispose() async {
    _navViewPlatform.setOnNavigationRunningCallback(null);
    _navViewPlatform.setOnNavigationCancellingCallback(null);
    _navViewPlatform.setOnArriveAtWaypointCallback(null);
    _navViewPlatform.setOnRerouteFromLocationCallback(null);
    _navViewPlatform.setOnRerouteAlongCallback(null);
    _navViewPlatform.setOnRerouteFailureCallback(null);
    try {
      await _navProgressSubscription?.cancel();
    } finally {
      _navProgressSubscription = null;
      try {
        await _navViewPlatform.stopNavigation();
      } finally {
        _navViewPlatform.dispose();
      }
    }
  }
}
