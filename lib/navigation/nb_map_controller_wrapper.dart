import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:nb_maps_flutter/nb_maps_flutter.dart';

abstract class MapController {
  bool get disposed;

  List<OnFeatureInteractionCallback> get onFeatureTapped;

  void resizeWebMap();

  void forceResizeWebMap();

  Future<bool?> animateCamera(CameraUpdate cameraUpdate, {Duration? duration});

  Future<bool?> moveCamera(CameraUpdate cameraUpdate);

  Future<void> addGeoJsonSource(String sourceId, Map<String, dynamic> geojson,
      {String? promoteId});

  Future<void> setGeoJsonSource(String sourceId, Map<String, dynamic> geojson);

  Future<void> setGeoJsonFeature(
      String sourceId, Map<String, dynamic> geojsonFeature);

  Future<void> addSymbolLayer(
      String sourceId, String layerId, SymbolLayerProperties properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom,
      dynamic filter,
      bool enableInteraction = true});

  Future<void> addLineLayer(
      String sourceId, String layerId, LineLayerProperties properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom,
      dynamic filter,
      bool enableInteraction = true});

  Future<void> addFillLayer(
      String sourceId, String layerId, FillLayerProperties properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom,
      dynamic filter,
      bool enableInteraction = true});

  Future<void> addFillExtrusionLayer(
      String sourceId, String layerId, FillExtrusionLayerProperties properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom,
      dynamic filter,
      bool enableInteraction = true});

  Future<void> addCircleLayer(
      String sourceId, String layerId, CircleLayerProperties properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom,
      dynamic filter,
      bool enableInteraction = true});

  Future<void> addRasterLayer(
      String sourceId, String layerId, RasterLayerProperties properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom});

  Future<void> addHillshadeLayer(
      String sourceId, String layerId, HillshadeLayerProperties properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom});

  Future<void> addHeatmapLayer(
      String sourceId, String layerId, HeatmapLayerProperties properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom});

  Future<void> updateMyLocationTrackingMode(
      MyLocationTrackingMode myLocationTrackingMode);

  Future<void> matchMapLanguageWithDeviceDefault();

  Future<void> updateContentInsets(EdgeInsets insets, [bool animated = false]);

  Future<void> setMapLanguage(String language);

  Future<void> setTelemetryEnabled(bool enabled);

  Future<bool> getTelemetryEnabled();

  Future<Symbol?> addSymbol(SymbolOptions options, [Map? data]);

  Future<List<Symbol>?> addSymbols(List<SymbolOptions> options,
      [List<Map>? data]);

  Future<void> updateSymbol(Symbol symbol, SymbolOptions changes);

  Future<LatLng?> getSymbolLatLng(Symbol symbol);

  Future<void> removeSymbol(Symbol symbol);

  Future<void> removeSymbols(Iterable<Symbol> symbols);

  Future<void> clearSymbols();

  Future<Line?> addLine(LineOptions options, [Map? data]);

  Future<List<Line>?> addLines(List<LineOptions> options, [List<Map>? data]);

  Future<void> updateLine(Line line, LineOptions changes);

  Future<List<LatLng>?> getLineLatLngs(Line line);

  Future<void> removeLine(Line line);

  Future<void> removeLines(Iterable<Line> lines);

  Future<void> clearLines();

  Future<Circle?> addCircle(CircleOptions options, [Map? data]);

  Future<List<Circle>?> addCircles(List<CircleOptions> options,
      [List<Map>? data]);

  Future<void> updateCircle(Circle circle, CircleOptions changes);

  Future<LatLng?> getCircleLatLng(Circle circle);

  Future<void> removeCircle(Circle circle);

  Future<void> removeCircles(Iterable<Circle> circles);

  Future<void> clearCircles();

  Future<Fill?> addFill(FillOptions options, [Map? data]);

  Future<List<Fill>?> addFills(List<FillOptions> options, [List<Map>? data]);

  Future<void> updateFill(Fill fill, FillOptions changes);

  Future<void> clearFills();

  Future<void> removeFill(Fill fill);

  Future<void> removeFills(Iterable<Fill> fills);

  Future<List?> queryRenderedFeatures(
      Point<double> point, List<String> layerIds, List<Object>? filter);

  Future<List?> queryRenderedFeaturesInRect(
      Rect rect, List<String> layerIds, String? filter);

  Future invalidateAmbientCache();

  Future<LatLng?> requestMyLocationLatLng();

  Future<LatLngBounds?> getVisibleRegion();

  Future<void> setStyleString(String styleString);

  Future<void> addImage(String name, Uint8List bytes, [bool sdf = false]);

  Future<void> setSymbolIconAllowOverlap(bool enable);

  Future<void> setSymbolIconIgnorePlacement(bool enable);

  Future<void> setSymbolTextAllowOverlap(bool enable);

  Future<void> setSymbolTextIgnorePlacement(bool enable);

  Future<void> addImageSource(
      String imageSourceId, Uint8List bytes, LatLngQuad coordinates);

  Future<void> updateImageSource(
      String imageSourceId, Uint8List? bytes, LatLngQuad? coordinates);

  Future<void> removeSource(String sourceId);

  Future<void> addImageLayer(String layerId, String imageSourceId,
      {double? minzoom, double? maxzoom});

  Future<void> addImageLayerBelow(
      String layerId, String sourceId, String imageSourceId,
      {double? minzoom, double? maxzoom});

  Future<void> removeLayer(String layerId);

  Future<void> setFilter(String layerId, dynamic filter);

  Future<void> setVisibility(String layerId, bool isVisible);

  Future<Point?> toScreenLocation(LatLng latLng);
  Future<List<Point>?> toScreenLocationBatch(Iterable<LatLng> latLngs);
  Future<LatLng?> toLatLng(Point screenLocation);
  Future<double?> getMetersPerPixelAtLatitude(double latitude);
  Future<void> addSource(String sourceid, SourceProperties properties);
  Future<void> addLayer(
      String sourceId, String layerId, LayerProperties properties,
      {String? belowLayerId,
      bool enableInteraction = true,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom,
      dynamic filter});
  Future<String?> takeSnapshot(SnapshotOptions snapshotOptions);
  Future<String?> findBelowLayerId(List<String> belowAt);
  void dispose();
}

class NextbillionMapControllerWrapper extends MapController {
  final NextbillionMapController _controller;

  NextbillionMapControllerWrapper(this._controller);

  @override
  bool get disposed => _controller.disposed;

  @override
  List<OnFeatureInteractionCallback> get onFeatureTapped =>
      _controller.onFeatureTapped;

  @override
  void resizeWebMap() {
    _controller.resizeWebMap();
  }

  @override
  void forceResizeWebMap() {
    _controller.forceResizeWebMap();
  }

  @override
  Future<bool?> animateCamera(CameraUpdate cameraUpdate, {Duration? duration}) {
    return _controller.animateCamera(cameraUpdate, duration: duration);
  }

  @override
  Future<bool?> moveCamera(CameraUpdate cameraUpdate) {
    return _controller.moveCamera(cameraUpdate);
  }

  @override
  Future<void> addGeoJsonSource(String sourceId, Map<String, dynamic> geojson,
      {String? promoteId}) {
    return _controller.addGeoJsonSource(sourceId, geojson,
        promoteId: promoteId);
  }

  @override
  Future<void> setGeoJsonSource(String sourceId, Map<String, dynamic> geojson) {
    return _controller.setGeoJsonSource(sourceId, geojson);
  }

  @override
  Future<void> setGeoJsonFeature(
      String sourceId, Map<String, dynamic> geojsonFeature) {
    return _controller.setGeoJsonFeature(sourceId, geojsonFeature);
  }

  @override
  Future<void> addSymbolLayer(
      String sourceId, String layerId, SymbolLayerProperties properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom,
      dynamic filter,
      bool enableInteraction = true}) {
    return _controller.addSymbolLayer(sourceId, layerId, properties,
        belowLayerId: belowLayerId,
        sourceLayer: sourceLayer,
        minzoom: minzoom,
        maxzoom: maxzoom,
        filter: filter);
  }

  @override
  Future<void> addLineLayer(
      String sourceId, String layerId, LineLayerProperties properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom,
      dynamic filter,
      bool enableInteraction = true}) {
    return _controller.addLineLayer(sourceId, layerId, properties,
        belowLayerId: belowLayerId,
        sourceLayer: sourceLayer,
        minzoom: minzoom,
        maxzoom: maxzoom,
        filter: filter);
  }

  @override
  Future<void> addFillLayer(
      String sourceId, String layerId, FillLayerProperties properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom,
      dynamic filter,
      bool enableInteraction = true}) {
    return _controller.addFillLayer(sourceId, layerId, properties,
        belowLayerId: belowLayerId,
        sourceLayer: sourceLayer,
        minzoom: minzoom,
        maxzoom: maxzoom,
        filter: filter);
  }

  @override
  Future<void> addFillExtrusionLayer(
      String sourceId, String layerId, FillExtrusionLayerProperties properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom,
      dynamic filter,
      bool enableInteraction = true}) {
    return _controller.addFillExtrusionLayer(sourceId, layerId, properties,
        belowLayerId: belowLayerId,
        sourceLayer: sourceLayer,
        minzoom: minzoom,
        maxzoom: maxzoom,
        filter: filter);
  }

  @override
  Future<void> addCircleLayer(
      String sourceId, String layerId, CircleLayerProperties properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom,
      dynamic filter,
      bool enableInteraction = true}) {
    return _controller.addCircleLayer(sourceId, layerId, properties,
        belowLayerId: belowLayerId,
        sourceLayer: sourceLayer,
        minzoom: minzoom,
        maxzoom: maxzoom,
        filter: filter);
  }

  @override
  Future<void> addRasterLayer(
      String sourceId, String layerId, RasterLayerProperties properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom}) {
    return _controller.addRasterLayer(sourceId, layerId, properties,
        belowLayerId: belowLayerId,
        sourceLayer: sourceLayer,
        minzoom: minzoom,
        maxzoom: maxzoom);
  }

  @override
  Future<void> addHillshadeLayer(
      String sourceId, String layerId, HillshadeLayerProperties properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom}) {
    return _controller.addHillshadeLayer(sourceId, layerId, properties,
        belowLayerId: belowLayerId,
        sourceLayer: sourceLayer,
        minzoom: minzoom,
        maxzoom: maxzoom);
  }

  @override
  Future<void> addHeatmapLayer(
      String sourceId, String layerId, HeatmapLayerProperties properties,
      {String? belowLayerId,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom}) {
    return _controller.addHeatmapLayer(sourceId, layerId, properties,
        belowLayerId: belowLayerId,
        sourceLayer: sourceLayer,
        minzoom: minzoom,
        maxzoom: maxzoom);
  }

  @override
  Future<void> updateMyLocationTrackingMode(
      MyLocationTrackingMode myLocationTrackingMode) {
    return _controller.updateMyLocationTrackingMode(myLocationTrackingMode);
  }

  @override
  Future<void> matchMapLanguageWithDeviceDefault() {
    return _controller.matchMapLanguageWithDeviceDefault();
  }

  @override
  Future<void> updateContentInsets(EdgeInsets insets, [bool animated = false]) {
    return _controller.updateContentInsets(insets, animated);
  }

  @override
  Future<void> setMapLanguage(String language) {
    return _controller.setMapLanguage(language);
  }

  @override
  Future<void> setTelemetryEnabled(bool enabled) {
    return _controller.setTelemetryEnabled(enabled);
  }

  @override
  Future<bool> getTelemetryEnabled() {
    return _controller.getTelemetryEnabled();
  }

  @override
  Future<Symbol?> addSymbol(SymbolOptions options, [Map? data]) {
    return _controller.addSymbol(options, data);
  }

  @override
  Future<List<Symbol>?> addSymbols(List<SymbolOptions> options,
      [List<Map>? data]) {
    return _controller.addSymbols(options, data);
  }

  @override
  Future<void> updateSymbol(Symbol symbol, SymbolOptions changes) {
    return _controller.updateSymbol(symbol, changes);
  }

  @override
  Future<LatLng?> getSymbolLatLng(Symbol symbol) {
    return _controller.getSymbolLatLng(symbol);
  }

  @override
  Future<void> removeSymbol(Symbol symbol) {
    return _controller.removeSymbol(symbol);
  }

  @override
  Future<void> removeSymbols(Iterable<Symbol> symbols) {
    return _controller.removeSymbols(symbols);
  }

  @override
  Future<void> clearSymbols() {
    return _controller.clearSymbols();
  }

  @override
  Future<Line?> addLine(LineOptions options, [Map? data]) {
    return _controller.addLine(options, data);
  }

  @override
  Future<List<Line>?> addLines(List<LineOptions> options, [List<Map>? data]) {
    return _controller.addLines(options, data);
  }

  @override
  Future<void> updateLine(Line line, LineOptions changes) {
    return _controller.updateLine(line, changes);
  }

  @override
  Future<List<LatLng>?> getLineLatLngs(Line line) {
    return _controller.getLineLatLngs(line);
  }

  @override
  Future<void> removeLine(Line line) {
    return _controller.removeLine(line);
  }

  @override
  Future<void> removeLines(Iterable<Line> lines) {
    return _controller.removeLines(lines);
  }

  @override
  Future<void> clearLines() {
    return _controller.clearLines();
  }

  @override
  Future<Circle?> addCircle(CircleOptions options, [Map? data]) {
    return _controller.addCircle(options, data);
  }

  @override
  Future<List<Circle>?> addCircles(List<CircleOptions> options,
      [List<Map>? data]) {
    return _controller.addCircles(options, data);
  }

  @override
  Future<void> updateCircle(Circle circle, CircleOptions changes) {
    return _controller.updateCircle(circle, changes);
  }

  @override
  Future<LatLng?> getCircleLatLng(Circle circle) {
    return _controller.getCircleLatLng(circle);
  }

  @override
  Future<void> removeCircle(Circle circle) {
    return _controller.removeCircle(circle);
  }

  @override
  Future<void> removeCircles(Iterable<Circle> circles) {
    return _controller.removeCircles(circles);
  }

  @override
  Future<void> clearCircles() {
    return _controller.clearCircles();
  }

  @override
  Future<Fill?> addFill(FillOptions options, [Map? data]) {
    return _controller.addFill(options, data);
  }

  @override
  Future<List<Fill>> addFills(List<FillOptions> options, [List<Map>? data]) {
    return _controller.addFills(options, data);
  }

  @override
  Future<void> updateFill(Fill fill, FillOptions changes) {
    return _controller.updateFill(fill, changes);
  }

  @override
  Future<void> clearFills() {
    return _controller.clearFills();
  }

  @override
  Future<void> removeFill(Fill fill) {
    return _controller.removeFill(fill);
  }

  @override
  Future<void> removeFills(Iterable<Fill> fills) {
    return _controller.removeFills(fills);
  }

  @override
  Future<List> queryRenderedFeatures(
      Point<double> point, List<String> layerIds, List<Object>? filter) {
    return _controller.queryRenderedFeatures(point, layerIds, filter);
  }

  @override
  Future<List?> queryRenderedFeaturesInRect(
      Rect rect, List<String> layerIds, String? filter) {
    return _controller.queryRenderedFeaturesInRect(rect, layerIds, filter);
  }

  @override
  Future invalidateAmbientCache() {
    return _controller.invalidateAmbientCache();
  }

  @override
  Future<LatLng?> requestMyLocationLatLng() {
    return _controller.requestMyLocationLatLng();
  }

  @override
  Future<LatLngBounds?> getVisibleRegion() {
    return _controller.getVisibleRegion();
  }

  @override
  Future<void> setStyleString(String styleString) {
    return _controller.setStyleString(styleString);
  }

  @override
  Future<void> addImage(String name, Uint8List bytes, [bool sdf = false]) {
    return _controller.addImage(name, bytes, sdf);
  }

  @override
  Future<void> setSymbolIconAllowOverlap(bool enable) {
    return _controller.setSymbolIconAllowOverlap(enable);
  }

  @override
  Future<void> setSymbolIconIgnorePlacement(bool enable) {
    return _controller.setSymbolIconIgnorePlacement(enable);
  }

  @override
  Future<void> setSymbolTextAllowOverlap(bool enable) {
    return _controller.setSymbolTextAllowOverlap(enable);
  }

  @override
  Future<void> setSymbolTextIgnorePlacement(bool enable) {
    return _controller.setSymbolTextIgnorePlacement(enable);
  }

  @override
  Future<void> addImageSource(
      String imageSourceId, Uint8List bytes, LatLngQuad coordinates) {
    return _controller.addImageSource(imageSourceId, bytes, coordinates);
  }

  @override
  Future<void> updateImageSource(
      String imageSourceId, Uint8List? bytes, LatLngQuad? coordinates) {
    return _controller.updateImageSource(imageSourceId, bytes, coordinates);
  }

  @override
  Future<void> removeSource(String sourceId) {
    return _controller.removeSource(sourceId);
  }

  @override
  Future<void> addImageLayer(String layerId, String imageSourceId,
      {double? minzoom, double? maxzoom}) {
    return _controller.addImageLayer(layerId, imageSourceId,
        minzoom: minzoom, maxzoom: maxzoom);
  }

  @override
  Future<void> addImageLayerBelow(
      String layerId, String sourceId, String imageSourceId,
      {double? minzoom, double? maxzoom}) {
    return _controller.addImageLayerBelow(layerId, sourceId, imageSourceId,
        minzoom: minzoom, maxzoom: maxzoom);
  }

  @override
  Future<void> removeLayer(String layerId) {
    return _controller.removeLayer(layerId);
  }

  @override
  Future<void> setFilter(String layerId, dynamic filter) {
    return _controller.setFilter(layerId, filter);
  }

  @override
  Future<void> setVisibility(String layerId, bool isVisible) {
    return _controller.setVisibility(layerId, isVisible);
  }

  @override
  Future<Point> toScreenLocation(LatLng latLng) {
    return _controller.toScreenLocation(latLng);
  }

  @override
  Future<List<Point>?> toScreenLocationBatch(Iterable<LatLng> latLngs) {
    return _controller.toScreenLocationBatch(latLngs);
  }

  @override
  Future<LatLng?> toLatLng(Point screenLocation) {
    return _controller.toLatLng(screenLocation);
  }

  @override
  Future<double?> getMetersPerPixelAtLatitude(double latitude) {
    return _controller.getMetersPerPixelAtLatitude(latitude);
  }

  @override
  Future<void> addSource(String sourceid, SourceProperties properties) {
    return _controller.addSource(sourceid, properties);
  }

  @override
  Future<void> addLayer(
      String sourceId, String layerId, LayerProperties properties,
      {String? belowLayerId,
      bool enableInteraction = true,
      String? sourceLayer,
      double? minzoom,
      double? maxzoom,
      dynamic filter}) {
    return _controller.addLayer(sourceId, layerId, properties,
        belowLayerId: belowLayerId,
        enableInteraction: enableInteraction,
        sourceLayer: sourceLayer,
        minzoom: minzoom,
        maxzoom: maxzoom,
        filter: filter);
  }

  @override
  Future<String?> takeSnapshot(SnapshotOptions snapshotOptions) {
    return _controller.takeSnapshot(snapshotOptions);
  }

  @override
  Future<String?> findBelowLayerId(List<String> belowAt) {
    return _controller.findBelowLayerId(belowAt);
  }

  @override
  void dispose() {
    _controller.dispose();
  }
} // class MapControllerWrapper extends IMapController {
