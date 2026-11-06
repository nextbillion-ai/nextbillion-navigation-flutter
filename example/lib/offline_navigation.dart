import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';
import 'offline_download_manager.dart';

/// Mounts the map immediately; offline initialization/downloads run separately.
class OfflineNavigationExample extends StatefulWidget {
  static const title = 'Offline Navigation';
  const OfflineNavigationExample({super.key});

  @override
  State<OfflineNavigationExample> createState() =>
      _OfflineNavigationExampleState();
}

class _OfflineNavigationExampleState extends State<OfflineNavigationExample>
    with WidgetsBindingObserver {
  final _offline = NBNavigation.offline;
  final _country = TextEditingController(text: 'United States');
  final _search = TextEditingController();
  StreamSubscription<List<OfflineRegionProgress>>? _subscription;
  OfflineNavigationConfiguration? _previousConfiguration;
  String? _pageId;
  Timer? _installedRefresh;
  bool _ready = false;
  bool _loading = false;
  bool _calculating = false;
  OfflineDownloadNetworkPolicy _downloadPolicy =
      OfflineDownloadNetworkPolicy.wifiOnly;
  bool _simulate = true;
  String _message = 'Preparing offline navigation…';
  NavigationRouteMode _mode = NavigationRouteMode.offlineOnly;
  OfflineNavigationRegions? _catalog;
  List<OfflineInstalledMapRegion> _installed = [];
  Map<int, OfflineRegionProgress> _progress = {};
  OfflineMapPreviewStatus? _preview;
  NextbillionMapController? _controller;
  NavNextBillionMap? _navigationMap;
  LatLng? _origin;
  LatLng? _destination;
  List<DirectionsRoute> _routes = [];
  int _routeRevision = 0;
  int _styleRevision = 0;
  Future<void> _mapUpdate = Future<void>.value();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_setup());
  }

  Future<void> _setup() async {
    try {
      _previousConfiguration = await _offline.getConfiguration();
      if (!mounted) return;
      await _configure();
      if (!mounted) return;
      await _offline.initialize();
      if (!mounted) return;
      await _offline.refreshMapResources();
      if (!mounted) return;
      final supported = await _offline.isMapDownloadSupported();
      if (!mounted) return;
      if (!supported) throw StateError('Regional offline maps require TomTom.');
      final page = await _offline.beginDownloadPage();
      if (!mounted) {
        await _offline.endDownloadPage(page);
        return;
      }
      _pageId = page;
      _subscription = _offline.progress.listen((rows) {
        if (!mounted) return;
        setState(() {
          _progress = {for (final row in rows) row.regionId: row};
        });
        // Installed records are authoritative even if completed tasks disappear.
        _installedRefresh?.cancel();
        _installedRefresh = Timer(const Duration(milliseconds: 250), () {
          if (mounted) unawaited(_refreshInstalled());
        });
      }, onError: (Object error) => _show(error.toString()));
      setState(() {
        _ready = true;
        _message =
            'Load available regions online, or use installed data offline.';
      });
      await _refreshInstalled();
    } catch (error) {
      _show(error.toString());
    }
  }

  Future<void> _configure() =>
      _offline.configure(routeMode: _mode, networkPolicy: _downloadPolicy);

  void _show(String message) {
    if (mounted) {
      setState(() {
        _message = message;
      });
    }
  }

  Future<void> _refreshInstalled() async {
    try {
      final installed = await _offline.listInstalledMapRegions();
      final preview = await _offline.getPreviewStatus();
      if (mounted) {
        setState(() {
          _installed = installed;
          _preview = preview;
        });
      }
    } catch (error) {
      _show(error.toString());
    }
  }

  Future<void> _loadRegions() async {
    setState(() {
      _loading = true;
    });
    try {
      await _offline.syncRegions();
      final catalog = await _offline.fetchRegions(country: _country.text);
      if (!mounted) return;
      setState(() {
        _catalog = catalog;
      });
      _show([catalog.routingError, catalog.mapError, catalog.installedMapError]
              .whereType<String>()
              .join('\n')
              .isEmpty
          ? 'Region catalog loaded.'
          : [catalog.routingError, catalog.mapError, catalog.installedMapError]
              .whereType<String>()
              .join('\n'));
    } catch (error) {
      _show(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _manage(int id, String action) async {
    try {
      final result = await switch (action) {
        'download' => _offline.downloadRegion(id),
        'pause' => _offline.pauseRegion(id),
        'resume' => _offline.resumeRegion(id),
        'cancel' => _offline.cancelRegion(id),
        'delete' => _offline.deleteRegion(id),
        _ => throw ArgumentError(action),
      };
      _show(
          'Region $id — routing: ${result.routing.state}, maps: ${result.mapTiles.state}'
          '${result.hasError ? '\n${result.routing.message ?? result.mapTiles.message ?? "Inspect subtask errors."}' : ""}');
      if (!mounted) return;
      await _refreshInstalled();
      if (mounted) await _offline.refreshMapResources();
    } catch (error) {
      _show(error.toString());
      if (mounted) await _refreshInstalled();
    }
  }

  void _selectPoint(Point<double> _, LatLng coordinate) {
    setState(() {
      _routeRevision++;
      _calculating = false;
      if (_origin == null || _destination != null) {
        _origin = coordinate;
        _destination = null;
      } else {
        _destination = coordinate;
      }
      _routes = [];
    });
    unawaited(_clearRoute());
  }

  Future<void> _clearRoute() async {
    await _renderRoutes(const [], _routeRevision);
  }

  Future<void> _renderRoutes(List<DirectionsRoute> routes, int revision) {
    // Serialize source updates so clearing a changed selection also runs after
    // any earlier draw that was already in progress.
    return _mapUpdate = _mapUpdate.then<void>((_) async {
      if (!mounted || revision != _routeRevision) return;
      if (routes.isEmpty) {
        await _navigationMap?.clearRoute();
      } else {
        await _navigationMap?.drawRoute(routes);
      }
    }).catchError((Object error) => _show(error.toString()));
  }

  Future<void> _styleLoaded() {
    final revision = ++_styleRevision;
    return _mapUpdate = _mapUpdate.then<void>((_) async {
      final controller = _controller;
      if (!mounted || controller == null || revision != _styleRevision) return;
      _navigationMap?.dispose();
      _navigationMap = null;
      final map = await NavNextBillionMap.create(controller);
      if (!mounted || revision != _styleRevision) {
        map.dispose();
        return;
      }
      _navigationMap = map;
      if (_routes.isNotEmpty) await map.drawRoute(_routes);
    }).catchError((Object error) => _show(error.toString()));
  }

  Future<void> _calculate() async {
    final origin = _origin;
    final destination = _destination;
    if (origin == null || destination == null) return;
    final revision = ++_routeRevision;
    setState(() {
      _calculating = true;
      _routes = [];
    });
    try {
      final response = await NBNavigation.fetchRoute(RouteRequestParams(
        origin: origin,
        destination: destination,
        mode: ValidModes.car,
        geometry: SupportedGeometry.polyline6,
        overview: ValidOverview.full,
        alternatives: false,
      ));
      if (!mounted || revision != _routeRevision) return;
      setState(() {
        _routes = response.directionsRoutes;
      });
      _show(_routes.isEmpty
          ? response.message ?? 'No route found.'
          : 'Route source: ${response.routeSource?.name ?? "unknown"}. Turn off connectivity to test offline rerouting.');
      if (_routes.isNotEmpty) await _renderRoutes(_routes, revision);
    } catch (error) {
      if (revision == _routeRevision) _show(error.toString());
    } finally {
      if (mounted && revision == _routeRevision) {
        setState(() {
          _calculating = false;
        });
      }
    }
  }

  NavigationLauncherConfig get _launcher => NavigationLauncherConfig(
      route: _routes.first,
      routes: _routes,
      shouldSimulateRoute: _simulate,
      useCustomNavigationStyle: false);

  Future<void> _navigate({required bool embedded}) async {
    if (_routes.isEmpty) return;
    try {
      if (embedded) {
        await Navigator.of(context).push<void>(MaterialPageRoute(
            builder: (_) => _OfflineEmbeddedNavigation(options: _launcher)));
      } else {
        await NBNavigation.startNavigation(_launcher);
      }
    } catch (error) {
      _show(error.toString());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _ready) {
      unawaited(_refreshInstalled());
      unawaited(_offline
          .refreshMapResources()
          .catchError((Object error) => _show(error.toString())));
    }
  }

  String _pointLabel(LatLng? point) => point == null
      ? 'Tap map'
      : '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}';

  @override
  Widget build(BuildContext context) {
    final filter = _search.text.trim().toLowerCase();
    final regions = (_catalog?.regions ?? [])
        .where((row) =>
            row.name.toLowerCase().contains(filter) ||
            '${row.regionId}'.contains(filter))
        .toList();
    return Scaffold(
      appBar:
          AppBar(title: const Text(OfflineNavigationExample.title), actions: [
        IconButton(
            tooltip: OfflineDownloadManager.title,
            icon: const Icon(Icons.download_for_offline_outlined),
            onPressed: !_ready
                ? null
                : () async {
                    try {
                      final pageId = _pageId;
                      _pageId = null;
                      if (pageId != null) {
                        await _offline.endDownloadPage(pageId);
                      }
                      if (!context.mounted) return;
                      await Navigator.of(context).push<void>(MaterialPageRoute(
                          builder: (_) => const OfflineDownloadManager()));
                      if (!mounted || !_ready) return;
                      final newPageId = await _offline.beginDownloadPage();
                      if (!mounted) {
                        await _offline.endDownloadPage(newPageId);
                        return;
                      }
                      _pageId = newPageId;
                      final configuration = await _offline.getConfiguration();
                      if (!mounted) return;
                      setState(() {
                        _downloadPolicy = configuration.networkPolicy;
                      });
                      await _offline.refreshMapResources();
                      await _refreshInstalled();
                    } catch (error) {
                      _show(error.toString());
                    }
                  }),
      ]),
      body: Column(children: [
        SizedBox(
            height: 220,
            child: NBMap(
              initialCameraPosition: const CameraPosition(
                  target: LatLng(35.2271, -80.8431), zoom: 11),
              onMapCreated: (controller) {
                if (mounted) {
                  _controller = controller;
                } else if (!controller.disposed) {
                  controller.dispose();
                }
              },
              onStyleLoadedCallback: _styleLoaded,
              onMapClick: _selectPoint,
            )),
        Expanded(
            child: ListView.builder(
          itemCount: regions.length + 1,
          itemBuilder: (context, index) {
            if (index > 0) {
              final region = regions[index - 1];
              return ListTile(
                title: Text(region.name),
                subtitle: Text(
                    '${region.regionId} · routing ${region.routingInstalled ? "installed" : "${region.routingSizeBytes ?? 0} bytes"} · map ${region.mapSizeBytes ?? 0} bytes'),
                trailing: _controls(region.regionId),
              );
            }
            return Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_message),
                    Text(
                        'Origin: ${_pointLabel(_origin)}\nDestination: ${_pointLabel(_destination)}'),
                    DropdownButton<NavigationRouteMode>(
                      value: _mode,
                      isExpanded: true,
                      items: NavigationRouteMode.values
                          .map((mode) => DropdownMenuItem(
                              value: mode, child: Text(mode.name)))
                          .toList(),
                      onChanged: !_ready || _calculating
                          ? null
                          : (mode) async {
                              setState(() {
                                _mode = mode!;
                                _routeRevision++;
                                _routes = [];
                              });
                              unawaited(_clearRoute());
                              try {
                                await _configure();
                              } catch (error) {
                                _show(error.toString());
                              }
                            },
                    ),
                    SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Download on Wi-Fi only'),
                        value: _downloadPolicy ==
                            OfflineDownloadNetworkPolicy.wifiOnly,
                        onChanged: !_ready
                            ? null
                            : (value) async {
                                setState(() {
                                  _downloadPolicy = value
                                      ? OfflineDownloadNetworkPolicy.wifiOnly
                                      : OfflineDownloadNetworkPolicy.anyNetwork;
                                });
                                try {
                                  await _configure();
                                } catch (error) {
                                  _show(error.toString());
                                }
                              }),
                    SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Simulate navigation'),
                        value: _simulate,
                        onChanged: (value) => setState(() {
                              _simulate = value;
                            })),
                    Wrap(spacing: 8, children: [
                      FilledButton(
                          onPressed:
                              !_ready || _destination == null || _calculating
                                  ? null
                                  : _calculate,
                          child: Text(_calculating
                              ? 'Calculating…'
                              : 'Calculate route')),
                      OutlinedButton(
                          onPressed: _routes.isEmpty
                              ? null
                              : () => _navigate(embedded: false),
                          child: const Text('Navigate')),
                      OutlinedButton(
                          onPressed: _routes.isEmpty
                              ? null
                              : () => _navigate(embedded: true),
                          child: const Text('Embedded navigation')),
                    ]),
                    const Divider(),
                    Text(
                        'Preview styles: ${_preview?.stylesReady ?? false}; bundle: ${_preview?.previewBundleReady ?? "not exposed"}'),
                    const Text(
                        'Installed map packages (routing readiness is shown separately below):'),
                    for (final region in _installed)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(region.name),
                        subtitle: Text(
                            '${region.regionId} · packages complete: ${region.packagesComplete}'),
                        onTap: () async {
                          try {
                            final focused = await _controller
                                    ?.focusPreviewRegion(region.regionId) ??
                                false;
                            if (!focused) {
                              _show('Usable map coverage is not available.');
                            }
                          } catch (error) {
                            _show(error.toString());
                          }
                        },
                        trailing: _controls(region.regionId),
                      ),
                    for (final row in _progress.values.where((row) =>
                        row.routing?.state == OfflineTaskState.completed ||
                        row.overallState != OfflineTaskState.notStarted))
                      Text(
                          '${row.regionId}: routing ${row.routing?.state.name ?? "unknown"} ${row.routing?.percent ?? 0}%, '
                          'maps ${row.mapTiles?.state.name ?? "unknown"} ${row.mapTiles?.percent ?? 0}%'
                          '${row.routing?.error ?? row.mapTiles?.error ?? ""}'),
                    const Divider(),
                    TextField(
                        controller: _country,
                        decoration: const InputDecoration(
                            labelText: 'Country (full English name)')),
                    FilledButton(
                        onPressed: !_ready || _loading ? null : _loadRegions,
                        child: Text(
                            _loading ? 'Loading…' : 'Load available regions')),
                    TextField(
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                            labelText: 'Filter name or region ID')),
                  ],
                ));
          },
        )),
      ]),
    );
  }

  Widget _controls(int id) => PopupMenuButton<String>(
        enabled: _ready,
        onSelected: (action) => unawaited(_manage(id, action)),
        itemBuilder: (_) => ['download', 'pause', 'resume', 'cancel', 'delete']
            .map((action) => PopupMenuItem(value: action, child: Text(action)))
            .toList(),
      );

  @override
  void dispose() {
    _routeRevision++;
    _styleRevision++;
    _navigationMap?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _installedRefresh?.cancel();
    unawaited(_subscription?.cancel());
    final page = _pageId;
    if (page != null) {
      unawaited(_offline.endDownloadPage(page).catchError((Object _) {}));
    }
    final previous = _previousConfiguration;
    if (previous != null) {
      unawaited(_offline
          .configure(
              routeMode: previous.routeMode,
              networkPolicy: previous.networkPolicy)
          .catchError((Object _) {}));
    }
    _country.dispose();
    _search.dispose();
    super.dispose();
  }
}

class _OfflineEmbeddedNavigation extends StatelessWidget {
  final NavigationLauncherConfig options;
  const _OfflineEmbeddedNavigation({required this.options});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Offline navigation')),
        body: NBNavigationView(
          navigationOptions: options,
          onNavigationCancelling: () {
            if (context.mounted) Navigator.of(context).pop();
          },
          onRerouteFailureCallback: (error) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error ?? 'Rerouting failed')));
            }
          },
          onRerouteAlongCallback: (_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Route updated')));
            }
          },
        ),
      );
}
