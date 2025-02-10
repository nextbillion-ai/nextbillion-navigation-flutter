import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'nb_navigation_method_channels_test.mocks.dart';

@GenerateMocks([MethodChannel])
void main() {
  late MockMethodChannel mockMethodChannel;

  setUp(() {
    mockMethodChannel = MockMethodChannel();
    // NextBillion._nextBillionChannel = mockMethodChannel;
  });

  // group('NextBillion', () {
  //   test('getNbId returns correct value', () async {
  //     when(mockMethodChannel.invokeMethod<String>('nextbillion/get_nb_id'))
  //         .thenAnswer((_) async => 'test_nb_id');
  //
  //     final result = await NextBillion.getNbId();
  //
  //     expect(result, 'test_nb_id');
  //     verify(mockMethodChannel.invokeMethod<String>('nextbillion/get_nb_id')).called(1);
  //   });
  //
  //   test('setUserId calls method with correct arguments', () async {
  //     const userId = 'test_user_id';
  //     final config = {"userId": userId};
  //
  //     await NextBillion.setUserId(userId);
  //
  //     verify(mockMethodChannel.invokeMethod<void>('nextbillion/set_user_id', config)).called(1);
  //   });
  //
  //   test('getUserId returns correct value', () async {
  //     when(mockMethodChannel.invokeMethod<String>('nextbillion/get_user_id'))
  //         .thenAnswer((_) async => 'test_user_id');
  //
  //     final result = await NextBillion.getUserId();
  //
  //     expect(result, 'test_user_id');
  //     verify(mockMethodChannel.invokeMethod<String>('nextbillion/get_user_id')).called(1);
  //   });
  //
  //   test('getNbId throws error on exception', () async {
  //     when(mockMethodChannel.invokeMethod<String>('nextbillion/get_nb_id'))
  //         .thenThrow(PlatformException(code: 'ERROR'));
  //
  //     expect(() => NextBillion.getNbId(), throwsA(isA<PlatformException>()));
  //   });
  //
  //   test('setUserId throws error on exception', () async {
  //     when(mockMethodChannel.invokeMethod<void>('nextbillion/set_user_id', any))
  //         .thenThrow(PlatformException(code: 'ERROR'));
  //
  //     expect(() => NextBillion.setUserId('test_user_id'), throwsA(isA<PlatformException>()));
  //   });
  //
  //   test('getUserId throws error on exception', () async {
  //     when(mockMethodChannel.invokeMethod<String>('nextbillion/get_user_id'))
  //         .thenThrow(PlatformException(code: 'ERROR'));
  //
  //     expect(() => NextBillion.getUserId(), throwsA(isA<PlatformException>()));
  //   });
  // });
}
