part of nb_navigation_flutter;

typedef OnNavigationViewReadyCallBack = void Function(NavigationViewController controller);

class NBNavigationView extends StatefulWidget {
  const NBNavigationView({
    super.key,
    required this.navigationOptions,
    this.onNavigationViewReady,
    this.onProgressChange,
    this.onNavigationCancelling,
    this.onArriveAtWaypoint,
    this.onRerouteFromLocation,
    this.onRerouteAlongCallback,
    this.onRerouteFailureCallback,
  });

  /// The configuration for the navigation view.
  final NavigationLauncherConfig? navigationOptions;

  /// Callback to be invoked when the navigation view is ready.
  final OnNavigationViewReadyCallBack? onNavigationViewReady;
  /// Callback to be invoked when progress change if the user has set the callback when initializing the navigation view.
  final ProgressChangeCallback? onProgressChange;
  /// Callback to be invoked when navigation is cancelled if the user has set the callback when initializing the navigation view.
  final OnNavigationCancellingCallback? onNavigationCancelling;
  /// Callback to be invoked when arrive at waypoint if the user has set the callback when initializing the navigation view.
  final OnArriveAtWaypointCallback? onArriveAtWaypoint;
  /// Callback to be invoked when reroute from location if the user has set the callback when initializing the navigation view.
  final OnRerouteFromLocationCallback? onRerouteFromLocation;
  /// Callback to be invoked when reroute along the route if the user has set the callback when initializing the navigation view.
  final OnRerouteAlongCallback? onRerouteAlongCallback;
  /// Callback to be invoked when reroute fails if the user has set the callback when initializing the navigation view.
  final OnRerouteFailureCallback? onRerouteFailureCallback;

  @override
  State<NBNavigationView> createState() => _NBNavigationViewState();
}

class _NBNavigationViewState extends State<NBNavigationView> {
  final Completer<NavigationViewController> _controller = Completer<NavigationViewController>();

  final NBNavigationViewPlatform _nbNavViewPlatform = NBNavigationViewPlatform.createInstance();

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> creationParams = <String, dynamic>{};
    if (widget.navigationOptions != null) {
      creationParams['launcherConfig'] = widget.navigationOptions!.toJson();
      if (Platform.isIOS) {
        creationParams["routeOptions"] = jsonEncode(widget.navigationOptions!.route.routeOptions);
      }
    }
    return _nbNavViewPlatform.buildView(creationParams, _onPlatformViewCreated);
  }

  void _onPlatformViewCreated(int id) async {
    await _nbNavViewPlatform.initPlatform(id);
    final NavigationViewController controller = NavigationViewController(
      navViewPlatform: _nbNavViewPlatform,
      onProgressChange: widget.onProgressChange,
      onNavigationCancelling: widget.onNavigationCancelling,
      arriveAtWaypointCallback: widget.onArriveAtWaypoint,
      onRerouteFromLocationCallback: widget.onRerouteFromLocation,
      onRerouteAlongCallback: widget.onRerouteAlongCallback,
      onRerouteFailureCallback: widget.onRerouteFailureCallback,
    );
    _controller.complete(controller);

    if (widget.onNavigationViewReady != null) {
      _nbNavViewPlatform.setOnNavigationRunningCallback(() {
        widget.onNavigationViewReady!(controller);
      });
    }
  }

  @override
  void dispose() async {
    super.dispose();
    if (_controller.isCompleted) {
      final controller = await _controller.future;
      controller.dispose();
    }
  }
}
