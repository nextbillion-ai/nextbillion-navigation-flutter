import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';
import 'package:nb_navigation_flutter_example/offline_navigation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('changing points discards old responses while a new request runs',
      (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const offline = MethodChannel('nb_navigation_flutter/offline');
    const events = MethodChannel('nb_navigation_flutter/offline/events');
    const navigation = MethodChannel('nb_navigation_flutter');
    messenger.setMockMethodCallHandler(events, (_) async => null);
    messenger.setMockMethodCallHandler(
        offline,
        (call) async => switch (call.method) {
              'getConfiguration' => {
                  'routeMode': 'onlineOnly',
                  'networkPolicy': 'wifiOnly'
                },
              'isMapDownloadSupported' => true,
              'listInstalledMapRegions' => [],
              'getPreviewStatus' => {'stylesReady': false},
              _ => null,
            });
    final requests = <Completer<Map<String, dynamic>>>[];
    messenger.setMockMethodCallHandler(navigation, (call) async {
      final pending = Completer<Map<String, dynamic>>();
      requests.add(pending);
      return pending.future;
    });
    addTearDown(() {
      messenger.setMockMethodCallHandler(offline, null);
      messenger.setMockMethodCallHandler(events, null);
      messenger.setMockMethodCallHandler(navigation, null);
    });
    await tester
        .pumpWidget(const MaterialApp(home: OfflineNavigationExample()));
    await tester.pumpAndSettle();
    void select(LatLng point) => tester
        .widget<NBMap>(find.byType(NBMap))
        .onMapClick!(const Point<double>(0, 0), point);
    select(const LatLng(35.22, -80.84));
    select(const LatLng(35.23, -80.83));
    await tester.pump();
    await tester.tap(find.text('Calculate route'));
    await tester.pump();
    expect(requests, hasLength(1));
    select(const LatLng(35.24, -80.82));
    select(const LatLng(35.25, -80.81));
    await tester.pump();
    await tester.tap(find.text('Calculate route'));
    await tester.pump();
    expect(requests, hasLength(2));
    requests.first.complete({'routeResult': [], 'message': 'Obsolete failure'});
    await tester.pump();
    expect(find.text('Calculating…'), findsOneWidget);
    expect(find.text('Obsolete failure'), findsNothing);
    requests.last.complete({
      'routeSource': 'offline',
      'routeResult': [
        jsonEncode({
          'geometry': 'encoded',
          'legs': [],
          'routeOptions': {
            'origin': [-80.82, 35.24],
            'destination': [-80.81, 35.25]
          },
        })
      ],
    });
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<OutlinedButton>(
                find.widgetWithText(OutlinedButton, 'Navigate'))
            .onPressed,
        isNotNull);
    expect(find.textContaining('Route source: offline'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    debugDefaultTargetPlatformOverride = null;
  });
}
