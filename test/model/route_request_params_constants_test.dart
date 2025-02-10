import 'package:flutter_test/flutter_test.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

void main() {
  test('SupportedUnits.fromValue should return SupportedUnits', () {
    expect(
        SupportedUnits.fromValue('imperial'), equals(SupportedUnits.imperial));
    expect(SupportedUnits.fromValue('metric'), equals(SupportedUnits.metric));
    expect(SupportedUnits.fromValue(null), equals(SupportedUnits.metric));
    expect(SupportedUnits.fromValue('invalid'), equals(SupportedUnits.metric));
  });

  test('ValidModes.fromValue should return ValidModes', () {
    expect(ValidModes.fromValue('car'), equals(ValidModes.car));
    expect(ValidModes.fromValue('truck'), equals(ValidModes.truck));
    expect(ValidModes.fromValue(null), equals(ValidModes.car));
    expect(ValidModes.fromValue('invalid'), equals(ValidModes.car));
  });

  test('SupportedAvoid.fromValue should return SupportedAvoid', () {
    expect(SupportedAvoid.fromValue('toll'), equals(SupportedAvoid.toll));
    expect(SupportedAvoid.fromValue('ferry'), equals(SupportedAvoid.ferry));
    expect(SupportedAvoid.fromValue('highway'), equals(SupportedAvoid.highway));
    expect(SupportedAvoid.fromValue('none'), equals(SupportedAvoid.none));
    expect(SupportedAvoid.fromValue(null), equals(SupportedAvoid.ferry));
    expect(SupportedAvoid.fromValue('invalid'), equals(SupportedAvoid.ferry));
    expect(SupportedAvoid.fromValue('uturn'), equals(SupportedAvoid.uTurn));
    expect(SupportedAvoid.fromValue('sharp_turn'),
        equals(SupportedAvoid.sharpTurn));
    expect(SupportedAvoid.fromValue('service_road'),
        equals(SupportedAvoid.serviceRoad));
  });

  test('ValidOverview.fromValue should return ValidOverview', () {
    expect(ValidOverview.fromValue('full'), equals(ValidOverview.full));
    expect(ValidOverview.fromValue('simplified'),
        equals(ValidOverview.simplified));
    expect(ValidOverview.fromValue('false'), equals(ValidOverview.none));
    expect(ValidOverview.fromValue(null), equals(ValidOverview.full));
    expect(ValidOverview.fromValue('invalid'), equals(ValidOverview.full));
  });

  test('SupportedGeometry.fromValue should return SupportedGeometry', () {
    expect(SupportedGeometry.fromValue('polyline'),
        equals(SupportedGeometry.polyline));
    expect(SupportedGeometry.fromValue('polyline6'),
        equals(SupportedGeometry.polyline6));
    expect(
        SupportedGeometry.fromValue(null), equals(SupportedGeometry.polyline6));
    expect(SupportedGeometry.fromValue('invalid'),
        equals(SupportedGeometry.polyline6));
  });

  test('SupportedOption.fromValue should return SupportedOption', () {
    expect(SupportedOption.fromValue('flexible'),
        equals(SupportedOption.flexible));
    expect(SupportedOption.fromValue(null), equals(SupportedOption.fast));
    expect(SupportedOption.fromValue('invalid'), equals(SupportedOption.fast));
  });

  test('SupportedHazmatType.fromValue should return SupportedHazmatType', () {
    expect(SupportedHazmatType.fromValue('general'),
        equals(SupportedHazmatType.general));
    expect(SupportedHazmatType.fromValue("circumstantial"),
        equals(SupportedHazmatType.circumstantial));
    expect(SupportedHazmatType.fromValue('explosive'),
        equals(SupportedHazmatType.explosive));
    expect(SupportedHazmatType.fromValue('harmful_to_water'),
        equals(SupportedHazmatType.harmfulToWater));
    expect(SupportedHazmatType.fromValue(null), equals(null));
  });

  test('SupportedApproaches.fromValue should return SupportedApproaches', () {
    expect(SupportedApproaches.fromValue('curb'),
        equals(SupportedApproaches.curb));
    expect(SupportedApproaches.fromValue('unrestricted'),
        equals(SupportedApproaches.unrestricted));
    expect(SupportedApproaches.fromValue(null), equals(null));
  });

  test('EnumExtension.description should return description', () {
    expect(ValidOverview.none.description, equals('false'));
    expect(ValidOverview.full.description, equals('full'));
    expect(ValidOverview.simplified.description, equals('simplified'));
    expect(SupportedHazmatType.harmfulToWater.description,
        equals('harmful_to_water'));
    expect(SupportedAvoid.uTurn.description, equals('uturn'));
    expect(SupportedAvoid.sharpTurn.description, equals('sharp_turn'));
    expect(SupportedAvoid.serviceRoad.description, equals('service_road'));
  });
}
