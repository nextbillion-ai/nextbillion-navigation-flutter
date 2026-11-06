part of '../nb_navigation_flutter.dart';

/// The source policy used for initial routes and in-navigation rerouting.
enum NavigationRouteMode {
  onlineOnly,
  offlineOnly,
  onlinePreferred,
  offlinePreferred,
  smart,
}

/// [unmetered] is Android-only; iOS rejects it rather than broadening the policy.
enum OfflineDownloadNetworkPolicy { wifiOnly, anyNetwork, unmetered }

enum NavigationRouteSource { online, offline }

class OfflineNavigationConfiguration {
  final NavigationRouteMode routeMode;
  final OfflineDownloadNetworkPolicy networkPolicy;

  OfflineNavigationConfiguration.fromMap(Map<String, dynamic> map)
      : routeMode =
            NavigationRouteMode.values.byName(map['routeMode'] as String),
        networkPolicy = OfflineDownloadNetworkPolicy.values
            .byName(map['networkPolicy'] as String);
}

enum OfflineTaskState {
  notStarted,
  queued,
  running,
  paused,
  partial,
  failed,
  completed,
  unknown,
}

Map<String, dynamic> _offlineMap(dynamic value) =>
    Map<String, dynamic>.from(value as Map);

int _offlineInt(dynamic value, [int fallback = 0]) =>
    (value as num?)?.toInt() ?? fallback;

OfflineTaskState _offlineState(String? state) {
  final normalized = state?.replaceAll('_', '').toLowerCase();
  return OfflineTaskState.values.firstWhere(
    (value) => value.name.toLowerCase() == normalized,
    orElse: () => OfflineTaskState.unknown,
  );
}

/// Independent routing-network or map-tile progress. Native counters can be
/// absent; routing reports tile counts while maps report bytes.
class OfflineSubtaskProgress {
  final OfflineTaskState state;
  final String nativeState;
  final int percent;
  final int? downloaded;
  final int? total;
  final String? message;
  final String? error;

  OfflineSubtaskProgress.fromMap(Map<String, dynamic> map)
      : nativeState = map['state'] as String? ?? 'UNKNOWN',
        state = _offlineState(map['state'] as String?),
        percent = _offlineInt(map['percent']).clamp(0, 100),
        downloaded = (map['downloaded'] as num?)?.toInt(),
        total = (map['total'] as num?)?.toInt(),
        message = map['message'] as String?,
        error = map['error'] as String?;
}

/// A snapshot, not download history. Completed/cancelled tasks may disappear.
class OfflineRegionProgress {
  final int regionId;
  final OfflineSubtaskProgress? routing;
  final OfflineSubtaskProgress? mapTiles;
  final OfflineTaskState overallState;
  final int overallPercent;
  final DateTime updatedAt;

  OfflineRegionProgress.fromMap(Map<String, dynamic> map)
      : regionId = _offlineInt(map['regionId']),
        routing = map['routing'] == null
            ? null
            : OfflineSubtaskProgress.fromMap(_offlineMap(map['routing'])),
        mapTiles = map['mapTiles'] == null
            ? null
            : OfflineSubtaskProgress.fromMap(_offlineMap(map['mapTiles'])),
        overallState = _offlineState(map['overallState'] as String?),
        overallPercent = _offlineInt(map['overallPercent']).clamp(0, 100),
        updatedAt = DateTime.fromMillisecondsSinceEpoch(
            _offlineInt(map['updatedAtMs']),
            isUtc: true);

  /// Both native subtasks report completion. Map display resources are checked
  /// separately with [OfflineNavigation.getPreviewStatus]. This does not prove
  /// routing coverage for an arbitrary journey.
  bool get downloadsComplete =>
      routing?.state == OfflineTaskState.completed &&
      mapTiles?.state == OfflineTaskState.completed;
}

/// One row aligned by the Navigation SDK's regional catalog ID.
class OfflineNavigationRegion {
  final int regionId;
  final String name;
  final String? country;
  final String? adminL1;
  final String? adminL2;
  final String? adminL3;
  final bool hasRouting;
  final bool hasMapTiles;
  final int? routingSizeBytes;
  final int? mapSizeBytes;
  final String? routingVersion;
  final String? mapVersion;
  final bool routingInstalled;
  final bool routingPartial;
  final bool routingUpdateAvailable;
  final bool mapUpdateAvailable;
  final int routingTilesDone;
  final int routingTilesTotal;

  OfflineNavigationRegion.fromMap(Map<String, dynamic> map)
      : regionId = _offlineInt(map['regionId']),
        name = map['name'] as String? ?? '${map['regionId']}',
        country = map['country'] as String?,
        adminL1 = map['adminL1'] as String?,
        adminL2 = map['adminL2'] as String?,
        adminL3 = map['adminL3'] as String?,
        hasRouting = map['hasRouting'] == true,
        hasMapTiles = map['hasMapTiles'] == true,
        routingSizeBytes = (map['routingSizeBytes'] as num?)?.toInt(),
        mapSizeBytes = (map['mapSizeBytes'] as num?)?.toInt(),
        routingVersion = map['routingVersion'] as String?,
        mapVersion = map['mapVersion'] as String?,
        routingInstalled = map['routingInstalled'] == true,
        routingPartial = map['routingPartial'] == true,
        routingUpdateAvailable = map['routingUpdateAvailable'] == true,
        mapUpdateAvailable = map['mapUpdateAvailable'] == true,
        routingTilesDone = _offlineInt(map['routingTilesDone']),
        routingTilesTotal = _offlineInt(map['routingTilesTotal']);
}

/// Catalog components can fail independently. Preserve usable rows and show
/// [routingError], [mapError], or [installedMapError] alongside them.
class OfflineNavigationRegions {
  final List<OfflineNavigationRegion> regions;
  final String? routingError;
  final String? mapError;
  final String? installedMapError;
  final DateTime updatedAt;

  OfflineNavigationRegions.fromMap(Map<String, dynamic> map)
      : regions = List.unmodifiable((map['regions'] as List? ?? []).map(
            (dynamic row) =>
                OfflineNavigationRegion.fromMap(_offlineMap(row)))),
        routingError = map['routingError'] as String?,
        mapError = map['mapError'] as String?,
        installedMapError = map['installedMapError'] as String?,
        updatedAt = DateTime.fromMillisecondsSinceEpoch(
            _offlineInt(map['updatedAtMs']),
            isUtc: true);
}

/// Locally installed map packages, read without a catalog/network request.
/// Routing readiness is independent and is restored through [OfflineNavigation.progress].
class OfflineInstalledMapRegion {
  final int regionId;
  final String name;
  final int totalBytes;
  final int packageCount;
  final String? version;
  final bool packagesComplete;

  OfflineInstalledMapRegion.fromMap(Map<String, dynamic> map)
      : regionId = _offlineInt(map['regionId']),
        name = map['name'] as String? ?? '${map['regionId']}',
        totalBytes = _offlineInt(map['totalBytes']),
        packageCount = _offlineInt(map['packageCount']),
        version = map['version'] as String?,
        packagesComplete = map['packagesComplete'] == true;
}

/// A native management outcome for one subsystem. This acknowledges the
/// operation; it does not establish complete offline navigation readiness.
class OfflineSubtaskResult {
  final String state;
  final int? errorCode;
  final String? message;
  final Map<String, dynamic> details;

  OfflineSubtaskResult.fromMap(Map<String, dynamic> map)
      : state = map['state'] as String? ?? 'UNKNOWN',
        errorCode = (map['errorCode'] as num?)?.toInt(),
        message = map['message'] as String?,
        details = Map.unmodifiable(map);

  bool get hasError => errorCode != null && errorCode != 0;
}

class OfflineRegionOperation {
  final int regionId;
  final OfflineSubtaskResult routing;
  final OfflineSubtaskResult mapTiles;

  OfflineRegionOperation.fromMap(Map<String, dynamic> map)
      : regionId = _offlineInt(map['regionId']),
        routing = OfflineSubtaskResult.fromMap(_offlineMap(map['routing'])),
        mapTiles = OfflineSubtaskResult.fromMap(_offlineMap(map['mapTiles']));

  bool get hasError => routing.hasError || mapTiles.hasError;
}

/// A combined native operation may change one dataset before failing. These
/// observations describe local state after the error, not a per-kind success
/// acknowledgement. Null progress or an unreadable installed list is unknown.
class OfflineRegionOperationException extends PlatformException {
  final int regionId;
  final String operation;
  final OfflineRegionProgress? progress;
  final bool installedMapRead;
  final OfflineInstalledMapRegion? installedMap;

  OfflineRegionOperationException._(
      PlatformException error, Map<String, dynamic> value)
      : regionId = _offlineInt(value['regionId']),
        operation = value['operation'] as String? ?? '',
        progress = value['progress'] is Map
            ? OfflineRegionProgress.fromMap(_offlineMap(value['progress']))
            : null,
        installedMapRead = value['installedMapRead'] == true,
        installedMap = value['installedMap'] is Map
            ? OfflineInstalledMapRegion.fromMap(
                _offlineMap(value['installedMap']))
            : null,
        super(
            code: error.code,
            message: error.message,
            details: error.details,
            stacktrace: error.stacktrace);
}

/// Resource readiness is independent from regional transfer percentages.
/// Null means the native Navigation facade does not expose that probe.
class OfflineMapPreviewStatus {
  final bool stylesReady;
  final bool? previewBundleReady;
  final bool? spritesReady;
  final bool? tileJsonReady;

  OfflineMapPreviewStatus.fromMap(Map<String, dynamic> map)
      : stylesReady = map['stylesReady'] == true,
        previewBundleReady = map['previewBundleReady'] as bool?,
        spritesReady = map['spritesReady'] as bool?,
        tileJsonReady = map['tileJsonReady'] as bool?;
}
