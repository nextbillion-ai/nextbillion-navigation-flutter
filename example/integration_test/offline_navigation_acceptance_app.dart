import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_navigation_flutter/nb_navigation_flutter.dart';
import 'package:nb_navigation_flutter_example/offline_diagnostics.dart';

/// Installed once, then driven by OfflineNavigationUITests across real process
/// launches and system network changes. Every route and map uses the real SDK.
void main() => runApp(const MaterialApp(home: _AcceptancePage()));

class _AcceptancePage extends StatefulWidget {
  const _AcceptancePage();
  @override
  State<_AcceptancePage> createState() => _AcceptanceState();
}

class _AcceptanceState extends State<_AcceptancePage> {
  static const host = MethodChannel('example/offline_acceptance');
  static const key = String.fromEnvironment('ACCESS_KEY');
  final offline = NBNavigation.offline;
  final log = OfflineMethodLog(limit: 2000);
  String status = 'BOOTING';
  String message = '';
  late Directory directory;
  Map<String, dynamic>? fixture;
  Map<String, dynamic> report = {};
  DirectionsRoute? route;
  NextbillionMapController? map;
  NavNextBillionMap? overlay;
  bool styleLoaded = false;
  bool embedded = false;
  int dartReroutes = 0;
  int dartProgress = 0;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_boot());
  }

  Future<void> _boot() async {
    try {
      check(
          key.isNotEmpty, 'Supply ACCESS_KEY through the private test config');
      directory = Directory((await host.invokeMethod<String>('documents'))!);
      final f = File('${directory.path}/offline-acceptance-fixture.json');
      if (await f.exists()) {
        fixture = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      }
      final r = File('${directory.path}/offline-acceptance-report.json');
      if (await r.exists()) {
        report = jsonDecode(await r.readAsString()) as Map<String, dynamic>;
      }
      await NBNavigation.initNextBillionWithTileServer(
          accessKey: key, server: WellKnownTileServer.nbTomtom);
      if (mounted) {
        setState(() {
          status = fixture == null ? 'READY' : 'FIXTURE_READY';
        });
      }
      final phase = await host.invokeMethod<String>('phase');
      switch (phase) {
        case 'prepare':
          // A previous failed run owns this fixture. Remove only its data before
          // a new acceptance run so every complete run starts with fresh files.
          if (fixture?['ownedRegion'] == true) {
            await offline.initialize();
            await _cleanup();
            check(status == 'CLEANUP_OK',
                'Previous test data could not be cleaned');
            fixture = null;
          }
          report = {};
          await _prepare();
        case 'offline':
          await _offlineCheck();
        case 'full':
          await _offlineCheck();
          if (status == 'OFFLINE_OK') await _navigate(false);
        case 'embedded':
          await _offlineCheck();
          if (status == 'OFFLINE_OK') await _navigate(true);
        case 'cleanup':
          await offline.initialize();
          await _cleanup();
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          status = 'BOOT_FAILED';
          message = error.toString();
        });
      }
    }
  }

  Future<void> _save() async {
    final processes =
        Map<String, dynamic>.from(report['processes'] as Map? ?? {});
    processes['$pid'] = log.entries.reversed.toList();
    report['processes'] = processes;
    final text =
        jsonEncode(offlineDebugValue(report)).replaceAll(key, '[REDACTED]');
    final tmp = File('${directory.path}/offline-acceptance-report.tmp');
    await tmp.writeAsString(text, flush: true);
    await tmp.rename('${directory.path}/offline-acceptance-report.json');
  }

  Future<T> call<T>(String name, Future<T> Function() action) async {
    if (mounted) {
      setState(() {
        message = name;
      });
    }
    final pending = log.run(
        name,
        () => action().timeout(name == 'downloadRegion'
            ? const Duration(minutes: 15)
            : const Duration(seconds: 90)));
    await _save();
    try {
      return await pending;
    } finally {
      await _save();
    }
  }

  void check(bool value, String reason) {
    if (!value) throw StateError(reason);
  }

  Future<void> _run(
      String phase, Future<void> Function() action, String success) async {
    if (busy) return;
    setState(() {
      busy = true;
      status = '${phase}_RUNNING';
      message = '';
    });
    try {
      await action();
      report[phase] = {
        'passed': true,
        'pid': pid,
        'time': DateTime.now().toUtc().toIso8601String()
      };
      await _save();
      if (mounted) {
        setState(() {
          status = success;
        });
      }
    } catch (error) {
      report[phase] = {
        'passed': false,
        'pid': pid,
        'error': offlineDebugValue(error)
      };
      await _save();
      if (mounted) {
        setState(() {
          status = '${phase}_FAILED';
          message =
              redactOfflineText(error.toString()).replaceAll(key, '[REDACTED]');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
        });
      }
    }
  }

  Future<void> _prepare() => _run('PREPARE', () async {
        await call(
            'configure.online',
            () => offline.configure(
                networkPolicy: OfflineDownloadNetworkPolicy.anyNetwork));
        await call('initialize', offline.initialize);
        final page = await call('beginDownloadPage', offline.beginDownloadPage);
        try {
          await call(
              'syncRegions.force', () => offline.syncRegions(force: true));
          final catalog = await call('fetchRegions', offline.fetchRegions);
          final installed = await call(
              'listInstalledMapRegions', offline.listInstalledMapRegions);
          final allowed = catalog.regions
              .where((r) =>
                  r.hasRouting &&
                  r.hasMapTiles &&
                  !r.routingInstalled &&
                  !r.routingPartial &&
                  !installed.any((m) => m.regionId == r.regionId) &&
                  (r.routingSizeBytes ?? 0) + (r.mapSizeBytes ?? 0) <
                      150 * 1024 * 1024)
              .toList();
          check(allowed.isNotEmpty, 'No fresh test region available');
          OfflineNavigationRegion? selected;
          for (final name in [
            'Falls Church',
            'Manassas Park',
            'Colonial Heights',
            'Alexandria',
            'Hooker'
          ]) {
            final matches = allowed.where((r) => r.name == name);
            if (matches.isNotEmpty) {
              selected = matches.first;
              break;
            }
          }
          selected ??= allowed.first;
          final id = selected.regionId;
          final boundary = await call(
              'getRegionBoundary', () => offline.getRegionBoundary(id));
          final bounds = _bounds(jsonDecode(boundary));
          final plan = await _plan(bounds);
          // Persist ownership before mutation so cleanup remains possible after a crash.
          fixture = {
            'regionId': id,
            'name': selected.name,
            'ownedRegion': true,
            'preparePid': pid,
            ...plan
          };
          await File('${directory.path}/offline-acceptance-fixture.json')
              .writeAsString(jsonEncode(fixture), flush: true);
          final result =
              await call('downloadRegion', () => offline.downloadRegion(id));
          check(!result.hasError, offlineDebugJson(result));
          final watch = Stopwatch()..start();
          while (!(await offline.listInstalledMapRegions())
              .any((r) => r.regionId == id && r.packagesComplete)) {
            check(watch.elapsed < const Duration(minutes: 15),
                'Map install timed out');
            await Future<void>.delayed(const Duration(seconds: 1));
          }
          await call('refreshMapResources', offline.refreshMapResources);
          final preview =
              await call('getPreviewStatus', offline.getPreviewStatus);
          check(
              preview.stylesReady &&
                  preview.previewBundleReady != false &&
                  preview.spritesReady != false &&
                  preview.tileJsonReady != false,
              'Offline display bundle is incomplete');
          report['fixture'] = fixture;
        } finally {
          await offline.endDownloadPage(page);
        }
      }, 'PREPARE_OK');

  Future<Map<String, dynamic>> _plan(List<double> b) async {
    final width = b[2] - b[0], height = b[3] - b[1];
    for (final y in [.5, .35, .65]) {
      final start = LatLng(b[1] + height * y, b[0] + width * .3);
      final end = LatLng(b[1] + height * y, b[0] + width * .7);
      try {
        final original = await NBNavigation.fetchRoute(RouteRequestParams(
            origin: start,
            destination: end,
            geometry: SupportedGeometry.polyline6));
        if (original.directionsRoutes.isEmpty) continue;
        final points = decode(original.directionsRoutes.first.geometry!, 6);
        if (points.length < 2 ||
            !_inside(points, b) ||
            (original.directionsRoutes.first.distance ?? 0) < 700) {
          continue;
        }
        for (final offset in [
          LatLng(height * .15, 0),
          LatLng(-height * .15, 0),
          LatLng(0, width * .15)
        ]) {
          final waypoint = LatLng(
              (start.latitude + end.latitude) / 2 + offset.latitude,
              (start.longitude + end.longitude) / 2 + offset.longitude);
          final detour = await NBNavigation.fetchRoute(RouteRequestParams(
              origin: points.first,
              destination: points.last,
              waypoints: [waypoint],
              geometry: SupportedGeometry.polyline6));
          if (detour.directionsRoutes.isEmpty) continue;
          final shape = decode(detour.directionsRoutes.first.geometry!, 6);
          if (!_inside(shape, b)) continue;
          final samples = _sample(shape, 20);
          final deviated =
              samples.indexWhere((p) => _distanceToLine(p, points) > 140);
          if (deviated < 0 || deviated > 110) continue;
          final track =
              samples.take(math.min(samples.length, deviated + 8)).toList();
          return {
            'origin': _jsonPoint(points.first),
            'destination': _jsonPoint(points.last),
            'track': track.map(_jsonPoint).toList(),
            'divergenceIndex': deviated
          };
        }
      } catch (error) {
        message = redactOfflineText(error.toString());
      }
    }
    throw StateError(
        'Could not plan an in-region route and a genuine road detour');
  }

  Future<void> _offlineCheck() => _run('OFFLINE', () async {
        check(fixture != null, 'No persisted fixture');
        report['offlineStarted'] = {'pid': pid};
        await _save();
        final network = Map<String, dynamic>.from(
            (await host.invokeMapMethod<String, dynamic>('network'))!);
        bool connected = false;
        try {
          final socket = await Socket.connect('api.nextbillion.io', 443,
              timeout: const Duration(seconds: 3));
          connected = true;
          socket.destroy();
        } catch (_) {}
        check(
            network['wifi'] == false &&
                network['cellular'] == false &&
                !connected,
            'Device is still online: $network');
        report['network'] = {...network, 'apiSocketReachable': connected};
        report['coldStart'] = {
          'preparePid': fixture!['preparePid'],
          'currentPid': pid,
          'differentProcess': fixture!['preparePid'] != pid
        };
        await call(
            'configure.offlineOnly',
            () =>
                offline.configure(routeMode: NavigationRouteMode.offlineOnly));
        await call('initialize.offline', offline.initialize);
        await call('refreshMapResources.offline', offline.refreshMapResources);
        report['offlinePreview'] = offlineDebugValue(
            await call('getPreviewStatus.offline', offline.getPreviewStatus));
        final id = fixture!['regionId'] as int;
        check(
            (await call('listInstalledMapRegions.offline',
                    offline.listInstalledMapRegions))
                .any((r) => r.regionId == id && r.packagesComplete),
            'Installed map missing after restart');
        await call('getRegionBoundary.local',
            () => offline.getRegionBoundary(id, fetchIfMissing: false));
        final response = await call(
            'fetchRoute.offline',
            () => NBNavigation.fetchRoute(RouteRequestParams(
                origin: _point(fixture!['origin']),
                destination: _point(fixture!['destination']),
                geometry: SupportedGeometry.polyline6)));
        check(
            response.routeSource == NavigationRouteSource.offline &&
                response.directionsRoutes.isNotEmpty,
            'Offline route failed: ${response.message} ${response.errorDetails}');
        route = response.directionsRoutes.first;
        if (map == null) styleLoaded = false;
        setState(() {});
        final watch = Stopwatch()..start();
        while (!styleLoaded || map == null) {
          check(watch.elapsed < const Duration(seconds: 50),
              'Offline map style did not load');
          await Future<void>.delayed(const Duration(milliseconds: 250));
        }
        var rendered = <String, dynamic>{};
        while ((rendered['featureCount'] as int? ?? 0) == 0) {
          // The Flutter API requires layer IDs; an empty list queries no layers
          // on iOS. Read all real base-map features through the native probe.
          rendered = Map<String, dynamic>.from(
              (await host.invokeMapMethod<String, dynamic>('mapSnapshot'))!);
          report['mapProbe'] = rendered;
          check(watch.elapsed < const Duration(seconds: 60),
              'No map features rendered while disconnected');
          if ((rendered['featureCount'] as int? ?? 0) == 0) {
            await Future<void>.delayed(const Duration(milliseconds: 500));
          }
        }
        overlay?.dispose();
        overlay = await NavNextBillionMap.create(map!);
        await overlay!.drawRoute([route!]);
        report['offlineMap'] = {
          ...rendered,
          'routeDistance': route!.distance,
          'source': response.routeSource!.name
        };
      }, 'OFFLINE_OK');

  Future<void> _navigate(bool embed) =>
      _run(embed ? 'EMBEDDED' : 'FULL', () async {
        check(route != null, 'Run offline validation first');
        dartReroutes = 0;
        dartProgress = 0;
        await host.invokeMethod<void>('beginTracking');
        const permissions =
            MethodChannel('nb_navigation_flutter_example/permissions');
        check(
            await permissions.invokeMethod<bool>('requestLocationPermission') ==
                true,
            'Location permission denied');
        final config = NavigationLauncherConfig(
            route: route!,
            routes: [route!],
            shouldSimulateRoute: false,
            useCustomNavigationStyle: false);
        if (embed) {
          overlay?.dispose();
          overlay = null;
          map = null;
          styleLoaded = false;
          setState(() {
            embedded = true;
          });
        } else {
          await NBNavigation.startNavigation(config);
        }
        String? baseline;
        Map<String, dynamic> last = {};
        final watch = Stopwatch()..start();
        while (true) {
          check(watch.elapsed < const Duration(minutes: 3),
              'No successful real SDK reroute: $last; Dart reroutes=$dartReroutes');
          last = Map<String, dynamic>.from((await host
              .invokeMapMethod<String, dynamic>('navigationSnapshot'))!);
          if (last['active'] == true) {
            baseline ??= last['geometryHash'] as String?;
          }
          final changed = baseline != null && last['geometryHash'] != baseline;
          if ((last['didReroute'] as int? ?? 0) > 0 &&
              changed &&
              last['routeSource'] == 'offline' &&
              (!embed || dartReroutes > 0)) {
            break;
          }
          await Future<void>.delayed(const Duration(milliseconds: 400));
        }
        report[embed ? 'embeddedNavigation' : 'fullNavigation'] = {
          ...last,
          'geometryChanged': true,
          'dartRerouteCallbacks': dartReroutes,
          'dartProgressCallbacks': dartProgress
        };
        await host.invokeMethod<void>('finishNavigation');
        if (embed && mounted) {
          setState(() {
            embedded = false;
          });
        }
      }, embed ? 'EMBEDDED_OK' : 'FULL_OK');

  Future<void> _cleanup() => _run('CLEANUP', () async {
        if (fixture?['ownedRegion'] == true) {
          final result =
              await offline.deleteRegion(fixture!['regionId'] as int);
          check(!result.hasError, offlineDebugJson(result));
          final watch = Stopwatch()..start();
          while ((await offline.listInstalledMapRegions())
              .any((r) => r.regionId == fixture!['regionId'])) {
            check(watch.elapsed < const Duration(seconds: 90),
                'Map deletion did not complete');
            await Future<void>.delayed(const Duration(milliseconds: 500));
          }
        }
        overlay?.dispose();
        overlay = null;
        await offline.shutdown();
        await File('${directory.path}/offline-acceptance-fixture.json')
            .delete();
      }, 'CLEANUP_OK');

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Offline Navigation Acceptance')),
      body: Column(children: [
        Text(status, key: const Key('acceptance-status')),
        Text('PID:$pid'),
        if (fixture != null)
          Semantics(
              label: 'FIXTURE:${jsonEncode(fixture)}',
              excludeSemantics: true,
              child: const Text('Region and road track saved')),
        if (message.isNotEmpty) Text(message, maxLines: 3),
        Wrap(children: [
          ElevatedButton(
              onPressed: busy || fixture != null ? null : _prepare,
              child: const Text('Prepare Offline Data')),
          ElevatedButton(
              onPressed: busy || fixture == null ? null : _offlineCheck,
              child: const Text('Verify Offline Mode')),
          ElevatedButton(
              onPressed: busy || route == null ? null : () => _navigate(false),
              child: const Text('Start Full-Screen Navigation')),
          ElevatedButton(
              onPressed: busy || route == null ? null : () => _navigate(true),
              child: const Text('Start Embedded Navigation')),
          ElevatedButton(
              onPressed: busy || fixture == null ? null : _cleanup,
              child: const Text('Clean Up Test Region')),
        ]),
        if (route != null && !embedded)
          SizedBox(
              height: 220,
              child: NBMap(
                  initialCameraPosition: CameraPosition(
                      target: _point(fixture!['origin']), zoom: 14),
                  onMapCreated: (value) {
                    map = value;
                  },
                  onStyleLoadedCallback: () {
                    styleLoaded = true;
                  })),
        if (embedded)
          Expanded(
              child: NBNavigationView(
            navigationOptions: NavigationLauncherConfig(
                route: route!,
                routes: [route!],
                shouldSimulateRoute: false,
                useCustomNavigationStyle: false),
            onProgressChange: (_) {
              dartProgress++;
            },
            onRerouteAlongCallback: (value) {
              if (value != null) dartReroutes++;
            },
            onNavigationCancelling: () {
              if (mounted) {
                setState(() {
                  embedded = false;
                });
              }
            },
          )),
      ]));

  @override
  void dispose() {
    overlay?.dispose();
    super.dispose();
  }
}

LatLng _point(dynamic value) {
  final row = value as List;
  return LatLng((row[0] as num).toDouble(), (row[1] as num).toDouble());
}

List<double> _jsonPoint(LatLng p) => [p.latitude, p.longitude];
List<double> _bounds(dynamic geo) {
  final points = <List<num>>[];
  void visit(dynamic value) {
    if (value is List) {
      if (value.length >= 2 && value[0] is num && value[1] is num) {
        points.add(value.cast<num>());
      } else {
        for (final child in value) {
          visit(child);
        }
      }
    } else if (value is Map) {
      for (final name in ['coordinates', 'geometry', 'features']) {
        if (value.containsKey(name)) visit(value[name]);
      }
    }
  }

  visit(geo);
  if (points.isEmpty) throw StateError('Region boundary has no coordinates');
  return [
    points.map((p) => p[0].toDouble()).reduce(math.min),
    points.map((p) => p[1].toDouble()).reduce(math.min),
    points.map((p) => p[0].toDouble()).reduce(math.max),
    points.map((p) => p[1].toDouble()).reduce(math.max)
  ];
}

bool _inside(List<LatLng> points, List<double> b) => points.every((p) =>
    p.longitude >= b[0] &&
    p.longitude <= b[2] &&
    p.latitude >= b[1] &&
    p.latitude <= b[3]);
double _distance(LatLng a, LatLng b) =>
    math.sqrt(math.pow((a.latitude - b.latitude) * 111320, 2) +
        math.pow(
            (a.longitude - b.longitude) *
                111320 *
                math.cos(a.latitude * math.pi / 180),
            2));
double _distanceToLine(LatLng p, List<LatLng> line) {
  var best = double.infinity;
  final scale = math.cos(p.latitude * math.pi / 180);
  for (var i = 1; i < line.length; i++) {
    final ax = (line[i - 1].longitude - p.longitude) * scale,
        ay = line[i - 1].latitude - p.latitude;
    final bx = (line[i].longitude - p.longitude) * scale,
        by = line[i].latitude - p.latitude;
    final dx = bx - ax, dy = by - ay, length = dx * dx + dy * dy;
    final t =
        length == 0 ? 0.0 : (-(ax * dx + ay * dy) / length).clamp(0.0, 1.0);
    best = math.min(
        best,
        math.sqrt(math.pow(ax + t * dx, 2) + math.pow(ay + t * dy, 2)) *
            111320);
  }
  return best;
}

List<LatLng> _sample(List<LatLng> line, double spacing) {
  if (line.isEmpty) return [];
  final result = <LatLng>[line.first];
  var remaining = spacing;
  for (var i = 1; i < line.length; i++) {
    var start = line[i - 1];
    final end = line[i];
    var length = _distance(start, end);
    while (length >= remaining && length > 0) {
      final t = remaining / length;
      start = LatLng(start.latitude + (end.latitude - start.latitude) * t,
          start.longitude + (end.longitude - start.longitude) * t);
      result.add(start);
      length = _distance(start, end);
      remaining = spacing;
    }
    remaining -= length;
  }
  return result;
}
