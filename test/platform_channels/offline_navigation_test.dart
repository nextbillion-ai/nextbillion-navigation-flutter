import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const methods = MethodChannel('test/navigation/offline');
  const events = EventChannel('test/navigation/offline/events');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late OfflineNavigation offline;
  late List<MethodCall> calls;

  setUp(() {
    calls = [];
    offline = OfflineNavigation.withChannels(methods, events);
    messenger.setMockMethodCallHandler(methods, (call) async {
      calls.add(call);
      return null;
    });
  });
  tearDown(() {
    messenger.setMockMethodCallHandler(methods, null);
    messenger.setMockMethodCallHandler(MethodChannel(events.name), null);
  });

  test('partial catalog failures preserve usable routing rows', () async {
    messenger.setMockMethodCallHandler(
        methods,
        (call) async => {
              'regions': [
                {
                  'regionId': 42,
                  'name': 'County',
                  'hasRouting': true,
                  'hasMapTiles': false,
                  'routingInstalled': true,
                  'routingSizeBytes': 5000000000
                },
              ],
              'mapError': 'Map catalog unavailable',
              'updatedAtMs': 1720000000123,
            });
    final value = await offline.fetchRegions(country: ' Australia ');
    expect(value.regions.single.regionId, 42);
    expect(value.regions.single.routingInstalled, isTrue);
    expect(value.regions.single.hasMapTiles, isFalse);
    expect(value.regions.single.routingSizeBytes, 5000000000);
    expect(value.mapError, 'Map catalog unavailable');
    expect(value.updatedAt.millisecondsSinceEpoch, 1720000000123);
  });

  test('management retains separate child failures after partial deletion',
      () async {
    messenger.setMockMethodCallHandler(
        methods,
        (call) async => {
              'regionId': 42,
              'routing': {
                'state': 'DELETED',
                'errorCode': 0,
                'tilesGcDeleted': 10
              },
              'mapTiles': {
                'state': 'FAILED',
                'errorCode': -4,
                'message': 'Disk busy'
              },
            });
    final value = await offline.deleteRegion(42);
    expect(value.routing.hasError, isFalse);
    expect(value.mapTiles.hasError, isTrue);
    expect(value.hasError, isTrue);
    expect(value.routing.details['tilesGcDeleted'], 10);
    expect(value.mapTiles.message, 'Disk busy');
  });

  test('native errors retain retry and root cause metadata', () async {
    messenger.setMockMethodCallHandler(methods, (call) {
      throw PlatformException(
          code: 'NETWORK_UNAVAILABLE',
          message: 'No Wi-Fi',
          details: {
            'recoverable': true,
            'causeCode': 'offline.precheck.network'
          });
    });
    await expectLater(
        offline.downloadRegion(42),
        throwsA(isA<PlatformException>()
            .having((e) => e.code, 'code', 'NETWORK_UNAVAILABLE')
            .having((e) => (e.details as Map)['recoverable'], 'recoverable',
                true)));
  });

  test('invalid IDs and blank countries never reach native code', () async {
    for (final id in [0, -1, 0x80000000]) {
      await expectLater(offline.downloadRegion(id), throwsRangeError);
      await expectLater(offline.getRegionBoundary(id), throwsRangeError);
    }
    await expectLater(offline.fetchRegions(country: '  '), throwsArgumentError);
    expect(calls, isEmpty);
  });

  test(
      'combined failure exposes observed side effects without reporting success',
      () async {
    messenger.setMockMethodCallHandler(methods, (call) {
      throw PlatformException(
          code: 'INTERNAL_ERROR',
          message: 'Routing failed',
          details: {
            'recoverable': false,
            'partialOperation': {
              'regionId': 42,
              'operation': 'downloadRegion',
              'mayHaveSideEffects': true,
              'progress': {
                'regionId': 42,
                'routing': {'state': 'FAILED', 'percent': 0},
                'mapTiles': {'state': 'RUNNING', 'percent': 20},
              },
              'installedMapRead': true,
              'installedMap': null,
            },
          });
    });
    await expectLater(
        offline.downloadRegion(42),
        throwsA(isA<OfflineRegionOperationException>()
            .having((e) => e.regionId, 'regionId', 42)
            .having((e) => e.progress!.mapTiles!.state, 'map state',
                OfflineTaskState.running)
            .having((e) => e.installedMapRead, 'local read completed', true)
            .having((e) => e.installedMap, 'installed map', isNull)
            .having((e) => e.code, 'original error', 'INTERNAL_ERROR')));
  });

  test('unavailable failure diagnostics remain unknown', () async {
    messenger.setMockMethodCallHandler(methods, (call) {
      throw PlatformException(code: 'TIMEOUT', details: {
        'partialOperation': {
          'regionId': 42,
          'operation': 'deleteRegion',
          'installedMapRead': false
        },
      });
    });
    await expectLater(
        offline.deleteRegion(42),
        throwsA(isA<OfflineRegionOperationException>()
            .having((e) => e.progress, 'progress unknown', isNull)
            .having((e) => e.installedMapRead, 'read unknown', false)));
  });

  test('stale page cleanup passes its original ownership token', () async {
    final first = await offline.beginDownloadPage();
    final second = await offline.beginDownloadPage();
    expect(first, isNot(second));
    await offline.endDownloadPage(first);
    expect(calls.last.arguments, {'pageId': first});
    expect(calls.where((call) => call.method == 'cancelRegion'), isEmpty);
  });

  test(
      'progress subscribers share the native observer and cancel independently',
      () async {
    var listens = 0;
    var cancels = 0;
    messenger.setMockMethodCallHandler(MethodChannel(events.name),
        (call) async {
      if (call.method == 'listen') listens++;
      if (call.method == 'cancel') cancels++;
      return null;
    });
    final firstRows = <List<OfflineRegionProgress>>[];
    final secondRows = <List<OfflineRegionProgress>>[];
    final first = offline.progress.listen(firstRows.add);
    await Future<void>.delayed(Duration.zero);
    Future<void> send(int percent) async {
      final data = const StandardMethodCodec().encodeSuccessEnvelope([
        {
          'regionId': 42,
          'updatedAtMs': 1720000000123,
          'routing': {'state': 'COMPLETED', 'percent': 100},
          'mapTiles': {'state': 'RUNNING', 'percent': percent},
          'overallState': 'RUNNING',
          'overallPercent': percent
        },
      ]);
      await messenger.handlePlatformMessage(events.name, data, (_) {});
      await Future<void>.delayed(Duration.zero);
    }

    await send(50);
    final second = offline.progress.listen(secondRows.add);
    await Future<void>.delayed(Duration.zero);
    expect(listens, 1);
    expect(firstRows.single.single.downloadsComplete, isFalse);
    expect(secondRows.single.single.updatedAt.isUtc, isTrue);
    await first.cancel();
    expect(cancels, 0);
    await send(100);
    // 100% while RUNNING still does not mean the installation is complete.
    expect(secondRows.last.single.downloadsComplete, isFalse);
    expect(firstRows, hasLength(1));
    await second.cancel();
    await Future<void>.delayed(Duration.zero);
    expect(cancels, 1);
    final reopenedRows = <List<OfflineRegionProgress>>[];
    final reopened = offline.progress.listen(reopenedRows.add);
    await Future<void>.delayed(Duration.zero);
    expect(reopenedRows, isEmpty);
    await send(25);
    expect(reopenedRows.single.single.mapTiles!.percent, 25);
    await reopened.cancel();
    expect(listens, 2);
    expect(calls, isEmpty);
  });

  test('unknown native states remain unknown and unavailable probes stay null',
      () {
    final progress = OfflineRegionProgress.fromMap({
      'regionId': 42,
      'routing': {'state': 'NEW_NATIVE_STATE', 'percent': 200},
      'overallState': 'NEW_NATIVE_STATE',
    });
    expect(progress.routing!.state, OfflineTaskState.unknown);
    expect(progress.routing!.nativeState, 'NEW_NATIVE_STATE');
    expect(progress.routing!.percent, 100);
    expect(progress.downloadsComplete, isFalse);
    final preview = OfflineMapPreviewStatus.fromMap({'stylesReady': true});
    expect(preview.stylesReady, isTrue);
    expect(preview.previewBundleReady, isNull);
  });

  test('offline routing source and native route fields survive launching',
      () async {
    final routeJson = {
      'distance': 1000,
      'duration': 200,
      'geometry': 'encoded',
      'routeOptions': {
        'origin': [-80.84, 35.22],
        'destination': [-80.83, 35.23]
      },
      'native_route_metadata': {'dataset': 'v1'},
      'legs': [
        {
          'distance': {'value': 1000},
          'duration': {'value': 200},
          'annotation': {
            'speed': [10, 20]
          },
          'steps': [
            {
              'distance': {'value': 1000},
              'duration': {'value': 200},
              'start_location': {'latitude': 35.22, 'longitude': -80.84},
              'maneuver': {
                'maneuver_type': 'turn',
                'display_instruction': 'Keep left'
              },
            }
          ],
        }
      ],
    };
    const routeChannel = MethodChannel('test/navigation/routes');
    final platform = NBNavigationMethodChannel()
      ..setMethodChannel(routeChannel);
    messenger.setMockMethodCallHandler(routeChannel, (call) async {
      if (call.method == NBRouteMethodID.nbFetchRouteMethod) {
        return {
          'routeSource': 'offline',
          'routeResult': [jsonEncode(routeJson)]
        };
      }
      throw PlatformException(code: 'OFFLINE_DATA_NOT_READY');
    });
    addTearDown(() => messenger.setMockMethodCallHandler(routeChannel, null));
    final response = await platform.fetchRoute(RouteRequestParams(
        origin: const LatLng(35.22, -80.84),
        destination: const LatLng(35.23, -80.83)));
    expect(response.routeSource, NavigationRouteSource.offline);
    final route = response.directionsRoutes.single;
    route.legs.single.steps!.single.name = 'Updated road';
    final config = NavigationLauncherConfig(route: route, routes: [route]);
    final encoded = jsonDecode(config.toJson()['route'] as String) as Map;
    expect(encoded['native_route_metadata'], {'dataset': 'v1'});
    final leg = (encoded['legs'] as List).single as Map;
    expect(leg['annotation'], {
      'speed': [10, 20]
    });
    final step = (leg['steps'] as List).single as Map;
    expect(step['name'], 'Updated road');
    expect(step['start_location'], {'latitude': 35.22, 'longitude': -80.84});
    expect((step['maneuver'] as Map)['display_instruction'], 'Keep left');
    // Neither encoding nor subsequent consumer mutation changes the source JSON.
    final direct = route.toJson();
    final directLeg = (direct['legs'] as List).single as Map;
    final directStep = (directLeg['steps'] as List).single as Map;
    (directStep['start_location'] as Map)['latitude'] = 0;
    final freshLeg = (route.toJson()['legs'] as List).single as Map;
    final freshStep = (freshLeg['steps'] as List).single as Map;
    expect((freshStep['start_location'] as Map)['latitude'], 35.22);
    await expectLater(
        platform.startNavigation(config),
        throwsA(isA<PlatformException>()
            .having((error) => error.code, 'code', 'OFFLINE_DATA_NOT_READY')));
  });
}
