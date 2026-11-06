import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';
import 'package:nb_navigation_flutter_example/offline_download_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const methods = MethodChannel('test/download-manager');
  const events = EventChannel('test/download-manager/events');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late List<MethodCall> calls;
  late OfflineNavigation offline;
  late List<Map<String, dynamic>> installed;
  late bool catalogOffline;
  Completer<Map<String, dynamic>>? download;
  bool partialFailure = false;

  Map<String, dynamic> operation(int id, String state) => {
        'regionId': id,
        'routing': {'state': state, 'errorCode': 0},
        'mapTiles': {'state': state, 'errorCode': 0},
      };

  setUp(() {
    calls = [];
    catalogOffline = false;
    download = null;
    partialFailure = false;
    installed = [
      {
        'regionId': 99,
        'name': 'Saved County',
        'totalBytes': 4096,
        'packageCount': 1,
        'packagesComplete': true
      }
    ];
    offline = OfflineNavigation.withChannels(methods, events);
    messenger.setMockMethodCallHandler(
        MethodChannel(events.name), (_) async => null);
    messenger.setMockMethodCallHandler(methods, (call) async {
      calls.add(call);
      final args = call.arguments as Map?;
      switch (call.method) {
        case 'getConfiguration':
          return {'routeMode': 'smart', 'networkPolicy': 'wifiOnly'};
        case 'isMapDownloadSupported':
          return true;
        case 'listInstalledMapRegions':
          return installed;
        case 'getPreviewStatus':
          return {'stylesReady': true, 'previewBundleReady': false};
        case 'getRegionBoundary':
          return '{"type":"FeatureCollection","features":[]}';
        case 'healthCheck':
          return {'state': 'ready', 'loadedTileCount': 3};
        case 'syncRegions':
          if (catalogOffline) {
            throw PlatformException(
                code: 'NETWORK_UNAVAILABLE', message: 'Offline');
          }
          return null;
        case 'fetchRegions':
          if (catalogOffline) {
            throw PlatformException(
                code: 'NETWORK_UNAVAILABLE', message: 'Offline');
          }
          return {
            'regions': [
              {
                'regionId': 42,
                'name': 'Test County',
                'adminL1': 'Test State',
                'hasRouting': true,
                'hasMapTiles': true,
                'routingSizeBytes': 1024,
                'mapSizeBytes': 2048
              }
            ]
          };
        case 'downloadRegion':
          if (partialFailure) {
            throw PlatformException(
                code: 'INTERNAL_ERROR',
                message: 'Routing failed',
                details: {
                  'partialOperation': {
                    'regionId': 42,
                    'operation': 'downloadRegion',
                    'progress': {
                      'regionId': 42,
                      'routing': {'state': 'FAILED', 'percent': 0},
                      'mapTiles': {'state': 'RUNNING', 'percent': 20},
                    },
                    'installedMapRead': true,
                  },
                });
          }
          return download == null
              ? operation(42, 'ENQUEUED')
              : await download!.future;
        case 'pauseRegion':
          return operation(args!['regionId'] as int, 'PAUSED');
        case 'deleteRegion':
          installed = [];
          return operation(args!['regionId'] as int, 'DELETED');
        default:
          return null;
      }
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(methods, null);
    messenger.setMockMethodCallHandler(MethodChannel(events.name), null);
  });

  Future<void> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
        MaterialApp(home: OfflineDownloadManager(offline: offline)));
    await tester.pumpAndSettle();
  }

  Future<void> revealRegionControl(WidgetTester tester, Finder control) async {
    await tester.drag(find.byType(NestedScrollView), const Offset(0, -450));
    await tester.pumpAndSettle();
    await tester.ensureVisible(control);
    await tester.pumpAndSettle();
  }

  Future<void> sendProgress(WidgetTester tester, String state) async {
    await messenger.handlePlatformMessage(
        events.name,
        const StandardMethodCodec().encodeSuccessEnvelope([
          {
            'regionId': 42,
            'updatedAtMs': 1234,
            'overallState': state,
            'overallPercent': 30,
            'routing': {
              'state': state,
              'percent': 30,
              'downloaded': 3,
              'total': 10
            },
            'mapTiles': {
              'state': state,
              'percent': 10,
              'downloaded': 100,
              'total': 1000
            }
          },
        ]),
        (_) {});
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('restores local data when the online catalog is unavailable',
      (tester) async {
    catalogOffline = true;
    await mount(tester);
    expect(find.textContaining('Catalog loading failed'), findsOneWidget);
    await tester.ensureVisible(find.text('Installed (1)'));
    await tester.tap(find.text('Installed (1)'));
    await tester.pumpAndSettle();
    expect(find.text('Saved County'), findsOneWidget);
    expect(find.text('Map data · Installed'), findsOneWidget);
    expect(find.text('Routing data · No local status'), findsOneWidget);
    expect(calls.where((call) => call.method == 'configure'), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('download can be paused before its original Future completes',
      (tester) async {
    download = Completer<Map<String, dynamic>>();
    await mount(tester);
    final downloadButton = find.byKey(const ValueKey('download-42-download'));
    await revealRegionControl(tester, downloadButton);
    await tester.tap(downloadButton);
    await tester.pump();
    expect(
        calls.where((call) => call.method == 'downloadRegion'), hasLength(1));
    final pauseButton = find.byKey(const ValueKey('download-42-pause'));
    expect(tester.widget<TextButton>(pauseButton).onPressed, isNotNull);
    await tester.tap(pauseButton);
    await tester.pumpAndSettle();
    expect(calls.where((call) => call.method == 'pauseRegion'), hasLength(1));
    await sendProgress(tester, 'PAUSED');
    expect(find.text('Routing data · Paused'), findsOneWidget);
    expect(find.text('3 / 10 tiles'), findsOneWidget);
    // A late download result must not overwrite the newer pause outcome.
    download!.complete(operation(42, 'PARTIAL'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Pause · Test County'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'deleting installed data requires confirmation and refreshes local rows',
      (tester) async {
    await mount(tester);
    await tester.ensureVisible(find.text('Installed (1)'));
    await tester.tap(find.text('Installed (1)'));
    await tester.pumpAndSettle();
    final button = find.byKey(const ValueKey('download-99-delete'));
    await revealRegionControl(tester, button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('Delete Offline Data?'), findsOneWidget);
    expect(calls.where((call) => call.method == 'deleteRegion'), isEmpty);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete Data'));
    await tester.pumpAndSettle();
    expect(calls.where((call) => call.method == 'deleteRegion'), hasLength(1));
    expect(find.text('No Installed Data'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'policy changes preserve routing mode and closing only releases the page',
      (tester) async {
    await mount(tester);
    await tester.tap(find.text('Wi-Fi Only'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Any Available Network').last);
    await tester.pumpAndSettle();
    final configure = calls.singleWhere((call) => call.method == 'configure');
    expect(configure.arguments,
        {'routeMode': 'smart', 'networkPolicy': 'anyNetwork'});
    final begin =
        calls.singleWhere((call) => call.method == 'beginDownloadPage');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    final end = calls.singleWhere((call) => call.method == 'endDownloadPage');
    expect(end.arguments, begin.arguments);
    expect(
        calls.where((call) =>
            call.method == 'cancelRegion' || call.method == 'shutdown'),
        isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'partial native failure retains the running map task and warns about side effects',
      (tester) async {
    partialFailure = true;
    await mount(tester);
    final downloadButton =
        find.byKey(const ValueKey('download-42-download')).first;
    await revealRegionControl(tester, downloadButton);
    await tester.tap(downloadButton);
    await tester.pumpAndSettle();
    expect(find.textContaining('The operation may have partially completed'),
        findsWidgets);
    expect(find.textContaining('Map: RUNNING'), findsWidgets);
    await tester.ensureVisible(find.text('Tasks (1)'));
    await tester.tap(find.text('Tasks (1)'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('download-region-42')), findsOneWidget);
    expect(find.text('Map data · Downloading or installing'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('region details can query both local and fetched boundaries',
      (tester) async {
    await mount(tester);
    Future<void> details() async {
      final button = find.byKey(const ValueKey('download-42-details')).first;
      await revealRegionControl(tester, button);
      await tester.tap(button);
      await tester.pumpAndSettle();
    }

    await details();
    expect(find.textContaining('routingVersion'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('boundary-local-42')));
    await tester.pumpAndSettle();
    expect(
        calls.lastWhere((call) => call.method == 'getRegionBoundary').arguments,
        {'regionId': 42, 'fetchIfMissing': false});
    await tester.tap(find.text('Close').last);
    await tester.pumpAndSettle();
    await details();
    await tester.tap(find.byKey(const ValueKey('boundary-fetch-42')));
    await tester.pumpAndSettle();
    expect(
        calls.lastWhere((call) => call.method == 'getRegionBoundary').arguments,
        {'regionId': 42, 'fetchIfMissing': true});
    await tester.tap(find.text('Close').last);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets(
      'diagnostics exposes resource refresh and confirms engine shutdown',
      (tester) async {
    await mount(tester);
    await tester.ensureVisible(find.text('Diagnostics'));
    await tester.tap(find.text('Diagnostics'));
    await tester.pumpAndSettle();
    final refresh =
        find.widgetWithText(OutlinedButton, 'Refresh Map Resources');
    await tester.ensureVisible(refresh);
    await tester.tap(refresh);
    await tester.pumpAndSettle();
    expect(calls.any((call) => call.method == 'refreshMapResources'), isTrue);
    await tester.tap(find.text('Close').last);
    await tester.pumpAndSettle();
    final shutdown =
        find.widgetWithText(OutlinedButton, 'Shut Down Offline Engine');
    await tester.ensureVisible(shutdown);
    await tester.tap(shutdown);
    await tester.pumpAndSettle();
    expect(calls.where((call) => call.method == 'shutdown'), isEmpty);
    await tester.tap(find.widgetWithText(FilledButton, 'Shut Down'));
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(calls.where((call) => call.method == 'shutdown'), hasLength(1));
    expect(
        calls.where((call) => call.method == 'endDownloadPage'), hasLength(1));
    final initialize = find.widgetWithText(OutlinedButton, 'Initialize Engine');
    expect(tester.widget<OutlinedButton>(initialize).onPressed, isNotNull,
        reason: 'Shutdown must finish before another initialization starts');
    await Scrollable.ensureVisible(tester.element(initialize), alignment: 0.5);
    await tester.pumpAndSettle();
    await tester.tap(initialize);
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(calls.where((call) => call.method == 'initialize'), hasLength(2),
        reason: calls.map((call) => call.method).join(', '));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
