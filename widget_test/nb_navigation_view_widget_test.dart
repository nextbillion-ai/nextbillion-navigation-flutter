import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';
import 'package:provider/provider.dart';

import 'widget_route_test_json.dart';

void main() {
  testWidgets('NBNavigationView Widget Test', (WidgetTester tester) async {
    DirectionsRoute route = DirectionsRoute.fromJson(widgetTestRoute);
    final mockNavigationLauncherConfig = NavigationLauncherConfig(
      route: route, // Fill with your mock data
      routes: [route], // Fill with your mock data
    );
    // Build our app and trigger a frame.
    NavigationViewController? navigationViewController;
    await tester.pumpWidget(
      Provider<NavigationLauncherConfig>(
        create: (context) => mockNavigationLauncherConfig,
        child: MaterialApp(
          home: NBNavigationView(
            navigationOptions: mockNavigationLauncherConfig,
            onNavigationViewReady: (controller) {
              navigationViewController = controller;
            },
            // Add other callbacks as needed
          ),
        ),
      ),
    );

    expect(navigationViewController != null, true);
    // Verify that NBNavigationView is in the widget tree.
    expect(find.byType(NBNavigationView), findsOneWidget);
  });
}