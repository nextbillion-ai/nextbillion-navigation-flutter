import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

class _DelayedPlatform extends MethodChannelNavigationView {
  final initialized = Completer<void>();
  final progress = StreamController<NavigationProgress?>();
  late OnPlatformViewCreatedCallback created;
  int stops = 0;
  int releases = 0;

  @override
  Stream<NavigationProgress?> get navProgressListener => progress.stream;

  Future<void> create(int id) => (created as Future<void> Function(int))(id);

  @override
  Widget buildView(Map<String, dynamic> creationParams,
      OnPlatformViewCreatedCallback onPlatformViewCreated) {
    created = onPlatformViewCreated;
    return const SizedBox();
  }

  @override
  Future<void> initPlatform(int id) async {
    await super.initPlatform(id);
    await initialized.future;
  }

  @override
  Future<void> stopNavigation() async {
    stops++;
    await super.stopNavigation();
  }

  @override
  void dispose() {
    releases++;
    unawaited(progress.close());
    super.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _DelayedPlatform platform;
  final originalFactory = NBNavigationViewPlatform.createInstance;
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  setUp(() {
    NBNavigationViewPlatform.createInstance = () => platform;
    for (final name in [
      'flutter_nb_navigation/7',
      'flutter_nb_navigation/7/events'
    ]) {
      messenger.setMockMethodCallHandler(
          MethodChannel(name), (_) async => null);
    }
  });
  tearDown(() {
    NBNavigationViewPlatform.createInstance = originalFactory;
    for (final name in [
      'flutter_nb_navigation/7',
      'flutter_nb_navigation/7/events'
    ]) {
      messenger.setMockMethodCallHandler(MethodChannel(name), null);
    }
  });

  testWidgets(
      'a view created after its Flutter page closes is still stopped and released',
      (tester) async {
    platform = _DelayedPlatform();
    await tester.pumpWidget(
        const MaterialApp(home: NBNavigationView(navigationOptions: null)));
    final creating = platform.create(7);
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    platform.initialized.complete();
    await creating;
    await tester.pumpAndSettle();
    expect(platform.stops, 1);
    expect(platform.releases, 1);
    expect(platform.getMethodChannel(), isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'normal page removal closes the progress stream before releasing its channel',
      (tester) async {
    platform = _DelayedPlatform();
    await tester.pumpWidget(
        const MaterialApp(home: NBNavigationView(navigationOptions: null)));
    final creating = platform.create(7);
    platform.initialized.complete();
    await creating;
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(platform.stops, 1);
    expect(platform.releases, 1);
    expect(platform.getEventChannel(), isNull);
    expect(tester.takeException(), isNull);
  });
}
