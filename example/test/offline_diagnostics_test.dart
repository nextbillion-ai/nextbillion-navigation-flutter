import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nb_navigation_flutter_example/offline_diagnostics.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

void main() {
  test('typed catalog failures and quoted credentials are redacted', () {
    final catalog = OfflineNavigationRegions.fromMap({
      'regions': [],
      'mapError': 'https://example.test?key=secret',
      'routingError': '{"access_token":"secret"}',
    });
    expect(offlineDebugJson(catalog), isNot(contains('secret')));
    expect(redactOfflineText('Turkey catalog is unavailable'),
        'Turkey catalog is unavailable');
  });
  test(
      'method history is bounded and redacts credentials in errors and arguments',
      () async {
    final history = OfflineMethodLog(limit: 2);
    await history.run('initialize', () async {});
    await history
        .run('configure', () async {}, arguments: {'access_key': 'secret'});
    await expectLater(
        history.run('fetchRegions', () async {
          throw PlatformException(
              code: 'NETWORK',
              message: 'https://example.test?key=secret&country=US');
        }),
        throwsA(isA<PlatformException>()));
    expect(history.entries, hasLength(2));
    expect(history.export(), isNot(contains('secret')));
    expect(history.export(), contains('REDACTED'));
    expect(history.entries.first['status'], 'error');
  });
}
