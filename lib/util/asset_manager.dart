// This class is used to load assets from the asset bundle
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

abstract class IAssetManager {
  // Load an asset from the asset bundle
  Future<Uint8List> load(String key);
}

class AssetManager implements IAssetManager {
  AssetBundle _localRootBundle = rootBundle;

  AssetBundle get localRootBundle => _localRootBundle;

  @visibleForTesting
  void setLocalRootBundleForTesting(AssetBundle rootBundle) {
    assert(() {
      _localRootBundle = rootBundle;
      return true;
    }(), 'setLocalRootBundleForTesting should only be used in tests.');
  }


  @override
  Future<Uint8List> load(String key) {
    return transferAssetImage(key);
  }

  Future<Uint8List> transferAssetImage(String assetName) async {
    final ByteData bytes = await _localRootBundle.load(assetName);
    final Uint8List list = bytes.buffer.asUint8List();
    return list;
  }
}
