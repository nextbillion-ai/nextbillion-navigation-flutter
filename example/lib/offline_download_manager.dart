import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';
import 'offline_diagnostics.dart';

/// A map-free download screen. All data operations use Navigation SDK APIs.
class OfflineDownloadManager extends StatefulWidget {
  static const title = 'Offline Downloads';

  const OfflineDownloadManager({super.key, this.offline});

  final OfflineNavigation? offline;

  @override
  State<OfflineDownloadManager> createState() => _OfflineDownloadManagerState();
}

enum _DownloadAction { download, pause, resume, cancel, delete }

class _OfflineDownloadManagerState extends State<OfflineDownloadManager>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool _diagnosticsSelected = false;
  late final OfflineNavigation _offline =
      widget.offline ?? NBNavigation.offline;
  final _country = TextEditingController(text: 'United States');
  final _search = TextEditingController();
  final _regionId = TextEditingController();
  StreamSubscription<List<OfflineRegionProgress>>? _subscription;
  Timer? _refreshTimer;
  String? _pageId;
  bool _initializing = false;
  bool _ready = false;
  bool _loadingCatalog = false;
  bool _refreshingLocal = false;
  bool _refreshAgain = false;
  bool _changingPolicy = false;
  OfflineDownloadNetworkPolicy _policy = OfflineDownloadNetworkPolicy.wifiOnly;
  String? _notice;
  bool _noticeIsError = false;
  OfflineMapPreviewStatus? _preview;
  Map<int, OfflineNavigationRegion> _catalog = {};
  Map<int, OfflineInstalledMapRegion> _installed = {};
  Map<int, OfflineRegionProgress> _progress = {};
  final _manualIds = <int>{};
  final _pending = <int, Set<_DownloadAction>>{};
  final _operationVersions = <int, int>{};
  final _operationErrors = <int, String>{};
  final _log = <String>[];
  final _methods = OfflineMethodLog();
  NavigationRouteMode _routeMode = NavigationRouteMode.onlineOnly;
  bool _engineBusy = false;
  int _engineEpoch = 0;
  int _progressEvents = 0;
  DateTime? _lastProgressAt;

  Future<T> _call<T>(String method, Future<T> Function() action,
          {Map<String, Object?> arguments = const {}}) =>
      _methods.run(method, action, arguments: arguments);

  void _methodsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this)..addListener(_tabChanged);
    WidgetsBinding.instance.addObserver(this);
    _methods.onChanged = _methodsChanged;
    unawaited(_initialize());
  }

  void _tabChanged() {
    final diagnostic = _tabs.index == 3;
    if (diagnostic != _diagnosticsSelected && mounted) {
      setState(() {
        _diagnosticsSelected = diagnostic;
      });
    }
  }

  Future<void> _initialize() async {
    if (_initializing || _ready || _engineBusy) return;
    _engineEpoch++;
    setState(() {
      _initializing = true;
      _notice = null;
    });
    try {
      final configuration =
          await _call('getConfiguration', _offline.getConfiguration);
      if (!mounted) return;
      setState(() {
        _policy = configuration.networkPolicy;
        _routeMode = configuration.routeMode;
      });
      if (!await _call(
          'isMapDownloadSupported', _offline.isMapDownloadSupported)) {
        throw StateError(
            'Regional offline maps require TomTom. Initialize the SDK with TomTom first.');
      }
      if (!mounted) return;
      await _call('initialize', _offline.initialize);
      if (!mounted) return;
      final pageId =
          await _call('beginDownloadPage', _offline.beginDownloadPage);
      if (!mounted) {
        await _call('endDownloadPage', () => _offline.endDownloadPage(pageId));
        return;
      }
      _pageId = pageId;
      await _listenProgress();
      if (!mounted) return;
      setState(() {
        _ready = true;
      });
      // Restore local records before any online catalog request.
      await _refreshLocal();
      if (mounted) unawaited(_loadCatalog());
    } catch (error) {
      _show('Initialization failed: ${_errorText(error)}', error: true);
    } finally {
      if (mounted) {
        setState(() {
          _initializing = false;
        });
      }
    }
  }

  Future<void> _listenProgress() => _call('progress.listen', () async {
        if (_subscription != null || !mounted) return;
        _subscription = _offline.progress.listen((rows) {
          if (!mounted) return;
          setState(() {
            _progress = {for (final row in rows) row.regionId: row};
            _progressEvents++;
            _lastProgressAt = DateTime.now();
          });
          _refreshTimer ??= Timer(const Duration(milliseconds: 400), () {
            _refreshTimer = null;
            if (mounted) unawaited(_refreshLocal());
          });
        },
            onError: (Object error) => _show(
                'Progress subscription failed: ${_errorText(error)}',
                error: true));
      });

  void _show(String message, {bool error = false}) {
    if (!mounted) return;
    message = redactOfflineText(message);
    setState(() {
      _notice = message;
      _noticeIsError = error;
      _log.insert(0, '${TimeOfDay.now().format(context)}  $message');
      if (_log.length > 12) _log.removeLast();
    });
  }

  String _errorText(Object error) {
    if (error is OfflineRegionOperationException) {
      final map = error.progress?.mapTiles;
      return '${error.message ?? error.code} (${error.code})\n'
          'The operation may have partially completed. A failure does not mean both tasks were rolled back.\n'
          'Routing: ${error.progress?.routing?.nativeState ?? "Unknown"}; '
          'Map: ${map?.nativeState ?? "Unknown"}; '
          'Local maps: ${!error.installedMapRead ? "Read failed or timed out" : error.installedMap == null ? "No installation record" : error.installedMap!.packagesComplete ? "Installed" : "Incomplete installation"}';
    }
    return error is PlatformException
        ? '${error.message ?? error.code} (${error.code})'
        : error.toString();
  }

  Future<void> _refreshLocal() async {
    if (!_ready || !mounted) return;
    if (_refreshingLocal) {
      _refreshAgain = true;
      return;
    }
    setState(() {
      _refreshingLocal = true;
    });
    final epoch = _engineEpoch;
    try {
      do {
        _refreshAgain = false;
        // Preserve independent local data if either resource probe fails.
        await Future.wait([
          () async {
            try {
              final regions = await _call(
                  'listInstalledMapRegions', _offline.listInstalledMapRegions);
              if (mounted && epoch == _engineEpoch) {
                setState(() {
                  _installed = {
                    for (final region in regions) region.regionId: region
                  };
                });
              }
            } catch (error) {
              _show('Failed to read local maps: ${_errorText(error)}',
                  error: true);
            }
          }(),
          () async {
            try {
              final preview =
                  await _call('getPreviewStatus', _offline.getPreviewStatus);
              if (mounted && epoch == _engineEpoch) {
                setState(() {
                  _preview = preview;
                });
              }
            } catch (error) {
              _show('Failed to read map resource status: ${_errorText(error)}',
                  error: true);
            }
          }(),
        ]);
      } while (_refreshAgain && mounted && _ready && epoch == _engineEpoch);
    } finally {
      if (mounted) {
        setState(() {
          _refreshingLocal = false;
        });
      }
    }
  }

  Future<void> _loadCatalog({bool force = false}) async {
    if (!_ready || _loadingCatalog) return;
    final country = _country.text.trim();
    if (country.isEmpty) {
      _show('Enter the full country name in English.', error: true);
      return;
    }
    setState(() {
      _loadingCatalog = true;
    });
    final errors = <String>[];
    final epoch = _engineEpoch;
    try {
      try {
        await _call('syncRegions', () => _offline.syncRegions(force: force),
            arguments: {'force': force});
      } catch (error) {
        errors.add('Sync: ${_errorText(error)}');
      }
      if (!mounted || epoch != _engineEpoch) return;
      // Even a partially failed sync may leave a usable cached routing catalog.
      final result = await _call(
          'fetchRegions', () => _offline.fetchRegions(country: country),
          arguments: {'country': country});
      if (!mounted || epoch != _engineEpoch) return;
      setState(() {
        _catalog = {
          for (final region in result.regions) region.regionId: region
        };
      });
      if (result.routingError != null) {
        errors.add('Routing catalog: ${result.routingError}');
      }
      if (result.mapError != null) {
        errors.add('Map catalog: ${result.mapError}');
      }
      if (result.installedMapError != null) {
        errors.add('Local maps: ${result.installedMapError}');
      }
      _show(
          errors.isEmpty
              ? 'Loaded ${result.regions.length} regions for $country.'
              : 'Some catalogs failed to load. Local data can still be managed.\n${errors.join('\n')}',
          error: errors.isNotEmpty);
    } catch (error) {
      _show(
          'Catalog loading failed. Local data can still be managed.\n${_errorText(error)}',
          error: true);
    } finally {
      if (mounted) {
        setState(() {
          _loadingCatalog = false;
        });
      }
    }
  }

  Future<void> _setPolicy(OfflineDownloadNetworkPolicy policy) async {
    setState(() {
      _changingPolicy = true;
    });
    try {
      // The download screen must not overwrite the application's routing mode.
      final current =
          await _call('getConfiguration', _offline.getConfiguration);
      if (!mounted) return;
      await _call(
          'configure',
          () => _offline.configure(
              routeMode: current.routeMode, networkPolicy: policy),
          arguments: {
            'routeMode': current.routeMode.name,
            'networkPolicy': policy.name
          });
      if (mounted) {
        setState(() {
          _policy = policy;
        });
      }
      _show(
          'Download network policy updated for subsequent downloads and resumes.');
    } catch (error) {
      _show(_errorText(error), error: true);
    } finally {
      if (mounted) {
        setState(() {
          _changingPolicy = false;
        });
      }
    }
  }

  Future<void> _manage(int id, _DownloadAction action) async {
    if (!_ready || (_pending[id]?.contains(action) ?? false)) return;
    if (action == _DownloadAction.delete) {
      final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Delete Offline Data?'),
                content: Text(
                    'This will delete routing and map data for "${_name(id)}". Download the region again before using it offline.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Back')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete Data'))
                ],
              ));
      if (confirmed != true || !mounted) return;
    }
    final version = (_operationVersions[id] ?? 0) + 1;
    _operationVersions[id] = version;
    setState(() {
      (_pending[id] ??= {}).add(action);
      _operationErrors.remove(id);
    });
    try {
      // A long-running download must not disable pause/cancel for this region.
      final result = await _call(
          '${action.name}Region',
          () => switch (action) {
                _DownloadAction.download => _offline.downloadRegion(id),
                _DownloadAction.pause => _offline.pauseRegion(id),
                _DownloadAction.resume => _offline.resumeRegion(id),
                _DownloadAction.cancel => _offline.cancelRegion(id),
                _DownloadAction.delete => _offline.deleteRegion(id),
              },
          arguments: {'regionId': id});
      if (!mounted) return;
      if (_operationVersions[id] == version) {
        final message =
            '${_actionLabel(action)} · ${_name(id)}\nRouting: ${result.routing.state}'
            '${result.routing.message == null ? "" : " · ${result.routing.message}"}'
            '\nMap: ${result.mapTiles.state}${result.mapTiles.message == null ? "" : " · ${result.mapTiles.message}"}';
        if (result.hasError) _operationErrors[id] = message;
        _show(message, error: result.hasError);
      }
    } catch (error) {
      if (mounted && _operationVersions[id] == version) {
        if (error is OfflineRegionOperationException &&
            error.progress != null) {
          _progress[id] = error.progress!;
        }
        final message = '${_actionLabel(action)} failed: ${_errorText(error)}';
        _operationErrors[id] = message;
        _show(message, error: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _pending[id]?.remove(action);
          if (_pending[id]?.isEmpty ?? false) _pending.remove(id);
        });
        await _refreshLocal();
      }
    }
  }

  void _addRegion() {
    final id = int.tryParse(_regionId.text.trim());
    if (id == null || id <= 0 || id > 0x7fffffff) {
      _show('Enter a region ID between 1 and 2147483647.', error: true);
      return;
    }
    setState(() {
      _manualIds.add(id);
    });
    _tabs.animateTo(1);
  }

  String _name(int id) =>
      _catalog[id]?.name ?? _installed[id]?.name ?? 'Region $id';
  bool _isActive(OfflineTaskState? state) => const {
        OfflineTaskState.queued,
        OfflineTaskState.running,
        OfflineTaskState.paused,
        OfflineTaskState.partial,
        OfflineTaskState.failed,
      }.contains(state);

  Set<int> get _taskIds => {
        ..._manualIds,
        ..._pending.keys,
        ..._operationErrors.keys,
        for (final row in _progress.values)
          if (_isActive(row.routing?.state) ||
              _isActive(row.mapTiles?.state) ||
              _isActive(row.overallState))
            row.regionId,
      };

  Set<int> get _installedIds => {
        ..._installed.keys,
        for (final row in _progress.values)
          if (row.routing?.state == OfflineTaskState.completed) row.regionId,
      };

  List<int> _filter(Iterable<int> ids) {
    final query = _search.text.trim().toLowerCase();
    return ids.where((id) {
      final region = _catalog[id];
      return '${_name(id)} $id ${region?.country ?? ""} ${region?.adminL1 ?? ""} '
              '${region?.adminL2 ?? ""} ${region?.adminL3 ?? ""}'
          .toLowerCase()
          .contains(query);
    }).toList()
      ..sort((a, b) => _name(a).compareTo(_name(b)));
  }

  void _showDetails(String title, String message) {
    final safeMessage = redactOfflineText(message);
    showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                  child: SelectableText(safeMessage.length > 16000
                      ? '${safeMessage.substring(0, 16000)}\n…Display truncated. Copy to get the full content.'
                      : safeMessage)),
              actions: [
                TextButton(
                    onPressed: () =>
                        Clipboard.setData(ClipboardData(text: safeMessage)),
                    child: const Text('Copy')),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'))
              ],
            ));
  }

  Future<void> _healthCheck() async {
    try {
      final health = await _call('healthCheck', _offline.healthCheck);
      if (mounted) {
        _showDetails(
            'Offline Engine Status',
            health.entries
                .map((entry) => '${entry.key}: ${entry.value}')
                .join('\n'));
      }
    } catch (error) {
      _show(_errorText(error), error: true);
    }
  }

  Future<void> _inspect<T>(String method, Future<T> Function() action,
      {Map<String, Object?> arguments = const {}}) async {
    try {
      final value = await _call(method, action, arguments: arguments);
      if (mounted) _showDetails(method, offlineDebugJson(value));
    } catch (error) {
      _show('$method failed: ${_errorText(error)}', error: true);
    }
  }

  Future<void> _readConfiguration() async {
    try {
      final value = await _call('getConfiguration', _offline.getConfiguration);
      if (!mounted) return;
      setState(() {
        _routeMode = value.routeMode;
        _policy = value.networkPolicy;
      });
      _showDetails('Current Configuration', offlineDebugJson(value));
    } catch (error) {
      _show(_errorText(error), error: true);
    }
  }

  Future<void> _setRouteMode(NavigationRouteMode mode) async {
    if (_engineBusy || !_ready) return;
    setState(() {
      _changingPolicy = true;
    });
    try {
      final current =
          await _call('getConfiguration', _offline.getConfiguration);
      if (!mounted) return;
      await _call(
          'configure',
          () => _offline.configure(
              routeMode: mode, networkPolicy: current.networkPolicy),
          arguments: {
            'routeMode': mode.name,
            'networkPolicy': current.networkPolicy.name
          });
      if (mounted) {
        setState(() {
          _routeMode = mode;
          _policy = current.networkPolicy;
        });
      }
      _show(
          'Routing mode set to ${mode.name} for subsequent route requests and reroutes.');
    } catch (error) {
      _show(_errorText(error), error: true);
    } finally {
      if (mounted) {
        setState(() {
          _changingPolicy = false;
        });
      }
    }
  }

  Future<void> _toggleProgress() async {
    try {
      final subscription = _subscription;
      if (subscription == null) {
        await _listenProgress();
        _show('Progress subscription resumed.');
      } else {
        _subscription = null;
        await _call('progress.cancel', subscription.cancel);
        _show('Page progress subscription stopped. SDK downloads continue.');
      }
    } catch (error) {
      _show(_errorText(error), error: true);
    }
  }

  Future<void> _rebindPage() async {
    try {
      final old = _pageId;
      _pageId = null;
      if (old != null) {
        await _call('endDownloadPage', () => _offline.endDownloadPage(old));
      }
      if (!mounted) return;
      final token =
          await _call('beginDownloadPage', _offline.beginDownloadPage);
      if (!mounted) {
        await _offline.endDownloadPage(token);
        return;
      }
      _pageId = token;
      _show('Download page session rebound. Existing downloads continue.');
    } catch (error) {
      _show(_errorText(error), error: true);
    }
  }

  Future<void> _shutdown() async {
    if (_engineBusy ||
        _pending.isNotEmpty ||
        _loadingCatalog ||
        _changingPolicy) {
      return;
    }
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Shut Down Offline Engine?'),
              content: const Text(
                  'This stops offline services and interrupts related tasks for the entire process. Downloaded data is retained. Exit navigation first. You can initialize the engine again on this page.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Back')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Shut Down'))
              ],
            ));
    if (confirmed != true || !mounted) return;
    _engineEpoch++;
    setState(() {
      _engineBusy = true;
      _ready = false;
    });
    _refreshTimer?.cancel();
    _refreshTimer = null;
    try {
      final subscription = _subscription;
      _subscription = null;
      if (subscription != null) {
        await _call('progress.cancel', subscription.cancel);
      }
      final token = _pageId;
      _pageId = null;
      if (token != null) {
        await _call('endDownloadPage', () => _offline.endDownloadPage(token));
      }
      await _call('shutdown', _offline.shutdown);
      if (mounted) {
        setState(() {
          _progress = {};
          _preview = null;
        });
      }
      _show(
          'Offline engine stopped. Downloaded data is retained and can be read after reinitialization.');
    } catch (error) {
      _show('Engine shutdown failed: ${_errorText(error)}', error: true);
    } finally {
      if (mounted) {
        setState(() {
          _engineBusy = false;
        });
      }
    }
  }

  Future<void> _boundary(int id, bool fetchIfMissing) async {
    await _inspect('getRegionBoundary',
        () => _offline.getRegionBoundary(id, fetchIfMissing: fetchIfMissing),
        arguments: {'regionId': id, 'fetchIfMissing': fetchIfMissing});
  }

  void _regionDetails(int id) {
    showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
              title: Text('${_name(id)} · $id'),
              content: SingleChildScrollView(
                  child: SelectableText(offlineDebugJson({
                'catalog': _catalog[id],
                'installedMap': _installed[id],
                'progress': _progress[id],
                'operationError': _operationErrors[id],
              }))),
              actions: [
                TextButton(
                    key: ValueKey('boundary-local-$id'),
                    onPressed: !_ready
                        ? null
                        : () {
                            Navigator.pop(context);
                            unawaited(_boundary(id, false));
                          },
                    child: const Text('Local Boundary')),
                TextButton(
                    key: ValueKey('boundary-fetch-$id'),
                    onPressed: !_ready
                        ? null
                        : () {
                            Navigator.pop(context);
                            unawaited(_boundary(id, true));
                          },
                    child: const Text('Fetch Boundary')),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close')),
              ],
            ));
  }

  Widget _diagnostics() =>
      ListView(padding: const EdgeInsets.all(16), children: [
        Text('Offline API and Runtime Status',
            style: Theme.of(context).textTheme.titleMedium),
        Text(
            'Engine: ${_engineBusy ? "Changing" : _ready ? "Initialized" : "Not ready"}; Page session: ${_pageId == null ? "Unbound" : "Bound"}'),
        Text(
            'Progress subscription: ${_subscription == null ? "Stopped" : "Listening"}; $_progressEvents snapshots received'),
        Text(
            'Last snapshot: ${_lastProgressAt?.toLocal().toIso8601String() ?? "Not received yet"}'),
        const SizedBox(height: 8),
        DropdownButtonFormField<NavigationRouteMode>(
          isExpanded: true,
          key: ValueKey('route-mode-${_routeMode.name}'),
          initialValue: _routeMode,
          decoration: const InputDecoration(labelText: 'Global Routing Mode'),
          items: NavigationRouteMode.values
              .map((mode) =>
                  DropdownMenuItem(value: mode, child: Text(mode.name)))
              .toList(),
          onChanged: !_ready || _changingPolicy
              ? null
              : (value) => _setRouteMode(value!),
        ),
        const Text(
            'This mode applies to initial route requests and rerouting throughout the example.',
            style: TextStyle(fontSize: 12)),
        Wrap(spacing: 8, runSpacing: 4, children: [
          OutlinedButton(
              onPressed: _engineBusy ? null : _readConfiguration,
              child: const Text('Read Configuration')),
          OutlinedButton(
              onPressed: _engineBusy
                  ? null
                  : () => _inspect('isMapDownloadSupported',
                      _offline.isMapDownloadSupported),
              child: const Text('Check Download Support')),
          OutlinedButton(
              onPressed: _engineBusy || _initializing
                  ? null
                  : () => _ready
                      ? _inspect('initialize', _offline.initialize)
                      : _initialize(),
              child: const Text('Initialize Engine')),
          OutlinedButton(
              onPressed: !_ready
                  ? null
                  : () => _inspect(
                      'refreshMapResources', _offline.refreshMapResources),
              child: const Text('Refresh Map Resources')),
          OutlinedButton(
              onPressed: !_ready ? null : _healthCheck,
              child: const Text('Engine Health Check')),
          OutlinedButton(
              onPressed: !_ready ? null : _toggleProgress,
              child: Text(
                  _subscription == null ? 'Resume Progress' : 'Stop Progress')),
          OutlinedButton(
              onPressed: !_ready ? null : _rebindPage,
              child: const Text('Rebind Page Session')),
          OutlinedButton(
              onPressed: !_ready ||
                      _pending.isNotEmpty ||
                      _loadingCatalog ||
                      _changingPolicy
                  ? null
                  : _shutdown,
              child: const Text('Shut Down Offline Engine')),
        ]),
        const Divider(),
        Row(children: [
          const Expanded(
              child: Text(
                  'Last 80 calls (tap for arguments and response details)')),
          IconButton(
              tooltip: 'Copy Call History',
              onPressed: () =>
                  Clipboard.setData(ClipboardData(text: _methods.export())),
              icon: const Icon(Icons.copy))
        ]),
        for (final entry in _methods.entries)
          ListTile(
            dense: true,
            title: Text('${entry['method']} · ${entry['status']}'),
            subtitle:
                Text('${entry['startedAt']} · ${entry['elapsedMs'] ?? "…"} ms'),
            onTap: () => _showDetails(
                entry['method']! as String, offlineDebugJson(entry)),
          ),
      ]);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _ready) {
      unawaited(_refreshLocal());
    }
  }

  @override
  Widget build(BuildContext context) => Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
              title: const Text(OfflineDownloadManager.title),
              actions: [
                IconButton(
                    onPressed: !_ready ? null : _healthCheck,
                    icon: const Icon(Icons.health_and_safety_outlined),
                    tooltip: 'Check Offline Engine'),
                IconButton(
                    onPressed: !_ready
                        ? (_initializing ? null : _initialize)
                        : _refreshLocal,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh Local Data'),
              ],
              bottom: TabBar(
                  controller: _tabs,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    Tab(text: 'Available (${_catalog.length})'),
                    Tab(text: 'Tasks (${_taskIds.length})'),
                    Tab(text: 'Installed (${_installedIds.length})'),
                    const Tab(text: 'Diagnostics'),
                  ])),
          body: NestedScrollView(
            headerSliverBuilder: (_, __) => _diagnosticsSelected
                ? []
                : [
                    SliverToBoxAdapter(
                        child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_initializing) const LinearProgressIndicator(),
                          if (_initializing)
                            const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('Initializing offline downloads…')),
                          if (_notice != null)
                            Card(
                              color: _noticeIsError
                                  ? Theme.of(context).colorScheme.errorContainer
                                  : null,
                              child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(_notice!,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis),
                                      Wrap(spacing: 8, children: [
                                        TextButton(
                                            onPressed: () => _showDetails(
                                                'Operation Details', _notice!),
                                            child: const Text('View Details')),
                                        if (!_ready && !_initializing)
                                          TextButton(
                                              onPressed: _initialize,
                                              child: const Text(
                                                  'Retry Initialization')),
                                        TextButton(
                                            onPressed: () => setState(() {
                                                  _notice = null;
                                                }),
                                            child: const Text('Dismiss')),
                                      ]),
                                    ],
                                  )),
                            ),
                          DropdownButtonFormField<OfflineDownloadNetworkPolicy>(
                            isExpanded: true,
                            initialValue: _policy,
                            key: ValueKey(_policy),
                            decoration: const InputDecoration(
                                labelText: 'Download Network'),
                            items: [
                              const DropdownMenuItem(
                                  value: OfflineDownloadNetworkPolicy.wifiOnly,
                                  child: Text('Wi-Fi Only')),
                              const DropdownMenuItem(
                                  value:
                                      OfflineDownloadNetworkPolicy.anyNetwork,
                                  child: Text('Any Available Network')),
                              if (Platform.isAndroid ||
                                  _policy ==
                                      OfflineDownloadNetworkPolicy.unmetered)
                                const DropdownMenuItem(
                                    value:
                                        OfflineDownloadNetworkPolicy.unmetered,
                                    child: Text('Unmetered Only')),
                            ],
                            onChanged: !_ready || _changingPolicy
                                ? null
                                : (value) => unawaited(_setPolicy(value!)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                              'Style resources: ${_preview == null ? "Reading" : _preview!.stylesReady ? "Cached" : "Not ready"}'
                              '  ·  Display resources: ${_preview?.previewBundleReady == null ? "Full check unavailable" : _preview!.previewBundleReady! ? "Ready" : "Preparing"}'),
                          const Text(
                              'Download and display readiness are checked separately. Downloads continue after you leave.',
                              style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 12),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: TextField(
                                        controller: _country,
                                        key: const Key('download-country'),
                                        decoration: const InputDecoration(
                                            labelText: 'Country (English name)',
                                            hintText: 'e.g. United States'),
                                        onSubmitted: (_) =>
                                            unawaited(_loadCatalog()))),
                                const SizedBox(width: 8),
                                FilledButton(
                                    onPressed: !_ready || _loadingCatalog
                                        ? null
                                        : () => _loadCatalog(),
                                    child: Text(_loadingCatalog
                                        ? 'Loading…'
                                        : 'Load Regions')),
                                IconButton(
                                    onPressed: !_ready || _loadingCatalog
                                        ? null
                                        : () => _loadCatalog(force: true),
                                    icon: const Icon(Icons.sync),
                                    tooltip: 'Force Catalog Sync'),
                              ]),
                          TextField(
                              controller: _search,
                              key: const Key('download-search'),
                              decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.search),
                                  labelText:
                                      'Search by name, area, or region ID'),
                              onChanged: (_) => setState(() {})),
                          ExpansionTile(
                              tilePadding: EdgeInsets.zero,
                              title: const Text('Test by Region ID'),
                              children: [
                                Row(children: [
                                  Expanded(
                                      child: TextField(
                                          controller: _regionId,
                                          keyboardType: TextInputType.number,
                                          key: const Key('download-region-id'),
                                          decoration: const InputDecoration(
                                              labelText: 'Region ID'))),
                                  TextButton(
                                      onPressed: !_ready ? null : _addRegion,
                                      child: const Text('Add to Tasks'))
                                ]),
                              ]),
                          if (_log.isNotEmpty)
                            ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                title: const Text('Recent Activity'),
                                children: [
                                  for (final line in _log)
                                    ListTile(
                                        dense: true,
                                        title: SelectableText(line))
                                ]),
                        ],
                      ),
                    ))
                  ],
            body: TabBarView(controller: _tabs, children: [
              _regionList(
                  _filter(_catalog.keys),
                  'available',
                  _loadingCatalog
                      ? 'Loading region catalog…'
                      : 'No Available Regions',
                  'Choose another country or reload the catalog.'),
              _regionList(_filter(_taskIds), 'tasks', 'No Download Tasks',
                  'Select a region in Available, or add a task by region ID.'),
              _regionList(
                  _filter(_installedIds),
                  'installed',
                  'No Installed Data',
                  'Routing and map data are tracked separately. Local data can be viewed offline.'),
              _diagnostics(),
            ]),
          ),
        ),
      );

  Widget _regionList(
      List<int> ids, String storageKey, String emptyTitle, String description) {
    return RefreshIndicator(
        onRefresh: _refreshLocal,
        child: ListView.builder(
          key: PageStorageKey(storageKey),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: ids.isEmpty ? 1 : ids.length,
          itemBuilder: (context, index) => ids.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(children: [
                    const Icon(Icons.download_for_offline_outlined, size: 40),
                    const SizedBox(height: 12),
                    Text(emptyTitle),
                    const SizedBox(height: 8),
                    Text(description, textAlign: TextAlign.center)
                  ]))
              : _regionCard(ids[index]),
        ));
  }

  Widget _regionCard(int id) {
    final region = _catalog[id];
    final installed = _installed[id];
    final progress = _progress[id];
    final pending = _pending[id] ?? {};
    return Card(
        key: ValueKey('download-region-$id'),
        child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                      child: Text(_name(id),
                          style: Theme.of(context).textTheme.titleMedium)),
                  IconButton(
                      key: ValueKey('download-$id-details'),
                      tooltip: 'Region Details and Boundary',
                      onPressed: () => _regionDetails(id),
                      icon: const Icon(Icons.info_outline))
                ]),
                Text(
                    'ID $id${region?.adminL1 == null ? "" : " · ${region!.adminL1}"}'),
                if (region?.routingUpdateAvailable == true ||
                    region?.mapUpdateAvailable == true)
                  const Text('Update available'),
                const SizedBox(height: 12),
                _subtask('Routing data', progress?.routing,
                    progress?.routing?.state == OfflineTaskState.completed,
                    totalSize: region?.routingSizeBytes, tiles: true),
                const SizedBox(height: 10),
                _subtask('Map data', progress?.mapTiles,
                    installed?.packagesComplete ?? false,
                    totalSize: installed?.totalBytes ?? region?.mapSizeBytes,
                    tiles: false),
                if (_operationErrors[id] != null)
                  Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(_operationErrors[id]!,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error))),
                const SizedBox(height: 8),
                Wrap(spacing: 4, runSpacing: 4, children: [
                  for (final action in _DownloadAction.values)
                    TextButton.icon(
                      key: ValueKey('download-$id-${action.name}'),
                      onPressed: !_ready || pending.contains(action)
                          ? null
                          : () => _manage(id, action),
                      icon: Icon(
                          switch (action) {
                            _DownloadAction.download => Icons.download,
                            _DownloadAction.pause => Icons.pause,
                            _DownloadAction.resume => Icons.play_arrow,
                            _DownloadAction.cancel => Icons.stop,
                            _DownloadAction.delete => Icons.delete_outline,
                          },
                          size: 18),
                      label: Text(pending.contains(action)
                          ? '${_actionLabel(action)} in progress…'
                          : _actionLabel(action)),
                    ),
                ]),
              ],
            )));
  }

  Widget _subtask(
      String label, OfflineSubtaskProgress? progress, bool installed,
      {required int? totalSize, required bool tiles}) {
    final state = progress?.state;
    final title = state == null
        ? (installed ? 'Installed' : 'No local status')
        : _stateLabel(state);
    final counter = progress?.total;
    final details = counter != null && counter > 0
        ? (tiles
            ? '${progress?.downloaded ?? 0} / $counter tiles'
            : '${_bytes(progress?.downloaded ?? 0)} / ${_bytes(counter)}')
        : totalSize == null
            ? ''
            : _bytes(totalSize);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text('$label · $title')),
        if (progress != null) Text('${progress.percent}%')
      ]),
      if (progress != null)
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: LinearProgressIndicator(value: progress.percent / 100)),
      if (details.isNotEmpty)
        Text(details, style: Theme.of(context).textTheme.bodySmall),
      if (progress?.error != null)
        Text(progress!.error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error)),
    ]);
  }

  String _actionLabel(_DownloadAction action) => switch (action) {
        _DownloadAction.download => 'Download',
        _DownloadAction.pause => 'Pause',
        _DownloadAction.resume => 'Resume',
        _DownloadAction.cancel => 'Cancel',
        _DownloadAction.delete => 'Delete',
      };
  String _stateLabel(OfflineTaskState state) => switch (state) {
        OfflineTaskState.notStarted => 'Not started',
        OfflineTaskState.queued => 'Queued',
        OfflineTaskState.running => 'Downloading or installing',
        OfflineTaskState.paused => 'Paused',
        OfflineTaskState.partial => 'Partially complete',
        OfflineTaskState.failed => 'Failed',
        OfflineTaskState.completed => 'Installed',
        OfflineTaskState.unknown => 'Unknown',
      };
  String _bytes(int bytes) {
    var value = bytes.toDouble();
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    var unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }
    return '${value.toStringAsFixed(unit == 0 ? 0 : 1)} ${units[unit]}';
  }

  @override
  void dispose() {
    _tabs.removeListener(_tabChanged);
    _tabs.dispose();
    _methods.onChanged = null;
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    unawaited(_subscription?.cancel());
    final pageId = _pageId;
    if (pageId != null) {
      unawaited(_offline.endDownloadPage(pageId).catchError((Object _) {}));
    }
    _country.dispose();
    _search.dispose();
    _regionId.dispose();
    super.dispose();
  }
}
