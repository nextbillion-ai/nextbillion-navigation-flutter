import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

class TrackCurrentLocation extends StatefulWidget {
  static const String title = "Track Current Location";

  const TrackCurrentLocation({super.key});

  @override
  TrackCurrentLocationState createState() => TrackCurrentLocationState();
}

class TrackCurrentLocationState extends State<TrackCurrentLocation> {
  NextbillionMapController? controller;

  String locationTrackImage = "assets/location_on.png";

  void _onMapCreated(NextbillionMapController controller) {
    this.controller = controller;
  }

  _onStyleLoadedCallback() async {
    Future.delayed(const Duration(milliseconds: 80), () {
      controller?.updateMyLocationTrackingMode(MyLocationTrackingMode.Tracking);
    });
  }

  _onUserLocationUpdate(UserLocation location) {
    if (kDebugMode) {
      print('${location.position.longitude}, ${location.position.latitude}');
    }
  }

  _onCameraTrackingChanged() {
    setState(() {
      locationTrackImage = 'assets/location_off.png';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(TrackCurrentLocation.title),
      ),
      body: Stack(
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
            onUserLocationUpdated: _onUserLocationUpdate,
            onCameraTrackingDismissed: _onCameraTrackingChanged,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 100),
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
            ],
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
