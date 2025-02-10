import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

class MockNBNavigationViewPlatform extends Mock implements NBNavigationViewPlatform {
  @override
  Future<void> stopNavigation() async {
    (super.noSuchMethod(
      Invocation.method(
        #stopNavigation,[]
      ),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>);
  }
  @override
  void dispose() {
    (super.noSuchMethod(
      Invocation.method(
          #dispose,[]
      ),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>);
  }

  @override
  Stream<NavigationProgress?>? get navProgressListener {
    return super.noSuchMethod(
      Invocation.getter(
        #navProgressListener,
      ),
      returnValue: Stream<NavigationProgress?>.empty(),
      returnValueForMissingStub: Stream<NavigationProgress?>.empty(),
    ) as Stream<NavigationProgress?>?;
  }

  @override
  void setOnNavigationCancellingCallback(OnNavigationCancellingCallback? callback) {
    super.noSuchMethod(
      Invocation.method(
        #setOnNavigationCancellingCallback,
        [callback],
      ),
      returnValue: null,
      returnValueForMissingStub: null,
    );
  }

  @override
  void setOnNavigationRunningCallback(OnNavigationRunningCallback? callback) {
    super.noSuchMethod(
      Invocation.method(
        #setOnNavigationRunningCallback,
        [callback],
      ),
      returnValue: null,
      returnValueForMissingStub: null,
    );
  }
  @override
  void setOnArriveAtWaypointCallback(OnArriveAtWaypointCallback? callback) {
    super.noSuchMethod(
      Invocation.method(
        #setOnArriveAtWaypointCallback,
        [callback],
      ),
      returnValue: null,
      returnValueForMissingStub: null,
    );
  }

  @override
  void setOnRerouteFromLocationCallback(OnRerouteFromLocationCallback? callback) {
    super.noSuchMethod(
      Invocation.method(
        #setOnRerouteFromLocationCallback,
        [callback],
      ),
      returnValue: null,
      returnValueForMissingStub: null,
    );
  }

  @override
  void setOnRerouteAlongCallback(OnRerouteAlongCallback? callback) {
    super.noSuchMethod(
      Invocation.method(
        #setOnRerouteAlongCallback,
        [callback],
      ),
      returnValue: null,
      returnValueForMissingStub: null,
    );
  }

  @override
  void setOnRerouteFailureCallback(OnRerouteFailureCallback? callback) {
    super.noSuchMethod(
      Invocation.method(
        #setOnRerouteFailureCallback,
        [callback],
      ),
      returnValue: null,
      returnValueForMissingStub: null,
    );
  }
  @override
  Future<void> initPlatform(int id) {
    return super.noSuchMethod(
      Invocation.method(
        #initPlatform,
        [id],
      ),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>;
  }


}

void main() {
  late NavigationViewController navigationController;
  late MockNBNavigationViewPlatform mockNavViewPlatform;

  setUp(() {
    mockNavViewPlatform = MockNBNavigationViewPlatform();
    navigationController = NavigationViewController(navViewPlatform: mockNavViewPlatform);
  });

  tearDown(() {
    navigationController.dispose();
  });

  test('dispose should cancel subscription and stop navigation', () {
    navigationController.dispose();

    verify(mockNavViewPlatform.stopNavigation()).called(1);
    verify(mockNavViewPlatform.dispose()).called(1);
  });

  test('dispose should cancel subscription and stop navigation', () {
    navigationController.dispose();

    verify(mockNavViewPlatform.stopNavigation()).called(1);
    verify(mockNavViewPlatform.dispose()).called(1);
  });

  test('Check callback should be called', () {
    MockNBNavigationViewPlatform mockNBNavigationViewPlatform = MockNBNavigationViewPlatform();
    NavigationViewController(
      navViewPlatform: mockNBNavigationViewPlatform,
      onProgressChange: (progress) {
        expect(progress, isA<NavigationProgress>());
      },
      onNavigationCancelling: () {
        expect(true, true);
      },
      arriveAtWaypointCallback: (waypoint) {
        expect(waypoint, isA<Waypoint>());
      },
      onRerouteFromLocationCallback: (location) {
        expect(location, isA<LatLng>());
      },
      onRerouteAlongCallback: (route) {
        expect(route, isA<DirectionsRoute>());
      },
      onRerouteFailureCallback: (message) {
        expect(message, isA<String>());
      },
    );

    verify(mockNBNavigationViewPlatform.setOnNavigationCancellingCallback(any)).called(1);
    verify(mockNBNavigationViewPlatform.setOnArriveAtWaypointCallback(any)).called(1);
    verify(mockNBNavigationViewPlatform.setOnRerouteFromLocationCallback(any)).called(1);
    verify(mockNBNavigationViewPlatform.setOnRerouteAlongCallback(any)).called(1);
    verify(mockNBNavigationViewPlatform.setOnRerouteFailureCallback(any)).called(1);
    verify(mockNBNavigationViewPlatform.navProgressListener).called(1);
  });

  // Add more tests for other methods and functionalities
}