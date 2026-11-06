import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';
import 'package:nb_navigation_flutter_example/offline_download_manager.dart';

/// Exercises real platform registration and policy conversion without an API
/// key or downloading data. Device download/reroute acceptance uses the demo.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native route selection rejects malformed geometry safely',
      (tester) async {
    final channel = NBNavigationMethodChannelsFactory.nbNavigationChannel;
    for (final args in <Map<String, Object>>[
      {'clickPoint': <double>[], 'coordinates': <Object>[]},
      {
        'clickPoint': [38.5, -120.2],
        'coordinates': [
          [
            [38.5]
          ]
        ]
      },
      {
        'clickPoint': [double.nan, -120.2],
        'coordinates': <Object>[]
      },
    ]) {
      await expectLater(
          channel.invokeMethod<int>('route/findSelectedRouteIndex', args),
          throwsA(isA<PlatformException>()
              .having((e) => e.code, 'code', 'INVALID_ARGUMENT')));
    }
    expect(
        await channel.invokeMethod<int>('route/findSelectedRouteIndex', {
          'clickPoint': [38.5, -120.2],
          'coordinates': [
            [],
            [
              [38.5, -120.2]
            ],
            [
              [38.5, -120.2],
              [38.51, -120.21]
            ]
          ],
        }),
        2);
  });

  testWidgets(
      'offline native bridge validates account and owns its configuration',
      (tester) async {
    final offline = NBNavigation.offline;
    final original = await offline.getConfiguration();
    try {
      for (final mode in NavigationRouteMode.values) {
        await offline.configure(
            routeMode: mode,
            networkPolicy: OfflineDownloadNetworkPolicy.anyNetwork);
        final configuration = await offline.getConfiguration();
        expect(configuration.routeMode, mode);
        expect(configuration.networkPolicy,
            OfflineDownloadNetworkPolicy.anyNetwork);
      }
      await offline.configure(
          networkPolicy: OfflineDownloadNetworkPolicy.wifiOnly);
      expect((await offline.getConfiguration()).networkPolicy,
          OfflineDownloadNetworkPolicy.wifiOnly);
      expect(await offline.isMapDownloadSupported(), isFalse);
      await expectLater(
          offline.initialize(),
          throwsA(isA<PlatformException>()
              .having((error) => error.code, 'code', 'NOT_INITIALIZED')));
      await offline.configure(routeMode: NavigationRouteMode.offlineOnly);
      final response = await NBNavigation.fetchRoute(RouteRequestParams(
        origin: const LatLng(35.2271, -80.8431),
        destination: const LatLng(35.2300, -80.8400),
      )).timeout(const Duration(seconds: 10));
      expect(response.directionsRoutes, isEmpty);
      expect(response.errorDetails?['code'], isA<String>());
      await offline.endDownloadPage('expired-page');
      await expectLater(
          const MethodChannel('nb_navigation_flutter/offline')
              .invokeMethod<void>('unknownMethod'),
          throwsA(isA<MissingPluginException>()));
    } finally {
      await offline.configure(
          routeMode: original.routeMode, networkPolicy: original.networkPolicy);
    }
  });

  testWidgets('all offline data methods reject missing account without hanging',
      (tester) async {
    final offline = NBNavigation.offline;
    final guarded = <String, Future<void> Function()>{
      'syncRegions': () => offline.syncRegions(),
      'syncRegions.force': () => offline.syncRegions(force: true),
      'fetchRegions': () async {
        await offline.fetchRegions();
      },
      'listInstalledMapRegions': () async {
        await offline.listInstalledMapRegions();
      },
      'downloadRegion': () async {
        await offline.downloadRegion(42);
      },
      'pauseRegion': () async {
        await offline.pauseRegion(42);
      },
      'resumeRegion': () async {
        await offline.resumeRegion(42);
      },
      'cancelRegion': () async {
        await offline.cancelRegion(42);
      },
      'deleteRegion': () async {
        await offline.deleteRegion(42);
      },
      'getPreviewStatus': () async {
        await offline.getPreviewStatus();
      },
      'healthCheck': () async {
        await offline.healthCheck();
      },
      'getRegionBoundary.local': () async {
        await offline.getRegionBoundary(42, fetchIfMissing: false);
      },
      'getRegionBoundary.fetch': () async {
        await offline.getRegionBoundary(42);
      },
      'beginDownloadPage': () async {
        await offline.beginDownloadPage();
      },
      'refreshMapResources': offline.refreshMapResources,
    };
    for (final entry in guarded.entries) {
      await expectLater(
          entry.value().timeout(const Duration(seconds: 10)),
          throwsA(isA<PlatformException>()
              .having((error) => error.code, entry.key, 'NOT_INITIALIZED')));
      debugPrint('NB_DEVICE_CHECK ${entry.key}: missing-account guard passed');
    }
    final observer = offline.progress.listen((_) {});
    await Future<void>.delayed(const Duration(milliseconds: 100));
    await observer.cancel();
    await offline.endDownloadPage('stale-owner');
    await offline.shutdown().timeout(const Duration(seconds: 10));
    debugPrint(
        'NB_DEVICE_CHECK progress.subscribe/cancel, endDownloadPage, shutdown: completed');
  });

  testWidgets('platform-specific network policy retains its exact meaning',
      (tester) async {
    final offline = NBNavigation.offline;
    final original = await offline.getConfiguration();
    try {
      for (final policy in OfflineDownloadNetworkPolicy.values) {
        if (Platform.isIOS &&
            policy == OfflineDownloadNetworkPolicy.unmetered) {
          await expectLater(
              offline.configure(networkPolicy: policy),
              throwsA(isA<PlatformException>().having(
                  (e) => e.code, 'code', 'UNSUPPORTED_NETWORK_POLICY')));
        } else {
          await offline.configure(
              routeMode: NavigationRouteMode.smart, networkPolicy: policy);
          expect((await offline.getConfiguration()).networkPolicy, policy);
        }
      }
    } finally {
      await offline.configure(
          routeMode: original.routeMode, networkPolicy: original.networkPolicy);
    }
  });

  testWidgets(
      'download manager and diagnostics render safely without an account',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: OfflineDownloadManager()));
    await tester.pumpAndSettle();
    expect(find.text(OfflineDownloadManager.title), findsOneWidget);
    expect(find.textContaining('Initialization failed'), findsWidgets);
    await tester.ensureVisible(find.text('Diagnostics'));
    await tester.tap(find.text('Diagnostics'));
    await tester.pumpAndSettle();
    expect(find.text('Offline API and Runtime Status'), findsOneWidget);
    final read = find.widgetWithText(OutlinedButton, 'Read Configuration');
    await tester.ensureVisible(read);
    await tester.tap(read);
    await tester.pumpAndSettle();
    expect(find.text('Current Configuration'), findsOneWidget);
    await tester.tap(find.text('Close').last);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
