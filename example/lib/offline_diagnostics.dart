import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';

/// Bounded, redacted method history shared by the example and device tests.
class OfflineMethodLog {
  OfflineMethodLog({this.onChanged, this.limit = 80});

  final int limit;
  void Function()? onChanged;
  final List<Map<String, Object?>> entries = [];

  Future<T> run<T>(String method, Future<T> Function() action,
      {Map<String, Object?> arguments = const {}}) async {
    final entry = <String, Object?>{
      'method': method,
      'arguments': offlineDebugValue(arguments),
      'startedAt': DateTime.now().toUtc().toIso8601String(),
      'status': 'running',
    };
    entries.insert(0, entry);
    if (entries.length > limit) entries.removeLast();
    final watch = Stopwatch()..start();
    onChanged?.call();
    try {
      final result = await action();
      entry['status'] = 'success';
      entry['response'] = offlineDebugValue(result);
      return result;
    } catch (error) {
      entry['status'] = 'error';
      entry['error'] = offlineDebugValue(error);
      rethrow;
    } finally {
      entry['elapsedMs'] = watch.elapsedMilliseconds;
      onChanged?.call();
    }
  }

  String export() => const JsonEncoder.withIndent('  ').convert(entries);
}

String redactOfflineText(String value) => value.replaceAllMapped(
    RegExp(
        r'''(\b(?:api[_-]?key|access[_-]?(?:key|token)|key|token)(?:["']?\s*[:=]\s*["']?|\s+))[^\s&,\)"'\}]+''',
        caseSensitive: false),
    (match) => '${match[1]}[REDACTED]');

Object? offlineDebugValue(Object? value) {
  if (value == null || value is bool || value is num) return value;
  if (value is String) return redactOfflineText(value);
  if (value is PlatformException) {
    return {
      'code': value.code,
      'message': offlineDebugValue(value.message),
      'details': offlineDebugValue(value.details),
    };
  }
  if (value is Map) {
    return value.map((dynamic key, dynamic item) => MapEntry(
        key.toString(),
        RegExp(r'^(api[_-]?key|access[_-]?(key|token)|key|token)$',
                    caseSensitive: false)
                .hasMatch(key.toString())
            ? '[REDACTED]'
            : offlineDebugValue(item as Object?)));
  }
  if (value is Iterable) return value.map(offlineDebugValue).toList();
  if (value is OfflineNavigationConfiguration) {
    return {
      'routeMode': value.routeMode.name,
      'networkPolicy': value.networkPolicy.name
    };
  }
  if (value is OfflineNavigationRegions) {
    return {
      'regionCount': value.regions.length,
      'sample': value.regions.take(20).map(offlineDebugValue).toList(),
      'routingError': offlineDebugValue(value.routingError),
      'mapError': offlineDebugValue(value.mapError),
      'installedMapError': offlineDebugValue(value.installedMapError),
      'updatedAt': value.updatedAt.toIso8601String(),
    };
  }
  if (value is OfflineNavigationRegion) {
    return {
      'regionId': value.regionId,
      'name': value.name,
      'country': value.country,
      'adminL1': value.adminL1,
      'adminL2': value.adminL2,
      'adminL3': value.adminL3,
      'hasRouting': value.hasRouting,
      'hasMapTiles': value.hasMapTiles,
      'routingSizeBytes': value.routingSizeBytes,
      'mapSizeBytes': value.mapSizeBytes,
      'routingVersion': value.routingVersion,
      'mapVersion': value.mapVersion,
      'routingInstalled': value.routingInstalled,
      'routingPartial': value.routingPartial,
      'routingUpdateAvailable': value.routingUpdateAvailable,
      'mapUpdateAvailable': value.mapUpdateAvailable,
      'routingTilesDone': value.routingTilesDone,
      'routingTilesTotal': value.routingTilesTotal,
    };
  }
  if (value is OfflineInstalledMapRegion) {
    return {
      'regionId': value.regionId,
      'name': value.name,
      'totalBytes': value.totalBytes,
      'packageCount': value.packageCount,
      'version': value.version,
      'packagesComplete': value.packagesComplete,
    };
  }
  if (value is OfflineRegionProgress) {
    return {
      'regionId': value.regionId,
      'routing': offlineDebugValue(value.routing),
      'mapTiles': offlineDebugValue(value.mapTiles),
      'overallState': value.overallState.name,
      'overallPercent': value.overallPercent,
      'updatedAt': value.updatedAt.toIso8601String(),
    };
  }
  if (value is OfflineSubtaskProgress) {
    return {
      'state': value.nativeState,
      'percent': value.percent,
      'downloaded': value.downloaded,
      'total': value.total,
      'message': offlineDebugValue(value.message),
      'error': offlineDebugValue(value.error),
    };
  }
  if (value is OfflineRegionOperation) {
    return {
      'regionId': value.regionId,
      'routing': offlineDebugValue(value.routing),
      'mapTiles': offlineDebugValue(value.mapTiles)
    };
  }
  if (value is OfflineSubtaskResult) return offlineDebugValue(value.details);
  if (value is OfflineMapPreviewStatus) {
    return {
      'stylesReady': value.stylesReady,
      'previewBundleReady': value.previewBundleReady,
      'spritesReady': value.spritesReady,
      'tileJsonReady': value.tileJsonReady
    };
  }
  return redactOfflineText(value.toString());
}

String offlineDebugJson(Object? value) =>
    const JsonEncoder.withIndent('  ').convert(offlineDebugValue(value));
