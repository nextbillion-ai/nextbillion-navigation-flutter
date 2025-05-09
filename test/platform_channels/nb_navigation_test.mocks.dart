// Mocks generated by Mockito 5.4.4 from annotations
// in nb_navigation_flutter/test/platform_channels/nb_navigation_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;
import 'dart:typed_data' as _i7;

import 'package:flutter/services.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i5;
import 'package:nb_maps_flutter/nb_maps_flutter.dart' as _i6;
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart' as _i2;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeDirectionsRouteResponse_0 extends _i1.SmartFake
    implements _i2.DirectionsRouteResponse {
  _FakeDirectionsRouteResponse_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeMethodCodec_1 extends _i1.SmartFake implements _i3.MethodCodec {
  _FakeMethodCodec_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeBinaryMessenger_2 extends _i1.SmartFake
    implements _i3.BinaryMessenger {
  _FakeBinaryMessenger_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [NBNavigationPlatform].
///
/// See the documentation for Mockito's code generation for more information.
class MockNBNavigationPlatform extends _i1.Mock
    implements _i2.NBNavigationPlatform {
  MockNBNavigationPlatform() {
    _i1.throwOnMissingStub(this);
  }

  @override
  set navigationExitCallback(
          _i2.OnNavigationExitCallback? _navigationExitCallback) =>
      super.noSuchMethod(
        Invocation.setter(
          #navigationExitCallback,
          _navigationExitCallback,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i4.Future<_i2.DirectionsRouteResponse> fetchRoute(
          _i2.RouteRequestParams? routeRequestParams) =>
      (super.noSuchMethod(
        Invocation.method(
          #fetchRoute,
          [routeRequestParams],
        ),
        returnValue: _i4.Future<_i2.DirectionsRouteResponse>.value(
            _FakeDirectionsRouteResponse_0(
          this,
          Invocation.method(
            #fetchRoute,
            [routeRequestParams],
          ),
        )),
      ) as _i4.Future<_i2.DirectionsRouteResponse>);

  @override
  _i4.Future<void> startNavigation(
          _i2.NavigationLauncherConfig? launcherConfig) =>
      (super.noSuchMethod(
        Invocation.method(
          #startNavigation,
          [launcherConfig],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> startPreviewNavigation(_i2.DirectionsRoute? route,
          {String? mapStyle}) =>
      (super.noSuchMethod(
        Invocation.method(
          #startPreviewNavigation,
          [route],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<String> getRoutingBaseUri() => (super.noSuchMethod(
        Invocation.method(
          #getRoutingBaseUri,
          [],
        ),
        returnValue: _i4.Future<String>.value(_i5.dummyValue<String>(
          this,
          Invocation.method(
            #getRoutingBaseUri,
            [],
          ),
        )),
      ) as _i4.Future<String>);

  @override
  _i4.Future<void> setRoutingBaseUri(String? baseUri) => (super.noSuchMethod(
        Invocation.method(
          #setRoutingBaseUri,
          [baseUri],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<int> findSelectedRouteIndex(
    _i6.LatLng? clickPoint,
    List<List<_i6.LatLng>>? coordinates,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #findSelectedRouteIndex,
          [
            clickPoint,
            coordinates,
          ],
        ),
        returnValue: _i4.Future<int>.value(0),
      ) as _i4.Future<int>);

  @override
  _i4.Future<String> getFormattedDuration(num? durationSeconds) =>
      (super.noSuchMethod(
        Invocation.method(
          #getFormattedDuration,
          [durationSeconds],
        ),
        returnValue: _i4.Future<String>.value(_i5.dummyValue<String>(
          this,
          Invocation.method(
            #getFormattedDuration,
            [durationSeconds],
          ),
        )),
      ) as _i4.Future<String>);

  @override
  _i4.Future<void> setOnNavigationExitCallback(
          _i2.OnNavigationExitCallback? navigationExitCallback) =>
      (super.noSuchMethod(
        Invocation.method(
          #setOnNavigationExitCallback,
          [navigationExitCallback],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<_i7.Uint8List?> captureRouteDurationSymbol(
    _i2.DirectionsRoute? route,
    bool? isPrimaryRoute,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #captureRouteDurationSymbol,
          [
            route,
            isPrimaryRoute,
          ],
        ),
        returnValue: _i4.Future<_i7.Uint8List?>.value(),
      ) as _i4.Future<_i7.Uint8List?>);

  @override
  _i4.Future<_i7.Uint8List?> captureRouteWaypoints(int? waypointIndex) =>
      (super.noSuchMethod(
        Invocation.method(
          #captureRouteWaypoints,
          [waypointIndex],
        ),
        returnValue: _i4.Future<_i7.Uint8List?>.value(),
      ) as _i4.Future<_i7.Uint8List?>);
}

/// A class which mocks [MethodChannel].
///
/// See the documentation for Mockito's code generation for more information.
class MockMethodChannel extends _i1.Mock implements _i3.MethodChannel {
  MockMethodChannel() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get name => (super.noSuchMethod(
        Invocation.getter(#name),
        returnValue: _i5.dummyValue<String>(
          this,
          Invocation.getter(#name),
        ),
      ) as String);

  @override
  _i3.MethodCodec get codec => (super.noSuchMethod(
        Invocation.getter(#codec),
        returnValue: _FakeMethodCodec_1(
          this,
          Invocation.getter(#codec),
        ),
      ) as _i3.MethodCodec);

  @override
  _i3.BinaryMessenger get binaryMessenger => (super.noSuchMethod(
        Invocation.getter(#binaryMessenger),
        returnValue: _FakeBinaryMessenger_2(
          this,
          Invocation.getter(#binaryMessenger),
        ),
      ) as _i3.BinaryMessenger);

  @override
  _i4.Future<T?> invokeMethod<T>(
    String? method, [
    dynamic arguments,
  ]) =>
      (super.noSuchMethod(
        Invocation.method(
          #invokeMethod,
          [
            method,
            arguments,
          ],
        ),
        returnValue: _i4.Future<T?>.value(),
      ) as _i4.Future<T?>);

  @override
  _i4.Future<List<T>?> invokeListMethod<T>(
    String? method, [
    dynamic arguments,
  ]) =>
      (super.noSuchMethod(
        Invocation.method(
          #invokeListMethod,
          [
            method,
            arguments,
          ],
        ),
        returnValue: _i4.Future<List<T>?>.value(),
      ) as _i4.Future<List<T>?>);

  @override
  _i4.Future<Map<K, V>?> invokeMapMethod<K, V>(
    String? method, [
    dynamic arguments,
  ]) =>
      (super.noSuchMethod(
        Invocation.method(
          #invokeMapMethod,
          [
            method,
            arguments,
          ],
        ),
        returnValue: _i4.Future<Map<K, V>?>.value(),
      ) as _i4.Future<Map<K, V>?>);

  @override
  void setMethodCallHandler(
          _i4.Future<dynamic> Function(_i3.MethodCall)? handler) =>
      super.noSuchMethod(
        Invocation.method(
          #setMethodCallHandler,
          [handler],
        ),
        returnValueForMissingStub: null,
      );
}
