import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nb_maps_flutter/nb_maps_flutter.dart';

import 'nb_navigation_method_channels_test.mocks.dart';

@GenerateMocks([MethodChannel])
void main() {
  late MockMethodChannel mockMethodChannel;

  setUp(() {
    mockMethodChannel = MockMethodChannel();
    NextBillion.setMockMethodChannel(mockMethodChannel);

    // Set up default successful responses for all method calls
    when(mockMethodChannel.invokeMethod<String>('nextbillion/get_nb_id'))
        .thenAnswer((_) async => 'test_nb_id');
    when(mockMethodChannel.invokeMethod<String>('nextbillion/get_user_id'))
        .thenAnswer((_) async => 'test_user_id');
    when(mockMethodChannel.invokeMethod<void>('nextbillion/set_user_id', any))
        .thenAnswer((_) async {});
  });

  tearDown(() {
    // Reset any static state
    // NextBillion.setMockMethodChannel(null);
  });

  group('NextBillion User ID Tests', () {
    test('getNbId returns correct value', () async {

      final result = await NextBillion.getNbId();

      expect(result, 'test_nb_id');
      verify(mockMethodChannel.invokeMethod<String>('nextbillion/get_nb_id')).called(1);
    });

    test('setUserId calls method with correct arguments', () async {
      const userId = 'test_user_id';
      final config = {"userId": userId};

      await NextBillion.setUserId(userId);

      verify(mockMethodChannel.invokeMethod<void>('nextbillion/set_user_id', config)).called(1);
    });

    test('getUserId returns correct value', () async {

      final result = await NextBillion.getUserId();

      expect(result, 'test_user_id');
      verify(mockMethodChannel.invokeMethod<String>('nextbillion/get_user_id')).called(1);
    });

    test('setUserId handles empty string', () async {
      const userId = '';
      final config = {"userId": userId};

      await NextBillion.setUserId(userId);

      verify(mockMethodChannel.invokeMethod<void>('nextbillion/set_user_id', config)).called(1);
    });

    test('getNbId throws specific PlatformException', () async {
      const errorCode = 'NOT_FOUND';
      const errorMessage = 'NB ID not found';
      when(mockMethodChannel.invokeMethod<String>('nextbillion/get_nb_id'))
          .thenThrow(PlatformException(code: errorCode, message: errorMessage));

      expect(
        () => NextBillion.getNbId(),
        throwsA(isA<PlatformException>()
            .having((e) => e.code, 'code', errorCode)
            .having((e) => e.message, 'message', errorMessage)),
      );
    });

    test('setUserId throws specific PlatformException', () async {
      const errorCode = 'INVALID_ARGUMENT';
      const errorMessage = 'Invalid user ID';
      const userId = 'test_user_id';
      final config = {"userId": userId};

      when(mockMethodChannel.invokeMethod<void>('nextbillion/set_user_id', config))
          .thenThrow(PlatformException(code: errorCode, message: errorMessage));

      expect(
        () => NextBillion.setUserId(userId),
        throwsA(isA<PlatformException>()
            .having((e) => e.code, 'code', errorCode)
            .having((e) => e.message, 'message', errorMessage)),
      );
    });

    test('getUserId throws specific PlatformException', () async {
      const errorCode = 'NOT_FOUND';
      const errorMessage = 'User ID not found';
      when(mockMethodChannel.invokeMethod<String>('nextbillion/get_user_id'))
          .thenThrow(PlatformException(code: errorCode, message: errorMessage));

      expect(
        () => NextBillion.getUserId(),
        throwsA(isA<PlatformException>()
            .having((e) => e.code, 'code', errorCode)
            .having((e) => e.message, 'message', errorMessage)),
      );
    });
  });
}
