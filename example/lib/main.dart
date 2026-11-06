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
import 'offline_navigation.dart';
import 'offline_download_manager.dart';
import 'offline_diagnostics.dart';

final Map<String, Widget> _allPages = <String, Widget>{
  OfflineDownloadManager.title: const OfflineDownloadManager(),
  OfflineNavigationExample.title: const OfflineNavigationExample(),
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
  late Future<void> _sdkReady;
  final _keyInput = TextEditingController();
  bool _hasKey = NavigationDemo.accessKey.isNotEmpty;
  bool _settingKey = false;
  String? _keyError;
  static const MethodChannel _permissionChannel = MethodChannel(
    'nb_navigation_flutter_example/permissions',
  );

  @override
  void initState() {
    super.initState();
    // NBNavigation.initNextBillion(NavigationDemo.accessKey);

    _sdkReady = _hasKey
        ? _initializeSdk(NavigationDemo.accessKey)
        : Future<void>.value();
    // Surface initialization errors when opening an example; keep startup safe.
    _sdkReady.catchError((Object _) {});
  }

  Future<void> _initializeSdk(String accessKey) async {
    await NBNavigation.initNextBillionWithTileServer(
        accessKey: accessKey, server: WellKnownTileServer.nbTomtom);
    await NBNavigation.setUserId('123344');
    await NBNavigation.getUserId();
    await NBNavigation.getNBId();
  }

  Future<void> _applyKey() async {
    final key = _keyInput.text.trim();
    if (key.isEmpty || _settingKey) return;
    setState(() {
      _settingKey = true;
      _keyError = null;
    });
    try {
      _sdkReady = _initializeSdk(key);
      await _sdkReady;
      if (!mounted) return;
      _keyInput.clear();
      setState(() {
        _hasKey = true;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _keyError =
              redactOfflineText(error.toString()).replaceAll(key, '[REDACTED]');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _settingKey = false;
        });
      }
    }
  }

  Future<bool> _requestLocationPermission({
    required bool showDeniedMessage,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return true;
    }

    try {
      final bool granted = await _permissionChannel
              .invokeMethod<bool>('requestLocationPermission') ??
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

    try {
      await _sdkReady;
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('SDK initialization failed: $error')));
      }
      return;
    }
    if (!mounted) return;
    final bool hasPermission = page is OfflineDownloadManager ||
        await _requestLocationPermission(
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
      body: !_hasKey
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
    return ListView(padding: const EdgeInsets.all(24), children: [
      const Text('Configure Test Key', style: TextStyle(fontSize: 22)),
      const SizedBox(height: 12),
      const Text(
          'Enter a valid NextBillion access key to open Offline Downloads. This example uses TomTom. The key stays in memory for this session and is never saved to configuration files or call history.'),
      const SizedBox(height: 16),
      TextField(
          controller: _keyInput,
          obscureText: true,
          enableSuggestions: false,
          autocorrect: false,
          decoration: const InputDecoration(labelText: 'ACCESS_KEY'),
          onSubmitted: (_) => _applyKey()),
      if (_keyError != null)
        Text(_keyError!,
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
      const SizedBox(height: 16),
      FilledButton(
          onPressed: _settingKey ? null : _applyKey,
          child: Text(
              _settingKey ? 'Initializing…' : 'Initialize and Open Examples')),
      const SizedBox(height: 12),
      const Text(
          'For automated device tests, use --dart-define-from-file with a local configuration file.'),
    ]);
  }

  @override
  void dispose() {
    _keyInput.dispose();
    super.dispose();
  }
}

void main() {
  runApp(const MaterialApp(home: NavigationDemo()));
}
