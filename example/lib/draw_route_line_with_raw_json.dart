import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';
import 'package:nb_navigation_flutter_example/route_json.dart';

class DrawRouteLineWithRawJson extends StatefulWidget {
  static const String title = "Draw Route Line With Raw Json";

  const DrawRouteLineWithRawJson({super.key});

  @override
  DrawRouteLineState createState() => DrawRouteLineState();
}

class DrawRouteLineState extends State<DrawRouteLineWithRawJson> {
  NextbillionMapController? controller;
  List<DirectionsRoute> routes = [];
  late NavNextBillionMap navNextBillionMap;

  LatLng origin = const LatLng(
    1.311273,
    103.877693,
  );

  bool enableAlternativeRoutes = true;
  bool enableRouteDurationSymbol = true;
  var primaryIndex = 0;

  void _onMapCreated(NextbillionMapController controller) {
    this.controller = controller;
  }

  void _onStyleLoaded() async {
    if (controller != null) {
      navNextBillionMap = await NavNextBillionMap.create(
        controller!,
        routeLineProperties: const RouteLineProperties(
          alternativeRouteDefaultColor: Colors.blueAccent,
          alternativeRouteShieldColor: Colors.lightBlue,
        ),
      );
    }
  }

  _onMapClick(Point<double> point, LatLng coordinates) {
    navNextBillionMap.addRouteSelectedListener(coordinates,
        (selectedRouteIndex) {
          if (routes.isNotEmpty) {
            primaryIndex = selectedRouteIndex;
          }
    });
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
        title: const Text(DrawRouteLineWithRawJson.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(maxHeight: screenHeight * 0.6),
              child: NBMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(origin.latitude, origin.longitude),
                  zoom: 13.0,
                ),
                onStyleLoadedCallback: _onStyleLoaded,
                onMapClick: _onMapClick,
              ),
            ),
            _buttonWidget(),
            _switchButton(),
          ],
        ),
      ),
    );
  }

  void _fetchRoute() async {
    try {
      DirectionsRoute route1 = DirectionsRoute.fromJson(routeJson);
      DirectionsRoute route2 = DirectionsRoute.fromJson(routeJson2);
      DirectionsRoute route3 = DirectionsRoute.fromJson(routeJson3);

      setState(() {
        routes = [route1, route2,route3];
      });
      drawRoutes(routes);
    } catch (e) {
      print("_fetchRoute : ${e.toString()}");
    }
  }

  void _startNavigation() {
    if (routes.isEmpty) return;
    NavigationLauncherConfig config =
        NavigationLauncherConfig(route: routes[primaryIndex], routes: routes);
    config.locationLayerRenderMode = LocationLayerRenderMode.gps;
    config.themeMode = NavigationThemeMode.system;
    config.useCustomNavigationStyle = false;
    NBNavigation.startNavigation(config);
  }

  Future<void> drawRoutes(List<DirectionsRoute> routes) async {
    primaryIndex = 0;
    navNextBillionMap.clearRoute();
    navNextBillionMap.drawIndependentRoutes(routes);
  }

  @override
  void dispose() {
    super.dispose();
  }

  _buttonWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 18.0),
      child: Row(
        children: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.blueAccent),
            ),
            onPressed: () {
              _fetchRoute();
            },
            child: const Text("Draw Route"),
          ),
          const Padding(padding: EdgeInsets.only(left: 8)),
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    routes.isEmpty ? Colors.grey : Colors.blueAccent),
                enableFeedback: routes.isNotEmpty),
            onPressed: () {
              _startNavigation();
            },
            child: const Text("Start Navigation"),
          ),
        ],
      ),
    );
  }

  _switchButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text("Display Alternative Route"),
              Switch(
                  value: enableAlternativeRoutes,
                  onChanged: (value) {
                    setState(() {
                      enableAlternativeRoutes = value;
                    });
                    navNextBillionMap.toggleAlternativeVisibilityWith(value);
                  })
            ],
          ),
          Row(
            children: [
              const Text("Display Route Duration Symbol"),
              Switch(
                  value: enableRouteDurationSymbol,
                  onChanged: (value) async {
                    setState(() {
                      enableRouteDurationSymbol = value;
                    });
                    navNextBillionMap.toggleDurationSymbolVisibilityWith(value);
                  })
            ],
          )
        ],
      ),
    );
  }
}
