import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';
import 'package:nb_navigation_flutter_example/waypoint_dialog.dart';
import 'segment_selector.dart';
import 'constants.dart';

class EmbeddedNavigationViewIntegration extends StatefulWidget {
  static const String title = "Embedded NavigationView Example";

  const EmbeddedNavigationViewIntegration({super.key});

  @override
  EmbeddedNavigationViewExampleState createState() =>
      EmbeddedNavigationViewExampleState();
}

class EmbeddedNavigationViewExampleState
    extends State<EmbeddedNavigationViewIntegration> {
  NextbillionMapController? controller;
  List<DirectionsRoute> routes = [];
  NavNextBillionMap? navNextBillionMap;
  Symbol? mapMarkerSymbol;

  NavigationViewController? navigationViewController;
  NavigationProgress? progress;
  bool startNavigation = false;

  String locationTrackImage = "assets/location_on.png";
  bool showArrivalDialog = true;
  int _selectedRouteIndex = 0;

  UserLocation? currentLocation;

  List<String> travelModes = [
    NBString.car,
    NBString.truck,
  ];

  int selectedTravelMode = 0;
  bool showAlternative = true;

  List<String> supportedUnits = [
    NBString.imperial,
    NBString.metric,
  ];

  int selectedUnit = 0;

  void _onMapCreated(NextbillionMapController controller) {
    this.controller = controller;
  }

  _onStyleLoadedCallback() {
    if (controller != null) {
      NavNextBillionMap.create(controller!).then((value) {
        navNextBillionMap = value;

        navNextBillionMap?.addRouteSelectedListener((selectedRouteIndex) {
          _selectedRouteIndex = selectedRouteIndex;
        });
      });
    }
  }

  _onNavigationViewReady(NavigationViewController controller) {
    navigationViewController = controller;
  }

  _onMapLongClick(Point<double> point, LatLng coordinates) {
    _fetchRoute(coordinates);
  }

  _onMapClick(Point<double> point, LatLng coordinates) {}

  _onCameraTrackingChanged() {
    setState(() {
      locationTrackImage = 'assets/location_off.png';
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stackTraceStack = [];
    if (startNavigation) {
      stackTraceStack.add(_buildNBNavigationView());
    } else {
      stackTraceStack.addAll(_buildMapViewWithConfigurationWidgets());
    }
    return Scaffold(
      body: Stack(
        children: stackTraceStack,
      ),
    );
  }

  Widget _buildNBNavigationView() {
    return NBNavigationView(
      key: const Key("NBNavigationView"),
      onNavigationViewReady: _onNavigationViewReady,
      navigationOptions: _buildNavigationViewConfig(),
      onProgressChange: (progress) {
        setState(() {
          this.progress = progress;
        });
        if (kDebugMode) {
          print("onProgressChange : ${progress?.location}");
        }
      },
      onNavigationCancelling: () {
        setState(() {
          startNavigation = false;
          clearRouteResult();
        });
        if (kDebugMode) {
          print("onNavigationCancelling ");
        }
      },
      onArriveAtWaypoint: (waypoint) {
        if (showArrivalDialog) {
          _showArrivedDialog(waypoint, progress?.isFinalLeg ?? false);
        }
        if (kDebugMode) {
          print("onArriveAtWaypoint : $waypoint");
        }
      },
      onRerouteFromLocation: (location) {
        if (kDebugMode) {
          print(" onRerouteFromLocation : $location");
        }
      },
      onRerouteAlongCallback: (DirectionsRoute? route) {
        if (kDebugMode) {
          print("onRerouteAlongCallback : ${route?.geometry}");
        }
      },
    );
  }

  List<Widget> _buildMapViewWithConfigurationWidgets() {
    List<Widget> widgets = [];
    widgets.add(_buildNBMapView());
    widgets.add(buildConfigurationWidgets());
    return widgets;
  }

  Widget buildConfigurationWidgets() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 44),
      color: Colors.white38,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegmentItem(
            NBString.travelMode,
            travelModes,
            selectedTravelMode,
            (index) {
              setState(() {
                selectedTravelMode = index;
              });
            },
          ),
          const SizedBox(height: 4),
          _buildSegmentItem(NBString.distanceUnit, supportedUnits, selectedUnit,
              (index) {
            setState(() {
              selectedUnit = index;
            });
          }),
          _buildSwitchItem(
            NBString.showAlternative,
            showAlternative,
            (value) {
              setState(() {
                showAlternative = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchItem(String title, bool value, Function(bool) onSwitch) {
    return Row(
      children: [
        Text(title),
        const Padding(padding: EdgeInsets.only(left: 8)),
        Switch(
          key: Key(title),
          value: value,
          onChanged: onSwitch,
        ),
      ],
    );
  }

  Widget _buildSegmentItem(String title, List<String> values, int selectIndex,
      Function(int) onSegmentSelected) {
    return Row(children: [
      Text(title),
      const Padding(padding: EdgeInsets.only(left: 8)),
      SegmentSelector(
        segments: values,
        defaultIndex: selectIndex,
        onSegmentSelected: onSegmentSelected,
      ),
    ]);
  }

  NavigationLauncherConfig _buildNavigationViewConfig() {
    NavigationLauncherConfig config = NavigationLauncherConfig(
        route: routes[_selectedRouteIndex], routes: routes);
    config.locationLayerRenderMode = LocationLayerRenderMode.gps;
    config.shouldSimulateRoute = false;
    config.themeMode = NavigationThemeMode.system;
    config.useCustomNavigationStyle = false;
    // Please set the custom map style url if you only have the OSM map style access
    config.navigationMapStyleUrl = NbNavigationStyles.nbMapCustomMapLightStyle;
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
          initialCameraPosition: CameraPosition(
            target: LatLng(0, 0),
            zoom: 14.0,
          ),
          trackCameraPosition: true,
          myLocationEnabled: true,
          onUserLocationUpdated: _onUserLocationUpdate,
          myLocationTrackingMode: MyLocationTrackingMode.Tracking,
          onMapLongClick: _onMapLongClick,
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
                      ),
                      onPressed: () {
                        clearRouteResult();
                      },
                      child: const Text(NBString.clearRoutes)),
                  const Padding(padding: EdgeInsets.only(left: 8)),
                  ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                            routes.isEmpty ? Colors.grey : Colors.blueAccent),
                      ),
                      onPressed: () {
                        setState(() {
                          startNavigation = true;
                        });
                      },
                      child: const Text(NBString.startNavigation)),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 48)),
            ],
          ),
        )
      ],
    );
  }

  _onUserLocationUpdate(UserLocation location) {
    currentLocation = location;
  }

  void _fetchRoute(LatLng destination) async {
    if (currentLocation == null) {
      return;
    }
    RouteRequestParams requestParams = RouteRequestParams(
      origin: currentLocation!.position,
      destination: destination,
      truckSize: [300, 250, 600],
      truckWeight: 8000,
      unit: SupportedUnits.fromValue(supportedUnits[selectedUnit]),
      alternatives: showAlternative,
      altCount: 3,
      mode: ValidModes.fromValue(travelModes[selectedTravelMode]),
    );

    DirectionsRouteResponse routeResponse =
        await NBNavigation.fetchRoute(requestParams);
    if (routeResponse.directionsRoutes.isNotEmpty) {
      clearRouteResult();
      setState(() {
        routes = routeResponse.directionsRoutes;
      });
      drawRoutes(routes);
      fitCameraToBounds(routes);
      // addImageFromAsset(destination);
    } else if (routeResponse.message != null) {
      if (kDebugMode) {
        print(
            "====error====${routeResponse.message}===${routeResponse.errorCode}");
      }
    }
  }

  Future<void> drawRoutes(List<DirectionsRoute> routes) async {
    navNextBillionMap?.drawRoute(routes);
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
    navNextBillionMap?.clearRoute();
    controller?.clearSymbols();
    setState(() {
      routes.clear();
    });
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

  @override
  void dispose() {
    navNextBillionMap?.removeRouteSelectedListener();
    super.dispose();
  }
}
