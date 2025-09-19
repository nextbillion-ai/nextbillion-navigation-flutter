import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

class FullNavigationExample extends StatefulWidget {
  static const String title = "Full Navigation Experience Example";

  const FullNavigationExample({super.key});

  @override
  FullNavigationExampleState createState() => FullNavigationExampleState();
}

class FullNavigationExampleState extends State<FullNavigationExample> {
  NextbillionMapController? controller;
  List<DirectionsRoute> routes = [];
  NavNextBillionMap? navNextBillionMap;
  Symbol? mapMarkerSymbol;

  String locationTrackImage = "assets/location_on.png";
  UserLocation? currentLocation;
  List<LatLng> waypoints = [];
  var primaryIndex = 0;
  // Tile server state
  WellKnownTileServer currentTileServer = WellKnownTileServer.nbTomtom;
  bool isSwitchingTileServer = false;
  
  // Navigation mode state
  ValidModes currentMode = ValidModes.car;
  bool isSwitchingMode = false;
  
  // Map style state
  bool isLightStyle = true;
  bool isSwitchingStyle = false;

  void _onMapCreated(NextbillionMapController controller) {
    this.controller = controller;
  }

  _onStyleLoadedCallback() async {

    if (controller != null) {
      navNextBillionMap = await NavNextBillionMap.create(controller!);
      await loadAssetImage();
      await controller?.updateMyLocationTrackingMode(
          MyLocationTrackingMode.tracking);
      if (currentLocation != null) {
        controller?.animateCamera(
            CameraUpdate.newLatLngZoom(currentLocation!.position, 14),
            duration: const Duration(milliseconds: 400));
      }

      // NavNextBillionMap.create(controller!).then((value) {
      //   navNextBillionMap = value;
      //   loadAssetImage();
      //   Fluttertoast.showToast(
      //       msg: "Long press to select a destination to fetch a route");
      //   if (currentLocation != null) {
      //     controller?.animateCamera(
      //         CameraUpdate.newLatLngZoom(currentLocation!.position, 14),
      //         duration: const Duration(milliseconds: 400));
      //   }

      navNextBillionMap?.addRouteSelectedListener((selectedRouteIndex) {
        primaryIndex = selectedRouteIndex;
      });
      // });
    }
  }

  _onMapLongClick(Point<double> point, LatLng coordinates) {
    _fetchRoute(coordinates);
  }

  _onMapClick(Point<double> point, LatLng coordinates) {}

  _onUserLocationUpdate(UserLocation location) {
    currentLocation = location;
  }

  _onCameraTrackingChanged() {
    setState(() {
      locationTrackImage = 'assets/location_off.png';
    });
  }

  Future<void> _switchTileServer() async {
    if (isSwitchingTileServer) return;
    
    setState(() {
      isSwitchingTileServer = true;
    });

    try {
      // For now, we'll just toggle between nbTomtom and itself
      // since we don't know all available enum values
      WellKnownTileServer nextServer = currentTileServer == WellKnownTileServer.nbTomtom ? WellKnownTileServer.nbMapTiler: WellKnownTileServer.nbTomtom;

      // Switch tile server
      bool success = await NBNavigation.switchTileServer(server: nextServer);
      
      if (success) {
        setState(() {
          currentTileServer = nextServer;
        });
        
        // Clear current routes and reload map
        clearRouteResult();
        waypoints.clear();
        
        // Show success message
        Fluttertoast.showToast(
          msg: "Switched to ${_getTileServerName(nextServer)}",
          toastLength: Toast.LENGTH_SHORT,
        );
      } else {
        Fluttertoast.showToast(
          msg: "Failed to switch tile server",
          toastLength: Toast.LENGTH_SHORT,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error switching tile server: $e",
        toastLength: Toast.LENGTH_SHORT,
      );
    } finally {
      setState(() {
        isSwitchingTileServer = false;
      });
    }
  }

  String _getTileServerName(WellKnownTileServer server) {
    switch (server) {
      case WellKnownTileServer.nbTomtom:
        return "TomTom";
      case WellKnownTileServer.nbMapTiler:
        return "nbMapTiler";
    }
  }

  Future<void> _switchMode() async {
    if (isSwitchingMode) return;
    
    setState(() {
      isSwitchingMode = true;
    });

    try {
      // Cycle through available modes: car -> truck -> bike -> motorcycle -> car
      ValidModes nextMode;
      switch (currentMode) {
        case ValidModes.car:
          nextMode = ValidModes.truck;
          break;
        case ValidModes.truck:
          nextMode = ValidModes.bike;
          break;
        case ValidModes.bike:
          nextMode = ValidModes.motorcycle;
          break;
        case ValidModes.motorcycle:
          nextMode = ValidModes.car;
          break;
      }

      setState(() {
        currentMode = nextMode;
      });
      
      // Clear current routes since mode change affects routing
      clearRouteResult();
      waypoints.clear();
      
      // Show success message
      Fluttertoast.showToast(
        msg: "Switched to ${_getModeName(nextMode)} mode",
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error switching mode: $e",
        toastLength: Toast.LENGTH_SHORT,
      );
    } finally {
      setState(() {
        isSwitchingMode = false;
      });
    }
  }

  String _getModeName(ValidModes mode) {
    switch (mode) {
      case ValidModes.car:
        return "Car";
      case ValidModes.truck:
        return "Truck";
      case ValidModes.bike:
        return "Bike";
      case ValidModes.motorcycle:
        return "Motorcycle";
    }
  }

  IconData _getModeIcon(ValidModes mode) {
    switch (mode) {
      case ValidModes.car:
        return Icons.directions_car;
      case ValidModes.truck:
        return Icons.local_shipping;
      case ValidModes.bike:
        return Icons.directions_bike;
      case ValidModes.motorcycle:
        return Icons.motorcycle;
    }
  }

  void _switchMapStyle() {
    if (isSwitchingStyle) return;
    
    setState(() {
      isSwitchingStyle = true;
    });

    try {
      // Toggle between light and dark styles
      setState(() {
        isLightStyle = !isLightStyle;
      });
      
      // Show success message
      Fluttertoast.showToast(
        msg: "Switched to ${isLightStyle ? 'Bright' : 'Night'} style",
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error switching style: $e",
        toastLength: Toast.LENGTH_SHORT,
      );
    } finally {
      setState(() {
        isSwitchingStyle = false;
      });
    }
  }

  String _getStyleName(bool isLight) {
    return isLight ? "Bright" : "Night";
  }

  IconData _getStyleIcon(bool isLight) {
    return isLight ? Icons.light_mode : Icons.dark_mode;
  }



  @override
  Widget build(BuildContext context) {
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
          myLocationTrackingMode: MyLocationTrackingMode.tracking,
          onMapLongClick: _onMapLongClick,
          onUserLocationUpdated: _onUserLocationUpdate,
          onCameraTrackingDismissed: _onCameraTrackingChanged,
          onMapClick: _onMapClick,
          styleType: isLightStyle ? NBMapStyleType.bright : NBMapStyleType.night ,
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
                          MyLocationTrackingMode.tracking);
                      setState(() {
                        locationTrackImage = 'assets/location_on.png';
                      });
                    }),
              ),
              const Padding(padding: EdgeInsets.only(top: 35)),
              // Mode Switch Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        isSwitchingMode ? Colors.grey : Colors.green,
                      ),
                    ),
                    onPressed: isSwitchingMode ? null : _switchMode,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSwitchingMode)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        if (isSwitchingMode)
                          const SizedBox(width: 8),
                        if (!isSwitchingMode)
                          Icon(_getModeIcon(currentMode), size: 20),
                        if (!isSwitchingMode)
                          const SizedBox(width: 8),
                        Text(
                          isSwitchingMode 
                            ? "Switching..." 
                            : "Switch Mode",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 8)),
              // Current Mode Info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getModeIcon(currentMode), color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "Mode: ${_getModeName(currentMode)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 8)),
              // Map Style Switch Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        isSwitchingStyle ? Colors.grey : Colors.purple,
                      ),
                    ),
                    onPressed: isSwitchingStyle ? null : _switchMapStyle,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSwitchingStyle)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        if (isSwitchingStyle)
                          const SizedBox(width: 8),
                        if (!isSwitchingStyle)
                          Icon(_getStyleIcon(isLightStyle), size: 20),
                        if (!isSwitchingStyle)
                          const SizedBox(width: 8),
                        Text(
                          isSwitchingStyle 
                            ? "Switching..." 
                            : "Switch Style",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 8)),
              // Current Style Info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getStyleIcon(isLightStyle), color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      "Style: ${_getStyleName(isLightStyle)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 8)),
              // Tile Server Switch Button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        isSwitchingTileServer ? Colors.grey : Colors.orange,
                      ),
                    ),
                    onPressed: isSwitchingTileServer ? null : _switchTileServer,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSwitchingTileServer)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        if (isSwitchingTileServer)
                          const SizedBox(width: 8),
                        Text(
                          isSwitchingTileServer 
                            ? "Switching..." 
                            : "Switch Tile Server",
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(padding: EdgeInsets.only(top: 8)),
              // Current Tile Server Info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  "Current: ${_getTileServerName(currentTileServer)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.only(top: 8)),
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
                      onPressed: () {
                        _startNavigation();
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
      // avoidType: ["bbox: 17.453016,78.395004, 17.463005,78.413029|toll"],
      option: SupportedOption.flexible,
      // truckSize: [200, 200, 600],
      // truckWeight: 100,
      // unit: SupportedUnits.imperial,
      routeType: RouteType.shortest,
      altCount: 3,
      alternatives: true,
      mode: currentMode, // Use the current selected mode
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
      // addImageFromAsset(destination);
    } else if (routeResponse.message != null) {
      if (kDebugMode) {
        print(
            "====error====${routeResponse.message}===${routeResponse.errorCode}");
      }
    }
  }

  Future<void> drawRoutes(List<DirectionsRoute> routes) async {
    // navNextBillionMap.toggleDurationSymbolVisibilityWith(false);
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
    primaryIndex = 0;
    navNextBillionMap?.clearRoute();
    controller?.clearSymbols();
    setState(() {
      routes.clear();
    });
  }

  void _startNavigation() {
    if (routes.isEmpty) return;
    NavigationLauncherConfig config =
        NavigationLauncherConfig(route: routes[primaryIndex], routes: routes);
    config.locationLayerRenderMode = LocationLayerRenderMode.gps;
    config.shouldSimulateRoute = true;
    config.themeMode = NavigationThemeMode.system;
    config.useCustomNavigationStyle = false;
    config.themeMode = NavigationThemeMode.dark;
    // Please set the custom map style url if you only have the OSM map style access
    // config.navigationMapStyleUrl = NbNavigationStyles.nbMapCustomMapLightStyle;
    NBNavigation.startNavigation(config);
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

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    navNextBillionMap?.removeRouteSelectedListener();
    super.dispose();
  }

  @override
  void didUpdateWidget(FullNavigationExample oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
}
