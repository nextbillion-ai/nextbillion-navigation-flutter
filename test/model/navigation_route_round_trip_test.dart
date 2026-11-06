import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

void main() {
  test('native lane banners, images and fractional bearings survive launching',
      () {
    // Use JSON text to exercise the actual runtime types received from native.
    final input = jsonDecode('''
    {
      "routeOptions":{"origin":[-80.84,35.22],"destination":[-80.83,35.23]},
      "geometry":"encoded", "_nbFlutterGuidanceReady":true,
      "legs":[{"steps":[{
        "intersections":[{"bearings":[0.5,90.25,180.75],
          "entry":[true,true,true],"intersection_in":1,"intersection_out":2}],
        "bannerInstructions":[{"primary":{"type":"turn","components":[
          {"type":"icon","imageURL":"https://example.test/sign@3x.png?key=a",
           "label":"A1","abbr_priority":2}
        ]},"sub":{"components":[
          {"type":"lane","directions":["left","straight"],"active":true}
        ]}}]
      }]}]
    }''') as Map<String, dynamic>;
    final route = DirectionsRoute.fromJson(input);
    final config = NavigationLauncherConfig(route: route, routes: [route]);
    final output = jsonDecode(config.toJson()['route'] as String) as Map;
    final leg = (output['legs'] as List).single as Map;
    final step = (leg['steps'] as List).single as Map;
    final intersection = (step['intersections'] as List).single as Map;
    expect(intersection['bearings'], [0.5, 90.25, 180.75]);
    expect(intersection['intersection_in'], 1);
    expect(intersection['intersection_out'], 2);
    final banner = (step['bannerInstructions'] as List).single as Map;
    final lane = ((banner['sub'] as Map)['components'] as List).single as Map;
    final image =
        ((banner['primary'] as Map)['components'] as List).single as Map;
    expect(lane['directions'], ['left', 'straight']);
    expect(image['imageURL'], 'https://example.test/sign@3x.png?key=a');
    expect(image['abbr_priority'], 2);
    expect(image['label'], 'A1');
  });

  test('legacy intersection keys migrate without inventing a missing exit', () {
    final intersection = Intersection.fromJson({
      'bearings': [0, 90, 180],
      'in': 1,
      'out': 2
    });
    expect(intersection.toJson()['intersection_out'], 2);
    intersection.bearings = [];
    expect(intersection.toJson()['intersection_in'], -1);
    expect(intersection.toJson()['intersection_out'], -1);
    expect(Intersection.fromJson({}).toJson()['intersection_out'], -1);
  });

  test('older image and abbreviation aliases remain readable', () {
    final component = Component.fromJson({
      'image_url': 'https://example.test/shield.png',
      'abbreviation_priority': 2,
    });
    expect(component.toJson()['imageURL'], 'https://example.test/shield.png');
    expect(component.toJson()['abbr_priority'], 2);
  });
}
