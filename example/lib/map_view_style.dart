import 'package:flutter/material.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

class MapViewStyle extends StatefulWidget {
  static const String title = "MapView Style";

  const MapViewStyle({super.key});

  @override
  MapViewStyleState createState() => MapViewStyleState();
}

class MapViewStyleState extends State<MapViewStyle> {
  NextbillionMapController? controller;
  var isLight = true;

  void _onMapCreated(NextbillionMapController controller) {
    this.controller = controller;
  }

  void _onStyleLoaded() {}

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(MapViewStyle.title),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(32.0),
        child: FloatingActionButton(
          child: const Icon(Icons.swap_horiz),
          onPressed: () => setState(
            () => isLight = !isLight,
          ),
        ),
      ),
      body: Stack(
        children: [
          NBMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(1.312533169133601, 103.76986708439264),
              zoom: 13.0,
            ),
            onStyleLoadedCallback: _onStyleLoaded,
            styleString: isLight ? NbMapStyles.LIGHT : NbMapStyles.DARK,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
