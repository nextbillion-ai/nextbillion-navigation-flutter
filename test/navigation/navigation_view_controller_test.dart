import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

class MockNBNavigationViewPlatform extends Mock
    implements NBNavigationViewPlatform {
  @override
  Future<void> stopNavigation() {
    return super.noSuchMethod(
      Invocation.method(#stopNavigation, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>;
  }

  @override
  void dispose() {
    super.noSuchMethod(
      Invocation.method(#dispose, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    ) as Future<void>;
  }

  @override
  Stream<NavigationProgress?>? get navProgressListener {
    return super.noSuchMethod(
      Invocation.getter(
        #navProgressListener,
      ),
      returnValue: const Stream<NavigationProgress?>.empty(),
      returnValueForMissingStub: const Stream<NavigationProgress?>.empty(),
    ) as Stream<NavigationProgress?>?;
  }

  @override
  void setOnNavigationCancellingCallback(
      OnNavigationCancellingCallback? callback) {
    super.noSuchMethod(
      Invocation.method(
        #setOnNavigationCancellingCallback,
        [callback],
      ),
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
      returnValueForMissingStub: null,
    );
  }

  @override
  void setOnRerouteFromLocationCallback(
      OnRerouteFromLocationCallback? callback) {
    super.noSuchMethod(
      Invocation.method(
        #setOnRerouteFromLocationCallback,
        [callback],
      ),
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
    navigationController =
        NavigationViewController(navViewPlatform: mockNavViewPlatform);
  });

  tearDown(() async {
    await navigationController.dispose();
  });

  test('dispose should cancel subscription and stop navigation', () async {
    await navigationController.dispose();

    verify(mockNavViewPlatform.stopNavigation()).called(1);
    verify(mockNavViewPlatform.dispose()).called(1);
  });

  test('repeated disposal stops native navigation only once', () async {
    await Future.wait(
        [navigationController.dispose(), navigationController.dispose()]);

    verify(mockNavViewPlatform.stopNavigation()).called(1);
    verify(mockNavViewPlatform.dispose()).called(1);
  });

  test(
      'native teardown waits for stream cancellation and retains the channel until stopped',
      () async {
    final cancelled = Completer<void>();
    final stopped = Completer<void>();
    final stream =
        StreamController<NavigationProgress?>(onCancel: () => cancelled.future);
    final platform = MockNBNavigationViewPlatform();
    when(platform.navProgressListener).thenAnswer((_) => stream.stream);
    when(platform.stopNavigation()).thenAnswer((_) => stopped.future);
    final controller = NavigationViewController(navViewPlatform: platform);
    final done = controller.dispose();
    verifyNever(platform.stopNavigation());
    cancelled.complete();
    await Future<void>.delayed(Duration.zero);
    verify(platform.stopNavigation()).called(1);
    verifyNever(platform.dispose());
    stopped.complete();
    await done;
    verify(platform.dispose()).called(1);
    await stream.close();
  });

  test('Check callback should be called', () {
    final MockNBNavigationViewPlatform mockNBNavigationViewPlatform =
        MockNBNavigationViewPlatform();
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

    verify(mockNBNavigationViewPlatform.setOnNavigationCancellingCallback(any))
        .called(1);
    verify(mockNBNavigationViewPlatform.setOnArriveAtWaypointCallback(any))
        .called(1);
    verify(mockNBNavigationViewPlatform.setOnRerouteFromLocationCallback(any))
        .called(1);
    verify(mockNBNavigationViewPlatform.setOnRerouteAlongCallback(any))
        .called(1);
    verify(mockNBNavigationViewPlatform.setOnRerouteFailureCallback(any))
        .called(1);
    verify(mockNBNavigationViewPlatform.navProgressListener).called(1);
  });

  // Add more tests for other methods and functionalities
}
