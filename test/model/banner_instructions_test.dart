import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

class MockComponent extends Mock implements Component {}

void main() {
  group('BannerInstructions', () {
    test('fromJson should return a valid BannerInstructions instance', () {
      final map = {
        'distanceAlongGeometry': 10.0,
        'primary': {
          'components': [
            {'countryCode': 'US', 'text': 'Component 1'}
          ],
          'degrees': 90,
          'instruction': 'Instruction 1',
          'modifier': 'Modifier 1',
          'text': 'Text 1',
          'type': 'Type 1',
          'driving_side': 'left',
        },
        'sub': {
          'components': [
            {'countryCode': 'US', 'text': 'Component 2'}
          ],
          'degrees': 180,
          'instruction': 'Instruction 2',
          'modifier': 'Modifier 2',
          'text': 'Text 2',
          'type': 'Type 2',
          'driving_side': 'right',
        },
        'secondary': {
          'components': [
            {'countryCode': 'US', 'text': 'Component 3'}
          ],
          'degrees': 270,
          'instruction': 'Instruction 3',
          'modifier': 'Modifier 3',
          'text': 'Text 3',
          'type': 'Type 3',
          'driving_side': 'left',
        },
      };

      final bannerInstructions = BannerInstructions.fromJson(map);

      expect(bannerInstructions.distanceAlongGeometry, equals(10.0));
      expect(bannerInstructions.primary, isNotNull);
      expect(bannerInstructions.primary!.components, isNotEmpty);
      expect(bannerInstructions.sub, isNotNull);
      expect(bannerInstructions.sub!.components, isNotEmpty);
      expect(bannerInstructions.secondary, isNotNull);
      expect(bannerInstructions.secondary!.components, isNotEmpty);
    });

    test('toJson should return a valid JSON map', () {
      final bannerInstructions = BannerInstructions(
        distanceAlongGeometry: 10.0,
        primary: Primary(
          components: [Component(countryCode: 'US', text: 'Component 1')],
          degrees: 90,
          instruction: 'Instruction 1',
          modifier: 'Modifier 1',
          text: 'Text 1',
          type: 'Type 1',
          drivingSide: 'left',
        ),
        sub: Primary(
          components: [Component(countryCode: 'US', text: 'Component 2')],
          degrees: 180,
          instruction: 'Instruction 2',
          modifier: 'Modifier 2',
          text: 'Text 2',
          type: 'Type 2',
          drivingSide: 'right',
        ),
        secondary: Primary(
          components: [Component(countryCode: 'US', text: 'Component 3')],
          degrees: 270,
          instruction: 'Instruction 3',
          modifier: 'Modifier 3',
          text: 'Text 3',
          type: 'Type 3',
          drivingSide: 'left',
        ),
      );

      final json = bannerInstructions.toJson();

      expect(json['distanceAlongGeometry'], equals(10.0));
      expect(json['primary'], isNotNull);
      expect(json['primary']['components'], isNotEmpty);
      expect(json['sub'], isNotNull);
      expect(json['sub']['components'], isNotEmpty);
      expect(json['secondary'], isNotNull);
      expect(json['secondary']['components'], isNotEmpty);
    });
  });

  group('Primary', () {
    test('fromJson should return a valid Primary instance', () {
      final map = {
        'components': [
          {'countryCode': 'US', 'text': 'Component 1'}
        ],
        'degrees': 90,
        'instruction': 'Instruction 1',
        'modifier': 'Modifier 1',
        'text': 'Text 1',
        'type': 'Type 1',
        'driving_side': 'left',
      };

      final primary = Primary.fromJson(map);

      expect(primary.components, isNotEmpty);
      expect(primary.degrees, equals(90));
      expect(primary.instruction, equals('Instruction 1'));
      expect(primary.modifier, equals('Modifier 1'));
      expect(primary.text, equals('Text 1'));
      expect(primary.type, equals('Type 1'));
      expect(primary.drivingSide, equals('left'));
    });

    test('toJson should return a valid JSON map', () {
      final primary = Primary(
        components: [Component(countryCode: 'US', text: 'Component 1')],
        degrees: 90,
        instruction: 'Instruction 1',
        modifier: 'Modifier 1',
        text: 'Text 1',
        type: 'Type 1',
        drivingSide: 'left',
      );

      final json = primary.toJson();

      expect(json['components'], isNotEmpty);
      expect(json['degrees'], equals(90));
      expect(json['instruction'], equals('Instruction 1'));
      expect(json['modifier'], equals('Modifier 1'));
      expect(json['text'], equals('Text 1'));
      expect(json['type'], equals('Type 1'));
      expect(json['driving_side'], equals('left'));
    });
  });

  group('Component', () {
    test('fromJson should return a valid Component instance', () {
      final map = {
        'countryCode': 'US',
        'text': 'Component 1',
        'type': 'Type 1',
        'subType': 'SubType 1',
        'abbr': 'Abbr 1',
        'abbr_priority': 1,
        'imageBaseURL': 'Image Base URL 1',
        'imageURL': 'Image URL 1',
        'directions': ['Direction 1'],
        'active': true,
        'reference': 'Reference 1',
      };

      final component = Component.fromJson(map);

      expect(component.countryCode, equals('US'));
      expect(component.text, equals('Component 1'));
      expect(component.type, equals('Type 1'));
      expect(component.subType, equals('SubType 1'));
      expect(component.abbreviation, equals('Abbr 1'));
      expect(component.abbreviationPriority, equals(1));
      expect(component.imageBaseUrl, equals('Image Base URL 1'));
      expect(component.imageUrl, equals('Image URL 1'));
      expect(component.directions, isNotEmpty);
      expect(component.active, equals(true));
      expect(component.reference, equals('Reference 1'));
    });

    test('toJson should return a valid JSON map', () {
      final component = Component(
        countryCode: 'US',
        text: 'Component 1',
        type: 'Type 1',
        subType: 'SubType 1',
        abbreviation: 'Abbr 1',
        abbreviationPriority: 1,
        imageBaseUrl: 'Image Base URL 1',
        imageUrl: 'Image URL 1',
        directions: ['Direction 1'],
        active: true,
        reference: 'Reference 1',
      );

      final json = component.toJson();

      expect(json['countryCode'], equals('US'));
      expect(json['text'], equals('Component 1'));
      expect(json['type'], equals('Type 1'));
      expect(json['subType'], equals('SubType 1'));
      expect(json['abbr'], equals('Abbr 1'));
      expect(json['abbr_priority'], equals(1));
      expect(json['imageBaseURL'], equals('Image Base URL 1'));
      expect(json['imageURL'], equals('Image URL 1'));
      expect(json['directions'], isNotEmpty);
      expect(json['active'], equals(true));
      expect(json['reference'], equals('Reference 1'));
    });
  });
}
