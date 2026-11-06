part of '../nb_navigation_flutter.dart';

/// Navigation SDK regional downloads, shared by full-screen and embedded
/// navigation. Initialize the NextBillion account before using this API.
/// Do not also configure Maps Flutter's RegionalOffline manager for this flow.
class OfflineNavigation {
  static final OfflineNavigation instance = OfflineNavigation._();
  final MethodChannel _methods;
  final EventChannel _events;
  Stream<List<OfflineRegionProgress>>? _progress;
  Stream<List<OfflineRegionProgress>>? _nativeProgress;
  List<OfflineRegionProgress>? _lastProgress;
  int _progressListeners = 0;
  int _pageSequence = 0;

  OfflineNavigation._()
      : _methods = const MethodChannel('nb_navigation_flutter/offline'),
        _events = const EventChannel('nb_navigation_flutter/offline/events');

  @visibleForTesting
  OfflineNavigation.withChannels(this._methods, this._events);

  /// Sets process-wide policy for subsequent route requests and reroutes.
  /// SDK-managed timeouts/retries are retained. Existing downloads are not
  /// automatically paused when the network policy changes.
  Future<void> configure({
    NavigationRouteMode routeMode = NavigationRouteMode.onlineOnly,
    OfflineDownloadNetworkPolicy networkPolicy =
        OfflineDownloadNetworkPolicy.wifiOnly,
  }) =>
      _methods.invokeMethod<void>('configure', {
        'routeMode': routeMode.name,
        'networkPolicy': networkPolicy.name,
      });

  Future<OfflineNavigationConfiguration> getConfiguration() async =>
      OfflineNavigationConfiguration.fromMap(_offlineMap(
          await _methods.invokeMethod<dynamic>('getConfiguration')));

  /// Idempotent native initialization using SDK-owned data directories.
  /// Run asynchronously after normal map/account setup; map creation need not
  /// wait for offline setup or download readiness.
  Future<void> initialize() => _methods.invokeMethod<void>('initialize');

  Future<bool> isMapDownloadSupported() async =>
      await _methods.invokeMethod<bool>('isMapDownloadSupported') ?? false;

  /// Refreshes routing and map catalogs using the native cache TTL, or forces
  /// refresh. Network connectivity is needed when the catalog is not cached.
  Future<void> syncRegions({bool force = false}) =>
      _methods.invokeMethod<void>('syncRegions', {'force': force});

  /// Reads the routing catalog and queries the map catalog. Use full English
  /// country names from the native catalog, not ISO codes or localized names.
  /// Call [syncRegions] before the first catalog read. This is not a local-only
  /// query; while offline use installed map records and native progress.
  Future<OfflineNavigationRegions> fetchRegions(
      {String country = 'United States'}) async {
    if (country.trim().isEmpty) {
      throw ArgumentError.value(country, 'country', 'Must not be blank');
    }
    return OfflineNavigationRegions.fromMap(_offlineMap(await _methods
        .invokeMethod<dynamic>('fetchRegions', {'country': country.trim()})));
  }

  Future<List<OfflineInstalledMapRegion>> listInstalledMapRegions() async =>
      List.unmodifiable((await _methods
                  .invokeListMethod<dynamic>('listInstalledMapRegions') ??
              [])
          .map((dynamic row) =>
              OfflineInstalledMapRegion.fromMap(_offlineMap(row))));

  /// Starts both native downloads. May wait for routing work while map work
  /// remains queued/active. Observe [progress] and reread installed records;
  /// a completed Future or 100% transfer is not proof of display readiness.
  Future<OfflineRegionOperation> downloadRegion(int regionId) =>
      _manage('downloadRegion', regionId);
  Future<OfflineRegionOperation> pauseRegion(int regionId) =>
      _manage('pauseRegion', regionId);
  Future<OfflineRegionOperation> resumeRegion(int regionId) =>
      _manage('resumeRegion', regionId);

  /// Stops pending work while retaining data already persisted by the SDK.
  Future<OfflineRegionOperation> cancelRegion(int regionId) =>
      _manage('cancelRegion', regionId);

  /// Deletes routing and map data. Inspect both child results: deletion is not
  /// transactional and a failure can leave one subsystem's data installed.
  Future<OfflineRegionOperation> deleteRegion(int regionId) =>
      _manage('deleteRegion', regionId);

  Future<OfflineRegionOperation> _manage(String method, int regionId) async {
    _validateRegionId(regionId);
    try {
      return OfflineRegionOperation.fromMap(_offlineMap(await _methods
          .invokeMethod<dynamic>(method, {'regionId': regionId})));
    } on PlatformException catch (error) {
      final details = error.details;
      if (details is Map && details['partialOperation'] is Map) {
        throw OfflineRegionOperationException._(
            error, _offlineMap(details['partialOperation']));
      }
      rethrow;
    }
  }

  /// Returns the current snapshot then native updates, shared by subscribers.
  /// Routing installed state is restored from the native local catalog.
  /// Cancel a page's subscription on disposal; this never cancels downloads.
  Stream<List<OfflineRegionProgress>> get progress =>
      _progress ??= Stream<List<OfflineRegionProgress>>.multi((controller) {
        if (_progressListeners++ == 0) _lastProgress = null;
        final source = _nativeProgress ??=
            _events.receiveBroadcastStream().map((dynamic rows) {
          return _lastProgress = List<OfflineRegionProgress>.unmodifiable(
              (rows as List).map((dynamic row) =>
                  OfflineRegionProgress.fromMap(_offlineMap(row))));
        });
        final subscription = source.listen(controller.add,
            onError: controller.addError, onDone: controller.close);
        final snapshot = _lastProgress;
        if (snapshot != null) controller.add(snapshot);
        controller.onCancel = () {
          if (--_progressListeners == 0) _lastProgress = null;
          return subscription.cancel();
        };
      }, isBroadcast: true);

  Future<OfflineMapPreviewStatus> getPreviewStatus() async =>
      OfflineMapPreviewStatus.fromMap(_offlineMap(
          await _methods.invokeMethod<dynamic>('getPreviewStatus')));

  /// SDK diagnostics, including engine/data/schema versions. A healthy engine
  /// does not guarantee that every road needed by a requested trip is installed.
  Future<Map<String, dynamic>> healthCheck() async => Map.unmodifiable(
      _offlineMap(await _methods.invokeMethod<dynamic>('healthCheck')));

  Future<String> getRegionBoundary(int regionId,
      {bool fetchIfMissing = true}) async {
    _validateRegionId(regionId);
    return (await _methods.invokeMethod<String>('getRegionBoundary', {
      'regionId': regionId,
      'fetchIfMissing': fetchIfMissing,
    }))!;
  }

  /// Call when the Flutter download route opens. The token owns a native page
  /// session, independently of the host Activity/view controller lifetime.
  Future<String> beginDownloadPage() async {
    final token = '${DateTime.now().microsecondsSinceEpoch}_${_pageSequence++}';
    await _methods.invokeMethod<void>('beginDownloadPage', {'pageId': token});
    return token;
  }

  /// An older token cannot close a newer page session. Does not cancel tasks.
  Future<void> endDownloadPage(String pageId) =>
      _methods.invokeMethod<void>('endDownloadPage', {'pageId': pageId});

  Future<void> refreshMapResources() =>
      _methods.invokeMethod<void>('refreshMapResources');

  /// Process-level teardown only. Close navigation and download pages first.
  /// Downloaded data is retained. Initialize again before further offline use.
  Future<void> shutdown() => _methods.invokeMethod<void>('shutdown');

  void _validateRegionId(int regionId) {
    if (regionId <= 0 || regionId > 0x7fffffff) {
      throw RangeError.range(regionId, 1, 0x7fffffff, 'regionId');
    }
  }
}
