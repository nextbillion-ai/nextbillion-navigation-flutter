import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';
import 'package:nb_navigation_flutter_example/constants.dart';
import 'package:nb_navigation_flutter_example/embedded_navigation_view_intergration.dart';

import 'package:nb_navigation_flutter_example/main.dart' as app;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Navigation end to end test', (WidgetTester tester) async {
    app.main();

    await tester.pumpAndSettle();

    pushToEmbeddedNavigationView(tester);
    await Future.delayed(const Duration(seconds: 1));
    checkMapViewExist(tester);

    // wait for the map to load
    await Future.delayed(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Configure the request options.
    await configureRequestOptions(
      tester,
      mode: NBString.car,
      unit: NBString.imperial,
      alternatives: true,  // By default, the alternatives are enabled.
    );

    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await Future.delayed(const Duration(seconds: 2));

    await fetchRoutes(tester);

    await Future.delayed(const Duration(seconds: 5));

    await checkStartNavigation(tester);

    await Future.delayed(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    checkOverView(tester,binding);

    await Future.delayed(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    await checkClickCenterToShowRecenterButton(tester,binding);
    await Future.delayed(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    await checkDragBottomSheet(tester,binding);

    await Future.delayed(const Duration(seconds: 10));
    await tester.pumpAndSettle();
    await exitNavigation(tester);

    await Future.delayed(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    await Future.delayed(const Duration(seconds: 10));
    await tester.pumpAndSettle();

    // Configure the request options.
    await configureRequestOptions(
      tester,
      mode: NBString.truck,
      unit: NBString.metric,
      alternatives: false,  // By default, the alternatives are enabled.
    );

    await Future.delayed(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    checkMapViewExist(tester);

    await fetchRoutes(tester);

    await Future.delayed(const Duration(seconds: 5));
    await checkStartNavigation(tester);

    await Future.delayed(const Duration(seconds: 10));
    await tester.pumpAndSettle();
    await exitNavigation(tester);

    await Future.delayed(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });
}

void pushToEmbeddedNavigationView(WidgetTester tester) async {
  final fullNavItem = find.text(EmbeddedNavigationViewIntegration.title);
  await tester.pumpAndSettle();
  expect(fullNavItem, findsOneWidget);

  await tester.tap(fullNavItem);
  await tester.pumpAndSettle();
}

void checkMapViewExist(WidgetTester tester) {
  final mapView = find.byType(NBMap);
  expect(mapView, findsOneWidget);
}

Future fetchRoutes(WidgetTester tester) async {
  final fetchRouteBtn = find.text(NBString.fetchRoutes);
  expect(fetchRouteBtn, findsOneWidget);

  await tester.tap(fetchRouteBtn);
  await tester.pumpAndSettle();
  await Future.delayed(const Duration(seconds: 2));
  await tester.pumpAndSettle();
  await Future.delayed(const Duration(seconds: 2));
  await tester.pumpAndSettle();
  await Future.delayed(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

Future checkStartNavigation(WidgetTester tester) async {
  final startNavigationBtn = find.text(NBString.startNavigation);
  expect(startNavigationBtn, findsOneWidget);

  await tester.tap(startNavigationBtn);
  await tester.pumpAndSettle();
  await Future.delayed(const Duration(seconds: 1));
  await tester.pumpAndSettle();

  final navigationView = find.byKey(const Key("NBNavigationView"));
  expect(navigationView, findsOneWidget);
}
Future exitNavigation(WidgetTester tester) async {
  final Size screenSize = tester.getSize(find.byType(MaterialApp));

  final Offset tapPosition = Offset(
    screenSize.width - 40,
    screenSize.height - 50,
  );
  await tester.tapAt(tapPosition);
  await tester.pumpAndSettle();
}

Future checkOverView(WidgetTester tester,IntegrationTestWidgetsFlutterBinding binding) async {
  final Size screenSize = tester.getSize(find.byType(MaterialApp));

  final Offset tapPosition = Offset(
    screenSize.width - 130,
    screenSize.height - 50,
  );
  await tester.tapAt(tapPosition);
  await tester.pumpAndSettle();

  await Future.delayed(const Duration(seconds: 2));

  await tester.tapAt(tapPosition);
  await tester.pumpAndSettle();
}

Future checkDragBottomSheet(WidgetTester tester,IntegrationTestWidgetsFlutterBinding binding) async {

  final Size screenSize = tester.getSize(find.byType(MaterialApp));
  final Offset dragUpFrom = Offset(
    screenSize.width/2,
    screenSize.height - 50, // 距离底部 50px
  );

  await tester.dragFrom(dragUpFrom, const Offset(0, -300));
  await tester.pumpAndSettle();

  await Future.delayed(const Duration(seconds: 2));

  final Offset dragDownFrom = Offset(
    screenSize.width/2,
    screenSize.height - 350,
  );
  await tester.dragFrom(dragDownFrom, const Offset(0, 300));
  await tester.pumpAndSettle();
}

Future checkClickCenterToShowRecenterButton(WidgetTester tester,IntegrationTestWidgetsFlutterBinding binding) async {
  final Size screenSize = tester.getSize(find.byType(MaterialApp));
  final Offset dragUpFrom = Offset(
    screenSize.width/2,
    screenSize.height/2,
  );
  await tester.dragFrom(dragUpFrom, const Offset(0, -20));
  await tester.pumpAndSettle();
  await Future.delayed(const Duration(seconds: 2));
  final Offset recenterPosition = Offset(
    100,
    screenSize.height - 30,
  );

  await tester.tapAt(recenterPosition);
  await tester.pumpAndSettle();
}

Future configureRequestOptions(
  WidgetTester tester, {
  required String mode,
  required String unit,
  required bool alternatives,

}) async {
  final modeSelector = find.text(mode);
  final unitSelector = find.text(unit);
  final alternativeSelector = find.byKey(const Key(NBString.showAlternative));

  expect(modeSelector, findsOneWidget);
  expect(unitSelector, findsOneWidget);
  expect(alternativeSelector, findsOneWidget);

  // Tap on the mode selector.
  await tester.tap(modeSelector);
  await tester.pumpAndSettle();

  // Tap on the unit selector.
  await tester.tap(unitSelector);
  await tester.pumpAndSettle();

  if(!alternatives){
    // Tap on the alternative selector.
    await tester.tap(alternativeSelector);
    await tester.pumpAndSettle();
  }
}
