import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_navigation_flutter_example/custom_navigation_style.dart';
import 'package:nb_navigation_flutter_example/draw_route_line.dart';
import 'package:nb_navigation_flutter_example/launch_embedded_navigation_view.dart';
import 'package:nb_navigation_flutter_example/launch_navigation.dart';
import 'package:nb_navigation_flutter_example/map_view_style.dart';
import 'package:nb_navigation_flutter_example/navigation_theme_mode.dart';
import 'package:nb_navigation_flutter_example/route_line_style.dart';
import 'package:nb_navigation_flutter_example/track_current_location.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

import 'custom_view_on_navigation_view.dart';
import 'draw_route_line_with_raw_json.dart';
import 'embedded_navigation_view_integration.dart';
import 'full_navigation_example.dart';
import 'launch_preview_screen.dart';

final Map<String, Widget> _allPages = <String, Widget>{
  FullNavigationExample.title: const FullNavigationExample(),
  LaunchEmbeddedNavigationView.title: const LaunchEmbeddedNavigationView(),
  CustomViewOnNavigationView.title: const CustomViewOnNavigationView(),
  LaunchNavigation.title: const LaunchNavigation(),
  DrawRouteLine.title: const DrawRouteLine(),
  DrawRouteLineWithRawJson.title: const DrawRouteLineWithRawJson(),
  TrackCurrentLocation.title: const TrackCurrentLocation(),
  RouteLineStyle.title: const RouteLineStyle(),
  CustomNavigationStyle.title: const CustomNavigationStyle(),
  MapViewStyle.title: const MapViewStyle(),
  NavigationTheme.title: const NavigationTheme(),
  EmbeddedNavigationViewIntegration.title:
      const EmbeddedNavigationViewIntegration(),
  LaunchPreviewScreen.title: const LaunchPreviewScreen(),
};

class NavigationDemo extends StatefulWidget {
  static const String accessKey = String.fromEnvironment("ACCESS_KEY");

  const NavigationDemo({super.key});

  @override
  State<NavigationDemo> createState() => _NavigationDemoState();
}

class _NavigationDemoState extends State<NavigationDemo> {
  static const MethodChannel _permissionChannel = MethodChannel(
    'nb_navigation_flutter_example/permissions',
  );

  @override
  void initState() {
    super.initState();
    // NBNavigation.initNextBillion(NavigationDemo.accessKey);

    NBNavigation.initNextBillionWithTileServer(accessKey: NavigationDemo.accessKey, server: WellKnownTileServer.nbTomtom);

    // Set user ID If needed
    NBNavigation.setUserId("123344").then((value) {});

    // Check user ID If needed
    NBNavigation.getUserId().then((value) {});

    // Get NB ID If needed
    NBNavigation.getNBId().then((value) {});

    _requestLocationPermission(showDeniedMessage: false);
  }

  Future<bool> _requestLocationPermission({
    required bool showDeniedMessage,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return true;
    }

    try {
      final bool granted =
          await _permissionChannel.invokeMethod<bool>('requestLocationPermission') ??
              false;
      if (!granted && showDeniedMessage && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission is required for navigation.'),
          ),
        );
      }
      return granted;
    } on PlatformException {
      if (showDeniedMessage && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to request location permission.'),
          ),
        );
      }
      return false;
    }
  }

  Future<void> _pushPage(BuildContext context, Widget page) async {
    if (!mounted) {
      return;
    }

    final bool hasPermission = await _requestLocationPermission(
      showDeniedMessage: true,
    );
    if (!hasPermission || !mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Builder(
            builder: (newContext) => page,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NBNavigation examples')),
      body: NavigationDemo.accessKey.isEmpty
          ? buildAccessTokenWarning()
          : ListView.separated(
              itemCount: _allPages.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(height: 1),
              itemBuilder: (_, int index) => ListTile(
                  title: Text(_allPages.keys.toList()[index]),
                  onTap: () {
                    _pushPage(context, _allPages.values.toList()[index]);
                  }),
            ),
    );
  }

  Widget buildAccessTokenWarning() {
    return Container(
      color: Colors.red[900],
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            "Using MapView requires calling Nextbillion.initNextbillion(String accessKey) "
                "before inflating or creating NBMap Widget. ",
          ]
              .map((text) => Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: NavigationDemo()));
}
