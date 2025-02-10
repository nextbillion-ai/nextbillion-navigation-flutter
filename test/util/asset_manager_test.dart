import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nb_navigation_flutter/util/asset_manager.dart';

import 'asset_manager_test.mocks.dart';

@GenerateMocks([AssetBundle])
void main() {
  group('AssetManager', () {
    late AssetManager assetManager;
    late AssetBundle mockAssetBundle;

    setUp(() {
      mockAssetBundle = MockAssetBundle();
      assetManager = AssetManager();
      assetManager.setAssetBundle(mockAssetBundle);
    });

    test('load should return Uint8List', () async {
      const key = 'image.png';
      final bytes = ByteData(3);
      bytes.setUint8(0, 1);
      bytes.setUint8(1, 2);
      bytes.setUint8(2, 3);
      final expected = bytes.buffer.asUint8List();

      when(mockAssetBundle.load(key)).thenAnswer((_) async => bytes);

      final result = await assetManager.load(key);

      expect(result, equals(expected));
    });

    test('transferAssetImage should load asset from rootBundle', () async {
      const assetName = 'image.png';
      final bytes = ByteData(3);
      bytes.setUint8(0, 1);
      bytes.setUint8(1, 2);
      bytes.setUint8(2, 3);
      final expected = bytes.buffer.asUint8List();

      when(mockAssetBundle.load(assetName)).thenAnswer((_) async => bytes);

      final result = await assetManager.transferAssetImage(assetName);

      expect(result, equals(expected));
    });
  });
}
