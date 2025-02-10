import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';
import 'package:nb_navigation_flutter_example/constants.dart';
import 'package:nb_navigation_flutter_example/waypoint_dialog.dart';

class CustomViewOnNavigationView extends StatefulWidget {
  static const String title = "Launch Custom View On NavigationView";

  const CustomViewOnNavigationView({super.key});

  @override
  CustomViewOnNavigationViewState createState() =>
      CustomViewOnNavigationViewState();
}

class CustomViewOnNavigationViewState
    extends State<CustomViewOnNavigationView> {
  NextbillionMapController? controller;
  List<DirectionsRoute> routes = [];
  late NavNextBillionMap navNextBillionMap;
  Symbol? mapMarkerSymbol;

  NavigationViewController? navigationViewController;
  NavigationProgress? progress;
  Waypoint? waypoint;
  bool startNavigation = false;

  String locationTrackImage = "assets/location_on.png";
  UserLocation? currentLocation;
  List<LatLng> waypoints = [];

  // Control show the arrival dialog when the user arrives at a waypoint or destination
  bool showArrivalDialog = true;

  // Control show the speed view on the navigation view, It's only available when the navigation is started
  bool showSpeedView = true;

  // Control show the speed limit view on the navigation view
  bool showSpeedLimitView = true;

  // Speed limit values for each step
  Map<String, String> speedLimits = {};

  var primaryIndex = 0;

  void _onMapCreated(NextbillionMapController controller) {
    this.controller = controller;
  }

  _onStyleLoadedCallback() {
    if (controller != null) {
      NavNextBillionMap.create(controller!).then((value) {
        navNextBillionMap = value;
        loadAssetImage();
        Fluttertoast.showToast(
            msg: "Long press to select a destination to fetch a route");
        if (currentLocation != null) {
          controller?.animateCamera(
              CameraUpdate.newLatLngZoom(currentLocation!.position, 14),
              duration: const Duration(milliseconds: 400));
        }
      });
    }
  }

  _onNavigationViewReady(NavigationViewController controller) {
    navigationViewController = controller;
  }

  _onMapLongClick(Point<double> point, LatLng coordinates) {
    _fetchRoute(coordinates);
  }

  _onMapClick(Point<double> point, LatLng coordinates) {
    navNextBillionMap.addRouteSelectedListener(coordinates,
        (selectedRouteIndex) {
          if (routes.isNotEmpty) {
            primaryIndex = selectedRouteIndex;
            DirectionsRoute selectedRoute = routes[selectedRouteIndex];
            // You need to recalculate the speed limit for the new selected route
            _calculateSpeedLimit(selectedRoute);
          }
    });
  }

  _onUserLocationUpdate(UserLocation location) {
    currentLocation = location;
  }

  _onCameraTrackingChanged() {
    setState(() {
      locationTrackImage = 'assets/location_off.png';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 32,
          ),
          _buildSwitchRow(
              label: "Show speed view:",
              value: showSpeedView,
              onChanged: (value) {
                setState(() {
                  showSpeedView = value;
                });
              }),
          _buildSwitchRow(
              label: "Show speed limit view:",
              value: showSpeedLimitView,
              onChanged: (value) {
                setState(() {
                  showSpeedLimitView = value;
                });
              }),
          _buildSwitchRow(
              label: "Show arrival dialog:",
              value: showArrivalDialog,
              onChanged: (value) {
                setState(() {
                  showArrivalDialog = value;
                });
              }),
          Expanded(
            child: Stack(
              children: [
                _buildNBMapView(),
                _buildNBNavigationView(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
      {required String label,
      required bool value,
      required ValueChanged<bool> onChanged}) {
    return Row(
      children: [
        Padding(padding: const EdgeInsets.only(left: 16), child: Text(label)),
        const SizedBox(width: 8),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildNBNavigationView() {
    if (!startNavigation) {
      return Container();
    }
    var stacks = <Widget>[];
    stacks.add(Positioned(
      top: 0,
      bottom: 0,
      left: 0,
      right: 0,
      child: NBNavigationView(
        onNavigationViewReady: _onNavigationViewReady,
        navigationOptions: _buildNavigationViewConfig(),
        onProgressChange: (progress) {
          setState(() {
            this.progress = progress;
          });
        },
        onNavigationCancelling: () {
          setState(() {
            startNavigation = false;
            waypoints.clear();
            clearRouteResult();
          });
        },
        onArriveAtWaypoint: (waypoint) {
          setState(() {
            this.waypoint = waypoint;
          });
          if (showArrivalDialog) {
            _showArrivedDialog(waypoint, progress?.isFinalLeg ?? false);
          }
        },
        onRerouteFromLocation: (location) {},
        onRerouteAlongCallback: (route) {
          if (route != null) {
            // You need to recalculate the speed limit for the new route
            _calculateSpeedLimit(route);
          }
        },
      ),
    ));

    String speedLimit = speedLimits[
            "${progress?.currentLegIndex}${progress?.currentStepIndex}"] ??
        "";
    if (showSpeedLimitView && speedLimit.isNotEmpty) {
      stacks.add(Positioned(
        left: 12,
        bottom: 220,
        child: _buildSpeedLimitContainer(speedLimit),
      ));
    }
    return Stack(children: stacks);
  }

  Container _buildSpeedLimitContainer(String speedLimit) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text("Speed Limit\n$speedLimit",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16)),
    );
  }

  NavigationLauncherConfig _buildNavigationViewConfig() {
    NavigationLauncherConfig config =
        NavigationLauncherConfig(route: routes[primaryIndex], routes: routes);
    config.locationLayerRenderMode = LocationLayerRenderMode.gps;
    // config.shouldSimulateRoute = true;
    config.themeMode = NavigationThemeMode.system;
    config.useCustomNavigationStyle = false;
    config.showSpeedometer = showSpeedView;
    return config;
  }

  void _showArrivedDialog(Waypoint? waypoint, bool isArrivedDestination) {
    if (waypoint == null) {
      return;
    }

    String title =
        isArrivedDestination ? "Arrived Destination" : "Arrived Waypoint";
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return WaypointDialog(title: title, waypoint: waypoint);
      },
    );
  }

  Widget _buildNBMapView() {
    return Stack(
      children: [
        NBMap(
          onMapCreated: _onMapCreated,
          onStyleLoadedCallback: _onStyleLoadedCallback,
          initialCameraPosition: const CameraPosition(
            target: LatLng(0, 0),
            zoom: 14.0,
          ),
          trackCameraPosition: true,
          myLocationEnabled: true,
          myLocationTrackingMode: MyLocationTrackingMode.Tracking,
          onMapLongClick: _onMapLongClick,
          onUserLocationUpdated: _onUserLocationUpdate,
          onCameraTrackingDismissed: _onCameraTrackingChanged,
          onMapClick: _onMapClick,
          styleString: NbNavigationStyles.nbMapDefaultLightStyle,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                    child: Image(
                      image: AssetImage(locationTrackImage),
                      width: 28,
                      height: 28,
                    ),
                    onTap: () {
                      controller?.updateMyLocationTrackingMode(
                          MyLocationTrackingMode.Tracking);
                      setState(() {
                        locationTrackImage = 'assets/location_on.png';
                      });
                    }),
              ),
              const Padding(padding: EdgeInsets.only(top: 35)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              routes.isEmpty ? Colors.grey : Colors.blueAccent),
                          enableFeedback: routes.isNotEmpty),
                      onPressed: () {
                        clearRouteResult();
                        waypoints.clear();
                      },
                      child: const Text("Clear Routes")),
                  const Padding(padding: EdgeInsets.only(left: 8)),
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              routes.isEmpty ? Colors.grey : Colors.blueAccent),
                          enableFeedback: routes.isNotEmpty),
                      onPressed: routes.isEmpty
                          ? null
                          : () {
                              setState(() {
                                startNavigation = true;
                              });
                            },
                      child: const Text("Start Navigation")),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 48)),
              // Padding(
              //   padding: const EdgeInsets.only(top: 8.0),
              //   child: Text("route response: ${routeResult}"),
              // ),
            ],
          ),
        )
      ],
    );
  }

  void _fetchRoute(LatLng destination) async {
    if (currentLocation == null) {
      return;
    }
    LatLng origin = currentLocation!.position;
    waypoints.add(destination);
    RouteRequestParams requestParams = RouteRequestParams(
      origin: origin,
      destination: waypoints.last,
      // overview: ValidOverview.simplified,
      // avoid: [SupportedAvoid.toll, SupportedAvoid.ferry],
      // option: SupportedOption.flexible,
      // truckSize: [200, 200, 600],
      // truckWeight: 100,
      unit: SupportedUnits.imperial,
      alternatives: true,
      mode: ValidModes.car,
    );

    if (waypoints.length > 1) {
      requestParams.waypoints = waypoints.sublist(0, waypoints.length - 1);
    }

    DirectionsRouteResponse routeResponse =
        await NBNavigation.fetchRoute(requestParams);
    if (routeResponse.directionsRoutes.isNotEmpty) {
      clearRouteResult();
      setState(() {
        routes = routeResponse.directionsRoutes;
      });
      drawRoutes(routes);
      fitCameraToBounds(routes);
      _calculateSpeedLimit(routes.first);
    } else if (routeResponse.message != null) {
      if (kDebugMode) {
        print(
            "====error====${routeResponse.message}===${routeResponse.errorCode}");
      }
    }
  }

  /// Calculate speed limit for each step in the route
  /// This is just a dummy implementation
  /// You need to implement your own logic to get the speed limit
  Future<void> _calculateSpeedLimit(DirectionsRoute route) async {
    speedLimits.clear();
    for (int i = 0; i < route.legs.length; i++) {
      var leg = route.legs[i];
      for (int j = 0; j < leg.steps!.length; j++) {
        String key = "$i$j";
        // todo replace with your own logic to get the speed limit
        speedLimits[key] = "60 km/h";
      }
    }
  }

  Future<void> drawRoutes(List<DirectionsRoute> routes) async {
    navNextBillionMap.drawRoute(routes);
  }

  void fitCameraToBounds(List<DirectionsRoute> routes) {
    List<LatLng> multiPoints = [];
    for (var route in routes) {
      var routePoints =
          decode(route.geometry ?? '', _getDecodePrecision(route.routeOptions));
      multiPoints.addAll(routePoints);
    }
    if (multiPoints.isNotEmpty) {
      var latLngBounds = LatLngBounds.fromMultiLatLng(multiPoints);
      controller?.animateCamera(CameraUpdate.newLatLngBounds(latLngBounds,
          top: 50, left: 50, right: 50, bottom: 50));
    }
  }

  int _getDecodePrecision(RouteRequestParams? routeOptions) {
    return routeOptions?.geometry == SupportedGeometry.polyline
        ? precision
        : precision6;
  }

  void clearRouteResult() async {
    primaryIndex = 0;
    navNextBillionMap.clearRoute();
    controller?.clearSymbols();
    setState(() {
      routes.clear();
    });
  }

  Future<void> loadAssetImage() async {
    final ByteData bytes = await rootBundle.load("assets/map_marker_light.png");
    final Uint8List list = bytes.buffer.asUint8List();
    await controller?.addImage("ic_marker_destination", list);
  }

  Future<void> addImageFromAsset(LatLng coordinates) async {
    controller?.clearSymbols();
    var symbolOptions = SymbolOptions(
      geometry: coordinates,
      iconImage: "ic_marker_destination",
    );
    await controller?.addSymbol(symbolOptions);
    controller?.symbolManager?.setTextAllowOverlap(false);
  }
}
