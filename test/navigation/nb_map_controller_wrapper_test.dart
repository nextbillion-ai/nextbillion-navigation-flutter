import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nb_maps_flutter/nb_maps_flutter.dart';
import 'package:nb_navigation_flutter/navigation/nb_map_controller_wrapper.dart';

import 'nb_map_controller_wrapper_test.mocks.dart';

@GenerateMocks([NextbillionMapController])
void main() {
  late NextbillionMapControllerWrapper mapControllerWrapper;
  late NextbillionMapController mockController;

  setUp(() {
    mockController = MockNextbillionMapController();
    mapControllerWrapper = NextbillionMapControllerWrapper(mockController);
  });

  test('dispose should call dispose on the controller', () {
    mapControllerWrapper.dispose();

    verify(mockController.dispose()).called(1);
  });

  test('get disposed should return the value from the controller', () {
    when(mockController.disposed).thenReturn(true);

    expect(mapControllerWrapper.disposed, equals(true));
  });

  test('onFeatureTapped should call onFeatureTapped on the controller',
      () async {
    List<OnFeatureInteractionCallback> onFeatureInteractionCallbacks = [];

    when(mockController.onFeatureTapped)
        .thenAnswer((_) => onFeatureInteractionCallbacks);

    expect(mapControllerWrapper.onFeatureTapped,
        equals(onFeatureInteractionCallbacks));
  });

  test('resizeWebMap should call resizeWebMap on the controller', () async {
    mapControllerWrapper.resizeWebMap();

    verify(mockController.resizeWebMap()).called(1);
  });

  test('forceResizeWebMap should call forceResizeWebMap on the controller',
      () async {
    mapControllerWrapper.forceResizeWebMap();

    verify(mockController.forceResizeWebMap()).called(1);
  });

  test('animateCamera should call animateCamera on the controller', () async {
    final cameraUpdate = CameraUpdate.zoomTo(1.0);

    when(mockController.animateCamera(cameraUpdate))
        .thenAnswer((_) async => true);

    await mapControllerWrapper.animateCamera(cameraUpdate);

    verify(mockController.animateCamera(cameraUpdate)).called(1);
  });

  test('addGeoJsonSource should call addGeoJsonSource on the controller',
      () async {
    const sourceId = 'sourceId';
    const geoJson = <String, dynamic>{};

    await mapControllerWrapper.addGeoJsonSource(sourceId, geoJson);

    verify(mockController.addGeoJsonSource(sourceId, geoJson)).called(1);
  });

  test('setGeoJsonSource should call setGeoJsonSource on the controller',
      () async {
    const sourceId = 'sourceId';
    const geoJson = <String, dynamic>{};

    await mapControllerWrapper.setGeoJsonSource(sourceId, geoJson);

    verify(mockController.setGeoJsonSource(sourceId, geoJson)).called(1);
  });

  test('toScreenLocation should call toScreenLocation on the controller',
      () async {
    const latLng = LatLng(1.0, 2.0);
    const expectedPoint = Point(3.0, 4.0);

    when(mockController.toScreenLocation(latLng))
        .thenAnswer((_) async => expectedPoint);

    final result = await mapControllerWrapper.toScreenLocation(latLng);

    expect(result, equals(expectedPoint));
    verify(mockController.toScreenLocation(latLng)).called(1);
  });

  test(
      'toScreenLocationBatch should call toScreenLocationBatch on the controller',
      () async {
    const latLngs = [LatLng(1.0, 2.0), LatLng(3.0, 4.0)];
    const expectedPoints = [Point(5.0, 6.0), Point(7.0, 8.0)];

    when(mockController.toScreenLocationBatch(latLngs))
        .thenAnswer((_) async => expectedPoints);

    final result = await mapControllerWrapper.toScreenLocationBatch(latLngs);

    expect(result, equals(expectedPoints));
    verify(mockController.toScreenLocationBatch(latLngs)).called(1);
  });

  test('toLatLng should call toLatLng on the controller', () async {
    const screenLocation = Point(1.0, 2.0);
    const expectedLatLng = LatLng(3.0, 4.0);

    when(mockController.toLatLng(screenLocation))
        .thenAnswer((_) async => expectedLatLng);

    final result = await mapControllerWrapper.toLatLng(screenLocation);

    expect(result, equals(expectedLatLng));
    verify(mockController.toLatLng(screenLocation)).called(1);
  });

  test(
      'getMetersPerPixelAtLatitude should call getMetersPerPixelAtLatitude on the controller',
      () async {
    const latitude = 1.0;
    const expectedMetersPerPixel = 2.0;

    when(mockController.getMetersPerPixelAtLatitude(latitude))
        .thenAnswer((_) async => expectedMetersPerPixel);

    final result =
        await mapControllerWrapper.getMetersPerPixelAtLatitude(latitude);

    expect(result, equals(expectedMetersPerPixel));
    verify(mockController.getMetersPerPixelAtLatitude(latitude)).called(1);
  });

  test('addSource should call addSource on the controller', () async {
    const sourceId = 'sourceId';
    const properties = VectorSourceProperties();

    await mapControllerWrapper.addSource(sourceId, properties);

    verify(mockController.addSource(sourceId, properties)).called(1);
  });

  test('addLayer should call addLayer on the controller', () async {
    const sourceId = 'sourceId';
    const layerId = 'layerId';
    const properties = FillLayerProperties();
    const belowLayerId = 'belowLayerId';
    const enableInteraction = true;
    const sourceLayer = 'sourceLayer';
    const minzoom = 1.0;
    const maxzoom = 2.0;
    const filter = 'filter';

    await mapControllerWrapper.addLayer(
      sourceId,
      layerId,
      properties,
      belowLayerId: belowLayerId,
      enableInteraction: enableInteraction,
      sourceLayer: sourceLayer,
      minzoom: minzoom,
      maxzoom: maxzoom,
      filter: filter,
    );

    verify(mockController.addLayer(
      sourceId,
      layerId,
      properties,
      belowLayerId: belowLayerId,
      enableInteraction: enableInteraction,
      sourceLayer: sourceLayer,
      minzoom: minzoom,
      maxzoom: maxzoom,
      filter: filter,
    )).called(1);
  });

  test('takeSnapshot should call takeSnapshot on the controller', () async {
    final snapshotOptions = SnapshotOptions(width: 1.0, height: 2.0);
    const expectedSnapshot = 'snapshot';

    when(mockController.takeSnapshot(snapshotOptions))
        .thenAnswer((_) async => expectedSnapshot);

    final result = await mapControllerWrapper.takeSnapshot(snapshotOptions);

    expect(result, equals(expectedSnapshot));
    verify(mockController.takeSnapshot(snapshotOptions)).called(1);
  });

  test('findBelowLayerId should call findBelowLayerId on the controller',
      () async {
    final belowAt = ['layer1', 'layer2'];
    const expectedLayerId = 'layerId';

    when(mockController.findBelowLayerId(belowAt))
        .thenAnswer((_) async => expectedLayerId);

    final result = await mapControllerWrapper.findBelowLayerId(belowAt);

    expect(result, equals(expectedLayerId));
    verify(mockController.findBelowLayerId(belowAt)).called(1);
  });

  test('addImage should call addImage on the controller', () async {
    const name = 'name';
    final bytes = Uint8List(0);

    await mapControllerWrapper.addImage(name, bytes);

    verify(mockController.addImage(name, bytes)).called(1);
  });

  test('addSymbolLayer should call addSymbolLayer on the controller', () async {
    const sourceId = 'sourceId';
    const layerId = 'layerId';
    const properties = SymbolLayerProperties();

    await mapControllerWrapper.addSymbolLayer(sourceId, layerId, properties);

    verify(mockController.addSymbolLayer(sourceId, layerId, properties))
        .called(1);
  });

  test('addLineLayer should call addLineLayer on the controller', () async {
    const sourceId = 'sourceId';
    const layerId = 'layerId';
    const properties = LineLayerProperties();

    await mapControllerWrapper.addLineLayer(sourceId, layerId, properties);

    verify(mockController.addLineLayer(sourceId, layerId, properties))
        .called(1);
  });

  test('addCircleLayer should call addCircleLayer on the controller', () async {
    const sourceId = 'sourceId';
    const layerId = 'layerId';
    const properties = CircleLayerProperties();

    await mapControllerWrapper.addCircleLayer(sourceId, layerId, properties);

    verify(mockController.addCircleLayer(sourceId, layerId, properties))
        .called(1);
  });

  test('addFillLayer should call addFillLayer on the controller', () async {
    const sourceId = 'sourceId';
    const layerId = 'layerId';
    const properties = FillLayerProperties();

    await mapControllerWrapper.addFillLayer(sourceId, layerId, properties);

    verify(mockController.addFillLayer(sourceId, layerId, properties))
        .called(1);
  });

  test(
      'addFillExtrusionLayer should call addFillExtrusionLayer on the controller',
      () async {
    const sourceId = 'sourceId';
    const layerId = 'layerId';
    const properties = FillExtrusionLayerProperties();

    await mapControllerWrapper.addFillExtrusionLayer(
        sourceId, layerId, properties);

    verify(mockController.addFillExtrusionLayer(sourceId, layerId, properties))
        .called(1);
  });

  test('removeLayer should call removeLayer on the controller', () async {
    const layerId = 'layerId';

    await mapControllerWrapper.removeLayer(layerId);

    verify(mockController.removeLayer(layerId)).called(1);
  });

  test('removeSource should call removeSource on the controller', () async {
    const sourceId = 'sourceId';

    await mapControllerWrapper.removeSource(sourceId);

    verify(mockController.removeSource(sourceId)).called(1);
  });

  test('setFilter should call setFilter on the controller', () async {
    const layerId = 'layerId';
    const filter = ['==', 'name', 'value'];

    await mapControllerWrapper.setFilter(layerId, filter);

    verify(mockController.setFilter(layerId, filter)).called(1);
  });

  test(
      'setSymbolIconAllowOverlap should call setSymbolIconAllowOverlap on the controller',
      () async {
    const enable = true;
    await mapControllerWrapper.setSymbolIconAllowOverlap(enable);
    verify(mockController.setSymbolIconAllowOverlap(enable)).called(1);
  });

  test(
      'setSymbolIconIgnorePlacement should call setSymbolIconIgnorePlacement on the controller',
      () async {
    const enable = true;
    await mapControllerWrapper.setSymbolIconIgnorePlacement(enable);
    verify(mockController.setSymbolIconIgnorePlacement(enable)).called(1);
  });

  test(
      'setSymbolTextAllowOverlap should call setSymbolTextAllowOverlap on the controller',
      () async {
    const enable = true;
    await mapControllerWrapper.setSymbolTextAllowOverlap(enable);
    verify(mockController.setSymbolTextAllowOverlap(enable)).called(1);
  });

  test(
      'setSymbolTextIgnorePlacement should call setSymbolTextIgnorePlacement on the controller',
      () async {
    const enable = true;
    await mapControllerWrapper.setSymbolTextIgnorePlacement(enable);
    verify(mockController.setSymbolTextIgnorePlacement(enable)).called(1);
  });

  test('addImageSource should call addImageSource on the controller', () async {
    const sourceId = 'sourceId';

    Uint8List bytes = Uint8List(0);
    const LatLngQuad coordinates = LatLngQuad(
        topLeft: LatLng(1.0, 2.0),
        topRight: LatLng(3.0, 4.0),
        bottomRight: LatLng(5.0, 6.0),
        bottomLeft: LatLng(7.0, 8.0));
    await mapControllerWrapper.addImageSource(sourceId, bytes, coordinates);
    verify(mockController.addImageSource(sourceId, bytes, coordinates))
        .called(1);
  });

  test('updateImageSource should call updateImageSource on the controller',
      () async {
    const sourceId = 'sourceId';
    Uint8List bytes = Uint8List(0);
    const LatLngQuad coordinates = LatLngQuad(
        topLeft: LatLng(1.0, 2.0),
        topRight: LatLng(3.0, 4.0),
        bottomRight: LatLng(5.0, 6.0),
        bottomLeft: LatLng(7.0, 8.0));
    await mapControllerWrapper.updateImageSource(sourceId, bytes, coordinates);
    verify(mockController.updateImageSource(sourceId, bytes, coordinates))
        .called(1);
  });

  test('addRasterLayer should call addRasterLayer on the controller', () async {
    const sourceId = 'sourceId';
    const layerId = 'layerId';
    const RasterLayerProperties properties = RasterLayerProperties();
    await mapControllerWrapper.addRasterLayer(sourceId, layerId, properties);
    verify(mockController.addRasterLayer(sourceId, layerId, properties))
        .called(1);
  });

  test('addHillshadeLayer should call addHillshadeLayer on the controller',
      () async {
    const sourceId = 'sourceId';
    const layerId = 'layerId';
    const HillshadeLayerProperties properties = HillshadeLayerProperties();
    await mapControllerWrapper.addHillshadeLayer(sourceId, layerId, properties);
    verify(mockController.addHillshadeLayer(sourceId, layerId, properties))
        .called(1);
  });

  test('addHeatmapLayer should call addHeatmapLayer on the controller',
      () async {
    const sourceId = 'sourceId';
    const layerId = 'layerId';
    const HeatmapLayerProperties properties = HeatmapLayerProperties();
    await mapControllerWrapper.addHeatmapLayer(sourceId, layerId, properties);
    verify(mockController.addHeatmapLayer(sourceId, layerId, properties))
        .called(1);
  });

  test(
      'updateMyLocationTrackingMode should call updateMyLocationTrackingMode on the controller',
      () async {
    const mode = MyLocationTrackingMode.Tracking;
    await mapControllerWrapper.updateMyLocationTrackingMode(mode);
    verify(mockController.updateMyLocationTrackingMode(mode)).called(1);
  });

  test(
      'matchMapLanguageWithDeviceDefault should call matchMapLanguageWithDeviceDefault on the controller',
      () async {
    await mapControllerWrapper.matchMapLanguageWithDeviceDefault();
    verify(mockController.matchMapLanguageWithDeviceDefault()).called(1);
  });

  test('updateContentInsets should call updateContentInsets on the controller',
      () async {
    const insets = EdgeInsets.all(10.0);
    const animated = true;
    await mapControllerWrapper.updateContentInsets(insets, animated);
    verify(mockController.updateContentInsets(insets, animated)).called(1);
  });

  test('setMapLanguage should call setMapLanguage on the controller', () async {
    const language = 'en';
    await mapControllerWrapper.setMapLanguage(language);
    verify(mockController.setMapLanguage(language)).called(1);
  });

  test('setTelemetryEnabled should call setTelemetryEnabled on the controller',
      () async {
    const enabled = true;
    await mapControllerWrapper.setTelemetryEnabled(enabled);
    verify(mockController.setTelemetryEnabled(enabled)).called(1);
  });

  test('getTelemetryEnabled should call getTelemetryEnabled on the controller',
      () async {
    when(mockController.getTelemetryEnabled()).thenAnswer((_) async => true);
    await mapControllerWrapper.getTelemetryEnabled();
    verify(mockController.getTelemetryEnabled()).called(1);
  });

  test('addSymbol should call addSymbol on the controller', () async {
    const options = SymbolOptions();
    final Symbol symbol = Symbol('symbolId', options);
    when(mockController.addSymbol(options)).thenAnswer((_) async => symbol);

    Symbol? addedSymbol = await mapControllerWrapper.addSymbol(options);
    verify(mockController.addSymbol(options)).called(1);
    expect(addedSymbol, equals(symbol));
  });

  test('addSymbols should call addSymbols on the controller', () async {
    const option = SymbolOptions();
    const options = [option];
    final expectedSymbols = [Symbol('symbolId', option)];

    when(mockController.addSymbols(options))
        .thenAnswer((_) async => expectedSymbols);

    final addedSymbols = await mapControllerWrapper.addSymbols(options);
    verify(mockController.addSymbols(options)).called(1);
    expect(addedSymbols, equals(expectedSymbols));
  });

  test('updateSymbol should call updateSymbol on the controller', () async {
    const changes = SymbolOptions();
    final symbol = Symbol('symbolId', changes);
    await mapControllerWrapper.updateSymbol(symbol, changes);
    verify(mockController.updateSymbol(symbol, changes)).called(1);
  });

  test('getSymbolLatLng should call getSymbolLatLng on the controller',
      () async {
    const changes = SymbolOptions();
    final symbol = Symbol('symbolId', changes);
    LatLng expectedLatLng = const LatLng(1.0, 2.0);
    when(mockController.getSymbolLatLng(symbol))
        .thenAnswer((_) async => expectedLatLng);
    await mapControllerWrapper.getSymbolLatLng(symbol);
    verify(mockController.getSymbolLatLng(symbol)).called(1);
  });

  test('removeSymbol should call removeSymbol on the controller', () async {
    const changes = SymbolOptions();
    final symbol = Symbol('symbolId', changes);
    await mapControllerWrapper.removeSymbol(symbol);
    verify(mockController.removeSymbol(symbol)).called(1);
  });

  test('removeSymbols should call removeSymbols on the controller', () async {
    const changes = SymbolOptions();
    final symbol = Symbol('symbolId', changes);
    final symbols = [symbol];
    await mapControllerWrapper.removeSymbols(symbols);
    verify(mockController.removeSymbols(symbols)).called(1);
  });

  test('clearSymbols should call clearSymbols on the controller', () async {
    await mapControllerWrapper.clearSymbols();
    verify(mockController.clearSymbols()).called(1);
  });

  test('addLine should call addLine on the controller', () async {
    const options = LineOptions();
    Line expectedLine = Line('lineId', options);
    when(mockController.addLine(options)).thenAnswer((_) async => expectedLine);
    await mapControllerWrapper.addLine(options);
    verify(mockController.addLine(options)).called(1);
  });

  test('addLines should call addLines on the controller', () async {
    const options = [LineOptions()];
    List<Line> expectedLines = [];
    when(mockController.addLines(options))
        .thenAnswer((_) async => expectedLines);
    await mapControllerWrapper.addLines(options);
    verify(mockController.addLines(options)).called(1);
  });

  test('updateLine should call updateLine on the controller', () async {
    const changes = LineOptions();
    final line = Line('lineId', changes);

    await mapControllerWrapper.updateLine(line, changes);
    verify(mockController.updateLine(line, changes)).called(1);
  });

  test('getLineLatLngs should call getLineLatLngs on the controller', () async {
    const changes = LineOptions();
    final line = Line('lineId', changes);
    List<LatLng> expectedLatLngs = [];
    when(mockController.getLineLatLngs(line))
        .thenAnswer((_) async => expectedLatLngs);

    await mapControllerWrapper.getLineLatLngs(line);
    verify(mockController.getLineLatLngs(line)).called(1);
  });

  test('removeLine should call removeLine on the controller', () async {
    const changes = LineOptions();
    final line = Line('lineId', changes);
    await mapControllerWrapper.removeLine(line);
    verify(mockController.removeLine(line)).called(1);
  });

  test('removeLines should call removeLines on the controller', () async {
    const changes = LineOptions();
    final line = Line('lineId', changes);
    final lines = [line];
    await mapControllerWrapper.removeLines(lines);
    verify(mockController.removeLines(lines)).called(1);
  });

  test('clearLines should call clearLines on the controller', () async {
    await mapControllerWrapper.clearLines();
    verify(mockController.clearLines()).called(1);
  });

  test('addCircle should call addCircle on the controller', () async {
    const options = CircleOptions();
    Circle expectedCircle = Circle('circleId', options);
    when(mockController.addCircle(options))
        .thenAnswer((_) async => expectedCircle);

    await mapControllerWrapper.addCircle(options);
    verify(mockController.addCircle(options)).called(1);
  });

  test('addCircles should call addCircles on the controller', () async {
    const options = [CircleOptions()];
    List<Circle> expectedCircles = [];
    when(mockController.addCircles(options))
        .thenAnswer((_) async => expectedCircles);
    await mapControllerWrapper.addCircles(options);
    verify(mockController.addCircles(options)).called(1);
  });

  test('updateCircle should call updateCircle on the controller', () async {
    const changes = CircleOptions();
    final circle = Circle('circleId', changes);

    await mapControllerWrapper.updateCircle(circle, changes);
    verify(mockController.updateCircle(circle, changes)).called(1);
  });

  test('getCircleLatLng should call getCircleLatLng on the controller',
      () async {
    const changes = CircleOptions();
    final circle = Circle('circleId', changes);
    LatLng expectedLatLng = const LatLng(1.0, 2.0);
    when(mockController.getCircleLatLng(circle))
        .thenAnswer((_) async => expectedLatLng);
    await mapControllerWrapper.getCircleLatLng(circle);
    verify(mockController.getCircleLatLng(circle)).called(1);
  });

  test('removeCircle should call removeCircle on the controller', () async {
    const changes = CircleOptions();
    final circle = Circle('circleId', changes);
    await mapControllerWrapper.removeCircle(circle);
    verify(mockController.removeCircle(circle)).called(1);
  });

  test('removeCircles should call removeCircles on the controller', () async {
    const changes = CircleOptions();
    final circle = Circle('circleId', changes);
    final circles = [circle];
    await mapControllerWrapper.removeCircles(circles);
    verify(mockController.removeCircles(circles)).called(1);
  });

  test('clearCircles should call clearCircles on the controller', () async {
    await mapControllerWrapper.clearCircles();
    verify(mockController.clearCircles()).called(1);
  });

  test('addFill should call addFill on the controller', () async {
    const options = FillOptions();
    Fill expectedFill = Fill('fillId', options);
    when(mockController.addFill(options)).thenAnswer((_) async => expectedFill);
    await mapControllerWrapper.addFill(options);
    verify(mockController.addFill(options)).called(1);
  });

  test('addFills should call addFills on the controller', () async {
    const options = [FillOptions()];
    List<Fill> expectedFills = [];
    when(mockController.addFills(options))
        .thenAnswer((_) async => expectedFills);

    await mapControllerWrapper.addFills(options);
    verify(mockController.addFills(options)).called(1);
  });

  test('updateFill should call updateFill on the controller', () async {
    const changes = FillOptions();
    final fill = Fill('fillId', changes);

    await mapControllerWrapper.updateFill(fill, changes);
    verify(mockController.updateFill(fill, changes)).called(1);
  });

  test('clearFills should call clearFills on the controller', () async {
    await mapControllerWrapper.clearFills();
    verify(mockController.clearFills()).called(1);
  });

  test('removeFill should call removeFill on the controller', () async {
    const changes = FillOptions();
    final fill = Fill('fillId', changes);
    await mapControllerWrapper.removeFill(fill);
    verify(mockController.removeFill(fill)).called(1);
  });

  test('removeFills should call removeFills on the controller', () async {
    const changes = FillOptions();
    final fill = Fill('fillId', changes);
    final fills = [fill];
    await mapControllerWrapper.removeFills(fills);
    verify(mockController.removeFills(fills)).called(1);
  });

  test(
      'queryRenderedFeatures should call queryRenderedFeatures on the controller',
      () async {
    const Point<double> point = Point(1.0, 2.0);
    List<String> layerIds = ['layerId'];
    List<Object>? filter = ['==', 'name', 'value'];
    final expectedList = [];
    when(mockController.queryRenderedFeatures(point, layerIds, filter))
        .thenAnswer((_) async => expectedList);

    await mapControllerWrapper.queryRenderedFeatures(point, layerIds, filter);

    verify(mockController.queryRenderedFeatures(point, layerIds, filter))
        .called(1);
  });

  test(
      'queryRenderedFeaturesInRect should call queryRenderedFeaturesInRect on the controller',
      () async {
    const Rect rect = Rect.fromLTWH(1.0, 2.0, 3.0, 4.0);
    List<String> layerIds = ['layerId'];
    String? filter = 'filter';

    final expectedList = [];
    when(mockController.queryRenderedFeaturesInRect(rect, layerIds, filter))
        .thenAnswer((_) async => expectedList);

    await mapControllerWrapper.queryRenderedFeaturesInRect(
        rect, layerIds, filter);

    verify(mockController.queryRenderedFeaturesInRect(rect, layerIds, filter))
        .called(1);
  });

  test(
      'invalidateAmbientCache should call invalidateAmbientCache on the controller',
      () async {
    final expectedFuture = Future.value();
    when(mockController.invalidateAmbientCache())
        .thenAnswer((_) => expectedFuture);
    await mapControllerWrapper.invalidateAmbientCache();
    verify(mockController.invalidateAmbientCache()).called(1);
  });

  test(
      'requestMyLocationLatLng should call requestMyLocationLatLng on the controller',
      () async {
    const expectedLatLng = LatLng(1.0, 2.0);
    when(mockController.requestMyLocationLatLng())
        .thenAnswer((_) async => expectedLatLng);

    when(mockController.requestMyLocationLatLng())
        .thenAnswer((_) async => expectedLatLng);

    final actual = await mapControllerWrapper.requestMyLocationLatLng();
    verify(mockController.requestMyLocationLatLng()).called(1);

    expect(actual, equals(expectedLatLng));
  });

  test('getVisibleRegion should call getVisibleRegion on the controller',
      () async {
    final expectedLatLngBounds = LatLngBounds(
      southwest: const LatLng(1.0, 2.0),
      northeast: const LatLng(3.0, 4.0),
    );
    when(mockController.getVisibleRegion())
        .thenAnswer((_) async => expectedLatLngBounds);
    final actual = await mapControllerWrapper.getVisibleRegion();
    verify(mockController.getVisibleRegion()).called(1);
    expect(actual, equals(expectedLatLngBounds));
  });

  test('setStyleString should call setStyleString on the controller', () async {
    const styleString = 'style';
    await mapControllerWrapper.setStyleString(styleString);
    verify(mockController.setStyleString(styleString)).called(1);
  });

  test('setGeoJsonFeature should call setGeoJsonFeature on the controller',
      () async {
    const featureId = 'featureId';
    const feature = <String, dynamic>{};
    await mapControllerWrapper.setGeoJsonFeature(featureId, feature);
    verify(mockController.setGeoJsonFeature(featureId, feature)).called(1);
  });

  test('setVisibility should call setVisibility on the controller', () async {
    const layerId = 'layerId';
    const isVisible = true;
    await mapControllerWrapper.setVisibility(layerId, isVisible);
    verify(mockController.setVisibility(layerId, isVisible)).called(1);
  });

  test('addImageLayerBelow should call addImageLayerBelow on the controller',
      () async {
    const imageLayerId = 'imageLayerId';
    const imageSourceId = 'imageSourceId';
    const belowLayerId = 'belowLayerId';
    await mapControllerWrapper.addImageLayerBelow(
        imageLayerId, imageSourceId, belowLayerId);
    verify(mockController.addImageLayerBelow(
            imageLayerId, imageSourceId, belowLayerId))
        .called(1);
  });

  test('addImageLayer should call addImageLayer on the controller', () async {
    const imageLayerId = 'imageLayerId';
    const imageSourceId = 'imageSourceId';
    await mapControllerWrapper.addImageLayer(imageLayerId, imageSourceId);
    verify(mockController.addImageLayer(imageLayerId, imageSourceId)).called(1);
  });

  test('moveCamera should call moveCamera on the controller', () async {
    final cameraUpdate = CameraUpdate.zoomTo(1.0);
    when(mockController.moveCamera(cameraUpdate)).thenAnswer((_) async => true);
    await mapControllerWrapper.moveCamera(cameraUpdate);
    verify(mockController.moveCamera(cameraUpdate)).called(1);
  });
}
