import 'package:flutter_test/flutter_test.dart';
import 'package:nb_maps_flutter/nb_maps_flutter.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

void main() {
  test('decode should return a list of LatLng points', () {
    // const encodedPath = 'mk{FcnsxRoMaBiGiAoF_AqB_@cEW{IsB[`CCxD';
    const encodedPath = '}u{FspsxRsLaB';
    const precision = 5;
    // const expectedPath = [
    //   LatLng(103.81554000000001, 1.2922300000000002),
    //   LatLng(103.81603000000001, 1.29455),
    //   LatLng(103.8164, 1.2958800000000001),
    //   LatLng(103.81672, 1.29708),
    //   LatLng(103.81688000000001, 1.2976500000000002),
    //   LatLng(103.81700000000001, 1.2986300000000002),
    //   LatLng(103.81758, 1.30037),
    //   LatLng(103.81693000000001, 1.30051),
    //   LatLng(103.816, 1.3005300000000002)
    // ];

    const expectedPath = [
      LatLng(1.29391, 103.81594),
      LatLng(1.29609, 103.81643)
    ];

    final result = decode(encodedPath, precision);

    // print('expectedPath: $expectedPath');
    // print('result: $result');

    expect(result, equals(expectedPath));
  });

  test('decode should handle empty encoded path', () {
    const encodedPath = '';
    const precision = 5;
    final expectedPath = [];

    final result = decode(encodedPath, precision);

    expect(result, equals(expectedPath));
  });
}
