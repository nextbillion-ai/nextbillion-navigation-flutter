import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

void main() {
  group('NBNavigationViewPlatform', () {
    test('instance returns the same instance', () {
      WidgetsFlutterBinding.ensureInitialized();
      final instance1 = NBNavigationViewPlatform.createInstance;
      final instance2 = NBNavigationViewPlatform.createInstance;

      expect(instance1, instance2);
    });
  });
}
