import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

class NavigationTheme extends StatefulWidget {
  static const String title = "Navigation Theme Mode";

  const NavigationTheme({super.key});

  @override
  NavigationThemeState createState() => NavigationThemeState();
}

class NavigationThemeState extends State<NavigationTheme> {
  NextbillionMapController? controller;
  List<DirectionsRoute> routes = [];
  late NavNextBillionMap navNextBillionMap;
  NavigationThemeMode themeMode = NavigationThemeMode.system;

  LatLng origin = const LatLng(1.312533169133601, 103.75986708439264);
  LatLng dest = const LatLng(1.310473772283314, 103.77982271935586);

  void _onMapCreated(NextbillionMapController controller) {
    this.controller = controller;
  }

  void _onStyleLoaded() async {
    if (controller != null) {
      navNextBillionMap = await NavNextBillionMap.create(controller!);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(NavigationTheme.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(maxHeight: screenHeight * 0.6),
              child: NBMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(origin.latitude, 103.76986708439264),
                  zoom: 13.0,
                ),
                onStyleLoadedCallback: _onStyleLoaded,
              ),
            ),
            _buttonWidget(),
          ],
        ),
      ),
    );
  }

  void _fetchRoute() async {
    RouteRequestParams requestParams = RouteRequestParams(
      origin: origin,
      destination: dest,
      // waypoints: [Coordinate(latitude: wayP2.latitude, longitude: wayP2.longitude)],
      // overview: ValidOverview.simplified,
      // avoid: [SupportedAvoid.toll, SupportedAvoid.ferry],
      // option: SupportedOption.flexible,
      // truckSize: [200, 200, 600],
      // truckWeight: 100,
      // unit: SupportedUnits.imperial,
      mode: ValidModes.car,
    );

    DirectionsRouteResponse routeResponse =
        await NBNavigation.fetchRoute(requestParams);
    if (routeResponse.directionsRoutes.isNotEmpty) {
      setState(() {
        routes = routeResponse.directionsRoutes;
      });
      drawRoutes(routes);
    } else if (routeResponse.message != null) {
      if (kDebugMode) {
        print(
            "====error====${routeResponse.message}===${routeResponse.errorCode}");
      }
    }
  }

  void _startNavigation() {
    if (routes.isEmpty) return;
    NavigationLauncherConfig config =
        NavigationLauncherConfig(route: routes.first, routes: routes);
    config.locationLayerRenderMode = LocationLayerRenderMode.gps;
    config.shouldSimulateRoute = true;
    config.themeMode = themeMode;
    config.useCustomNavigationStyle = false;
    NBNavigation.startNavigation(config);
  }

  Future<void> drawRoutes(List<DirectionsRoute> routes) async {
    navNextBillionMap.clearRoute();
    navNextBillionMap.drawRoute(routes);
  }

  @override
  void dispose() {
    super.dispose();
  }

  _buttonWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 18.0),
      child: Column(
        children: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.blueAccent),
            ),
            onPressed: () {
              _fetchRoute();
            },
            child: const Text("Fetch Route"),
          ),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    routes.isEmpty ? Colors.grey : Colors.blueAccent),
                enableFeedback: routes.isNotEmpty),
            onPressed: () {
              themeMode = NavigationThemeMode.light;
              _startNavigation();
            },
            child: const Text("Start Navigation with light mode"),
          ),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    routes.isEmpty ? Colors.grey : Colors.blueAccent),
                enableFeedback: routes.isNotEmpty),
            onPressed: () {
              themeMode = NavigationThemeMode.dark;
              _startNavigation();
            },
            child: const Text("Start Navigation with dark mode"),
          ),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    routes.isEmpty ? Colors.grey : Colors.blueAccent),
                enableFeedback: routes.isNotEmpty),
            onPressed: () {
              themeMode = NavigationThemeMode.system;
              _startNavigation();
            },
            child: const Text("Start Navigation with following system mode"),
          ),
        ],
      ),
    );
  }
}
