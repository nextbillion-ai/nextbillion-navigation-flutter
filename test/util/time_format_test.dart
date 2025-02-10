import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

class MockTimeFormatter extends Mock implements TimeFormatter {}

void main() {
  test('formatSeconds should return formatted time', () {
    const seconds = 3600;
    const expected = '1 hr 0 min';

    final result = TimeFormatter.formatSeconds(seconds);

    expect(result, equals(expected));
  });

  test('formatSeconds should return "<1 min" for less than 1 minute', () {
    const seconds = 30;
    const expected = '<1 min';

    final result = TimeFormatter.formatSeconds(seconds);

    expect(result, equals(expected));
  });

  test('formatSeconds should return formatted time in minutes', () {
    const seconds = 120;
    const expected = '2 min';

    final result = TimeFormatter.formatSeconds(seconds);

    expect(result, equals(expected));
  });
}
