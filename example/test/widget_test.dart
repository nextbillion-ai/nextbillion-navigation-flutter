// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nb_navigation_flutter_example/main.dart';

void main() {
  testWidgets('home offers runtime configuration when no build-time key is set',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: NavigationDemo()));
    expect(find.text('Configure Test Key'), findsOneWidget);
    expect(
        tester.widget<TextField>(find.byType(TextField)).obscureText, isTrue);
    expect(find.text('Initialize and Open Examples'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
