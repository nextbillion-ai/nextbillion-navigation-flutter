import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

import 'widget_route_test_json.dart';

class _WidgetPlatform extends MethodChannelNavigationView {
  late OnPlatformViewCreatedCallback created;
  late Map<String, dynamic> parameters;

  @override
  Stream<NavigationProgress?> get navProgressListener => const Stream.empty();

  @override
  Widget buildView(Map<String, dynamic> creationParams,
      OnPlatformViewCreatedCallback onPlatformViewCreated) {
    parameters = creationParams;
    created = onPlatformViewCreated;
    return const SizedBox();
  }
}

void main() {
  testWidgets('navigation becomes ready only after the native ready event',
      (tester) async {
    final originalFactory = NBNavigationViewPlatform.createInstance;
    final platform = _WidgetPlatform();
    NBNavigationViewPlatform.createInstance = () => platform;
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
        const MethodChannel('flutter_nb_navigation/9'), (_) async => null);
    addTearDown(() {
      NBNavigationViewPlatform.createInstance = originalFactory;
      messenger.setMockMethodCallHandler(
          const MethodChannel('flutter_nb_navigation/9'), null);
    });
    final route = DirectionsRoute.fromJsonWithOption(
        widgetTestRoute,
        RouteRequestParams(
            origin: const LatLng(1.292224, 103.815568),
            destination: const LatLng(1.300546, 103.816)));
    final mockNavigationLauncherConfig = NavigationLauncherConfig(
      route: route,
      routes: [route],
    );
    // Build our app and trigger a frame.
    NavigationViewController? navigationViewController;
    await tester.pumpWidget(
      MaterialApp(
        home: NBNavigationView(
          navigationOptions: mockNavigationLauncherConfig,
          onNavigationViewReady: (controller) {
            navigationViewController = controller;
          },
        ),
      ),
    );

    expect(platform.parameters['launcherConfig'],
        mockNavigationLauncherConfig.toJson());
    await (platform.created as Future<void> Function(int))(9);
    expect(navigationViewController, isNull);
    await platform.handleMethodCall(const MethodCall('onNavigationReady'));
    expect(navigationViewController, isNotNull);
    // Verify that NBNavigationView is in the widget tree.
    expect(find.byType(NBNavigationView), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
