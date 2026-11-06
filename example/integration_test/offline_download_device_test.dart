import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';
import 'package:nb_navigation_flutter_example/offline_diagnostics.dart';
import 'package:nb_navigation_flutter_example/offline_download_manager.dart';

/// Real SDK/network/data acceptance. Only a region absent before the test may
/// be modified or deleted. Supply credentials through an ignored JSON file.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('offline download lifecycle on a physical device',
      (tester) async {
    const key = String.fromEnvironment('ACCESS_KEY');
    const country = String.fromEnvironment('OFFLINE_TEST_COUNTRY',
        defaultValue: 'United States');
    const requestedId = int.fromEnvironment('OFFLINE_TEST_REGION_ID');
    const maxBytes = int.fromEnvironment('OFFLINE_TEST_MAX_BYTES',
        defaultValue: 150 * 1024 * 1024);
    const minRoutingBytes = int.fromEnvironment(
        'OFFLINE_TEST_MIN_ROUTING_BYTES',
        defaultValue: 20 * 1024 * 1024);
    expect(key, isNotEmpty,
        reason:
            'Provide a valid ACCESS_KEY using --dart-define-from-file. This suite never substitutes a fake key.');
    final offline = NBNavigation.offline;
    final log = OfflineMethodLog(limit: 2000);
    final latest = <int, OfflineRegionProgress>{};
    StreamSubscription<List<OfflineRegionProgress>>? subscription;
    String? page;
    int? testRegion;
    bool touchedRegion = false;
    OfflineNavigationConfiguration? original;
    String stage = 'initialization';
    int snapshots = 0;
    Future<T> call<T>(String name, Future<T> Function() action,
            {Map<String, Object?> args = const {}}) =>
        log.run(
            name,
            () => action().timeout(
                name == 'downloadRegion' || name == 'resumeRegion'
                    ? const Duration(minutes: 20)
                    : name == 'syncRegions' ||
                            name == 'fetchRegions' ||
                            name == 'getRegionBoundary'
                        ? const Duration(minutes: 2)
                        : const Duration(seconds: 30)),
            arguments: args);
    Future<void> until(String description, bool Function() condition,
        {Duration timeout = const Duration(seconds: 40)}) async {
      final watch = Stopwatch()..start();
      while (!condition()) {
        if (watch.elapsed > timeout) fail('Timed out: $description');
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
    }

    Future<void> subscribe() async {
      await call('progress.listen', () async {
        subscription = offline.progress.listen((rows) {
          snapshots++;
          latest
            ..clear()
            ..addEntries(rows.map((row) => MapEntry(row.regionId, row)));
        });
      });
    }

    Future<void> unsubscribe() async {
      final current = subscription;
      subscription = null;
      if (current != null) await call('progress.cancel', current.cancel);
    }

    Future<OfflineRegionOperation?> settle(
        Future<OfflineRegionOperation> pending) async {
      try {
        return await pending.timeout(const Duration(seconds: 30));
      } on PlatformException {
        return null;
      }
    }

    bool active(int id) =>
        [latest[id]?.routing?.state, latest[id]?.mapTiles?.state].any((state) =>
            state == OfflineTaskState.running ||
            state == OfflineTaskState.queued);

    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: Center(
                child: Text('Offline download device test in progress')))));
    try {
      await NBNavigation.initNextBillionWithTileServer(
          accessKey: key, server: WellKnownTileServer.nbTomtom);
      original = await call('getConfiguration', offline.getConfiguration);
      expect(
          await call('isMapDownloadSupported', offline.isMapDownloadSupported),
          isTrue);
      for (final mode in NavigationRouteMode.values) {
        await call(
            'configure',
            () => offline.configure(
                routeMode: mode,
                networkPolicy: OfflineDownloadNetworkPolicy.anyNetwork),
            args: {'routeMode': mode.name, 'networkPolicy': 'anyNetwork'});
        expect(
            (await call('getConfiguration', offline.getConfiguration))
                .routeMode,
            mode);
      }
      for (final policy in OfflineDownloadNetworkPolicy.values) {
        if (Platform.isIOS &&
            policy == OfflineDownloadNetworkPolicy.unmetered) {
          await expectLater(
              offline.configure(networkPolicy: policy),
              throwsA(isA<PlatformException>().having(
                  (e) => e.code, 'code', 'UNSUPPORTED_NETWORK_POLICY')));
        } else {
          await call(
              'configure', () => offline.configure(networkPolicy: policy),
              args: {'networkPolicy': policy.name});
          expect(
              (await call('getConfiguration', offline.getConfiguration))
                  .networkPolicy,
              policy);
        }
      }
      await call(
          'configure',
          () => offline.configure(
              routeMode: NavigationRouteMode.offlineOnly,
              networkPolicy: OfflineDownloadNetworkPolicy.anyNetwork));
      await call('initialize', offline.initialize);
      await call('initialize', offline.initialize); // idempotence
      page = await call('beginDownloadPage', offline.beginDownloadPage);
      final stale = page!;
      page = await call('beginDownloadPage', offline.beginDownloadPage);
      await call('endDownloadPage', () => offline.endDownloadPage(stale),
          args: {'staleOwner': true});
      await subscribe();
      await call('syncRegions', () => offline.syncRegions());
      await call('syncRegions', () => offline.syncRegions(force: true),
          args: {'force': true});
      final catalog = await call(
          'fetchRegions', () => offline.fetchRegions(country: country),
          args: {'country': country});
      expect(catalog.routingError, isNull,
          reason: 'Routing catalog must load successfully');
      expect(catalog.mapError, isNull,
          reason: 'Map catalog must load successfully');
      final installedBefore = await call(
          'listInstalledMapRegions', offline.listInstalledMapRegions);
      final existingMaps = installedBefore.map((row) => row.regionId).toSet();
      await until('initial progress snapshot', () => snapshots > 0);
      final candidates = catalog.regions.where((row) {
        final size = (row.routingSizeBytes ?? 0) + (row.mapSizeBytes ?? 0);
        return row.hasRouting &&
            row.hasMapTiles &&
            !row.routingInstalled &&
            !row.routingPartial &&
            !existingMaps.contains(row.regionId) &&
            !active(row.regionId) &&
            (requestedId == 0 || requestedId == row.regionId) &&
            size > 0 &&
            size <= maxBytes;
      }).toList()
        ..sort((a, b) => ((a.routingSizeBytes ?? 0) + (a.mapSizeBytes ?? 0))
            .compareTo((b.routingSizeBytes ?? 0) + (b.mapSizeBytes ?? 0)));
      expect(candidates, isNotEmpty,
          reason:
              'Need a fresh region supporting both datasets within the byte limit; existing user data is never deleted.');
      // Small or previously cached regions can finish between a progress event
      // and a control request. Keep a real transfer window for strict controls.
      final region = candidates.firstWhere(
          (row) => (row.routingSizeBytes ?? 0) >= minRoutingBytes,
          orElse: () => candidates.first);
      final id = region.regionId;
      testRegion = id;
      debugPrint('NB_DEVICE_REGION ${offlineDebugJson(region)}');
      final boundary = await call(
          'getRegionBoundary', () => offline.getRegionBoundary(id),
          args: {'regionId': id, 'fetchIfMissing': true});
      expect(jsonDecode(boundary), isA<Map>());
      expect(
          jsonDecode(await call('getRegionBoundary',
              () => offline.getRegionBoundary(id, fetchIfMissing: false),
              args: {'regionId': id, 'fetchIfMissing': false})),
          isA<Map>());
      await call('healthCheck', offline.healthCheck);
      await call('getPreviewStatus', offline.getPreviewStatus);

      stage = 'pause/resume/cancel';
      touchedRegion = true;
      final first = call('downloadRegion', () => offline.downloadRegion(id),
          args: {'regionId': id, 'scenario': 'pause'});
      unawaited(first.then<void>((_) {}, onError: (Object _) {}));
      await until('routing download becomes active',
          () => latest[id]?.routing?.state == OfflineTaskState.running);
      final paused = await call('pauseRegion', () => offline.pauseRegion(id),
          args: {'regionId': id});
      expect(paused.routing.hasError, isFalse,
          reason: offlineDebugJson(paused));
      expect(paused.mapTiles.hasError, isFalse);
      await until(
          'a real subtask is paused',
          () =>
              latest[id]?.routing?.state == OfflineTaskState.paused ||
              latest[id]?.mapTiles?.state == OfflineTaskState.paused);
      await settle(first);
      final resumed = call('resumeRegion', () => offline.resumeRegion(id),
          args: {'regionId': id});
      unawaited(resumed.then<void>((_) {}, onError: (Object _) {}));
      await until('routing download resumes',
          () => latest[id]?.routing?.state == OfflineTaskState.running);
      final cancelled = await call(
          'cancelRegion', () => offline.cancelRegion(id),
          args: {'regionId': id});
      expect(cancelled.hasError, isFalse, reason: offlineDebugJson(cancelled));
      await until('cancel stops active tasks', () => !active(id));
      await settle(resumed);

      stage = 'complete download';
      final downloaded = await call(
              'downloadRegion', () => offline.downloadRegion(id),
              args: {'regionId': id, 'scenario': 'complete'})
          .timeout(const Duration(minutes: 20));
      expect(downloaded.hasError, isFalse,
          reason: offlineDebugJson(downloaded));
      await until('routing dataset installed',
          () => latest[id]?.routing?.state == OfflineTaskState.completed,
          timeout: const Duration(minutes: 2));
      final mapWatch = Stopwatch()..start();
      while (true) {
        final installed = await call(
            'listInstalledMapRegions', offline.listInstalledMapRegions);
        if (installed
            .any((row) => row.regionId == id && row.packagesComplete)) {
          break;
        }
        if (mapWatch.elapsed > const Duration(minutes: 20)) {
          fail('Map packages did not finish installation');
        }
        await Future<void>.delayed(const Duration(seconds: 3));
      }
      await call('refreshMapResources', offline.refreshMapResources);
      final preview = await call('getPreviewStatus', offline.getPreviewStatus);
      expect(preview.stylesReady, isTrue,
          reason:
              'Transferred packages alone do not establish offline display readiness');
      await call('healthCheck', offline.healthCheck);

      stage = 'shutdown and restore';
      await unsubscribe();
      await call('endDownloadPage', () => offline.endDownloadPage(page!));
      page = null;
      await call('shutdown', offline.shutdown);
      await expectLater(
          offline.healthCheck(),
          throwsA(isA<PlatformException>()
              .having((e) => e.code, 'code', 'ENGINE_NOT_INITIALIZED')));
      await call('initialize', offline.initialize);
      page = await call('beginDownloadPage', offline.beginDownloadPage);
      await subscribe();
      expect(
          (await call(
                  'listInstalledMapRegions', offline.listInstalledMapRegions))
              .any((row) => row.regionId == id && row.packagesComplete),
          isTrue);
      await until('routing installed state restores from local catalog',
          () => latest[id]?.routing?.state == OfflineTaskState.completed);

      stage = 'delete test region';
      final deleted = await call('deleteRegion', () => offline.deleteRegion(id),
          args: {'regionId': id});
      expect(deleted.hasError, isFalse, reason: offlineDebugJson(deleted));
      final deleteWatch = Stopwatch()..start();
      while ((await call(
              'listInstalledMapRegions', offline.listInstalledMapRegions))
          .any((row) => row.regionId == id)) {
        if (deleteWatch.elapsed > const Duration(seconds: 40)) {
          fail('Map data was not deleted');
        }
        await Future<void>.delayed(const Duration(seconds: 1));
      }
      touchedRegion = false;
      stage = 'example page';
      await unsubscribe();
      await call('endDownloadPage', () => offline.endDownloadPage(page!));
      page = null;
      await tester
          .pumpWidget(const MaterialApp(home: OfflineDownloadManager()));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(find.text(OfflineDownloadManager.title), findsOneWidget);
      await tester.ensureVisible(find.text('Diagnostics'));
      await tester.tap(find.text('Diagnostics'));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Offline API and Runtime Status'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      stage = 'passed';
    } finally {
      final cleanupErrors = <Object?>[];
      Future<void> clean(String name, Future<void> Function() action) async {
        try {
          await action().timeout(const Duration(seconds: 30));
        } catch (error) {
          cleanupErrors
              .add({'method': name, 'error': offlineDebugValue(error)});
        }
      }

      await clean('progress.cancel', unsubscribe);
      final token = page;
      if (token != null) {
        await clean('endDownloadPage', () => offline.endDownloadPage(token));
      }
      if (touchedRegion && testRegion != null) {
        final id = testRegion;
        await clean('cancelRegion', () async {
          await offline.cancelRegion(id);
        });
        await clean('deleteRegion', () async {
          await offline.deleteRegion(id);
        });
      }
      final restore = original;
      if (restore != null) {
        await clean(
            'configure.restore',
            () => offline.configure(
                routeMode: restore.routeMode,
                networkPolicy: restore.networkPolicy));
      }
      await clean('shutdown', offline.shutdown);
      final report = {
        'platform': Platform.operatingSystem,
        'device': const String.fromEnvironment('OFFLINE_TEST_DEVICE'),
        'stage': stage,
        'testRegion': testRegion,
        'calls': log.entries.reversed.toList(),
        'networkDisconnectedTested': false,
        'processRestartTested': false,
        'cleanupErrors': cleanupErrors,
      };
      binding.reportData =
          jsonDecode(jsonEncode(report).replaceAll(key, '[REDACTED]'))
              as Map<String, dynamic>;
      debugPrint('NB_OFFLINE_REPORT ${jsonEncode({
            'platform': Platform.operatingSystem,
            'stage': stage,
            'testRegion': testRegion,
            'methods':
                log.entries.map((entry) => entry['method']).toSet().toList(),
          })}');
      if (stage == 'passed') {
        expect(cleanupErrors, isEmpty, reason: 'Cleanup must also succeed');
      }
    }
  }, timeout: const Timeout(Duration(minutes: 50)));
}
