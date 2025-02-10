import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

void main() {
  group('NBNavigationPlatform', () {
    test('instance returns the same instance', () {
      WidgetsFlutterBinding.ensureInitialized();
      final instance1 = NBNavigationPlatform.instance;
      final instance2 = NBNavigationPlatform.instance;

      expect(instance1, instance2);
    });
  });
}
