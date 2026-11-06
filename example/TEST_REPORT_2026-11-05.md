# Offline Navigation Review and Test Report

Environment: Flutter 3.44 / Dart 3.12; iOS Navigation 4.1.4, Android Navigation 3.1.2, Maps Flutter 4.0.0-beta.1.

## Review findings and fixes

The tested feature covers regional downloads, installed-data restoration, disconnected route calculation, map rendering, and offline rerouting. Both routing and map operations use the Navigation SDK. Flutter retains each subsystem's outcome so partial failure remains visible.

| Finding | Fix and verification |
| --- | --- |
| **iOS embedded navigation crashed on exit** | The physical-device report showed `EXC_BREAKPOINT` through `OrnamentsController.stop()`, `NavigationViewController` deinitialization, and `EmbeddedNavigationView.dispose()`. Call the complete `endNavigation()` operation before releasing the controller, while its weak view references are still valid. Two subsequent device acceptance runs completed rerouting and teardown. |
| Empty routes or incomplete coordinates could crash native route selection | Validate coordinate length, finite values, and geographic bounds on both platforms. Skip lines with fewer than two points and remove forced unwraps on iOS. Native and device tests cover malformed input and preservation of original route indices. |
| Style reloads registered duplicate click listeners; selection results could arrive after disposal | Use named, removable listeners; serialize style rebuilding and route drawing; ignore results after disposal; handle selection and drawing failures. Tests cover repeated initialization, unrelated listeners, and delayed completion. |
| Fused iOS offline routes lost road metadata when original JSON was absent | Serialize current SDK road references, exits, destinations, roundabout names, and pronunciations. Native round trips also verify lanes, sign images, and intersection indices. |
| Map resources were not consistently ready during cold starts | Refresh SDK map resources after offline initialization. Repeated cold launches after a fresh download check real rendered map features instead of inferring display readiness from download completion. |
| Diagnostic output could expose credentials | Redact typed catalog errors and JSON credentials. Remove another example's logging of complete route request parameters. |
| Legacy tests missed relevant behavior | Supply valid route options, wait for the native ready event, and complete the two previously skipped route tests. |

A real completion race was also observed: a small routing region can finish before cancellation arrives. Routing then returns `region is not downloading` while map cancellation succeeds. The UI must retain these independent outcomes. Successful control acceptance uses a fresh routing dataset of at least 20 MiB and still requires zero error codes from both subsystems.

## Test results

| Test | Result |
| --- | --- |
| All plugin tests under `test` and `widget_test` | **250 passed, 0 skipped** |
| All example unit and widget tests | **11 passed** |
| Repository-wide static analysis | **0 errors, 0 warnings**; 30 existing test-code style hints |
| Native iOS regression with actual SDK binaries | 5 checks passed, including 20 view deallocations and listener cleanup |
| USB iPhone: successful offline-method lifecycle | **19 methods plus progress subscription/cancellation; 51 calls passed; no cleanup errors** |
| USB iPhone: native guards, policies, and management UI | 5 cases passed |
| Samsung SM-E5260 / Android 13: the same native bridge suite | 5 cases passed |
| Android debug / release builds | Passed; release includes code shrinking; APK size 125.3 MB |
| iOS Simulator debug / physical-device Profile builds | Passed |

Covered methods: `configure`, `getConfiguration`, `initialize`, `isMapDownloadSupported`, `syncRegions`, `fetchRegions`, `listInstalledMapRegions`, `downloadRegion`, `pauseRegion`, `resumeRegion`, `cancelRegion`, `deleteRegion`, `getPreviewStatus`, `healthCheck`, `getRegionBoundary`, `beginDownloadPage`, `endDownloadPage`, `refreshMapResources`, and `shutdown`, plus progress subscription and cancellation.

The successful download-control rerun used **Lexington, Virginia (6148)**: 21,341,304 routing bytes and 1,068,854 map bytes. Pause, resume, and cancellation reached a real routing transfer; both subsystem error codes were zero. Complete installation, local restoration after engine shutdown/reinitialization, the actual management page's diagnostics, deletion, and cleanup also passed.

### USB iPhone: disconnected navigation, cold starts, and rerouting

The device was a wired iPhone 12 mini running iOS 26.6.1. The final independent acceptance started with a fresh **Falls Church (6119)** download:

1. Enable airplane mode and disable Wi-Fi through system settings. The network path was `unsatisfied`, Wi-Fi and cellular were unavailable, and the API socket connection failed.
2. Terminate and relaunch the application without reinstalling it. The test crossed OS processes 1266, 1267, 1268, 1269, 1271, and 1273; local data and offline routing remained available.
3. Calculate an approximately **2,206 m** initial route with source `offline`. The disconnected map rendered **191 features across 96 style layers**, with device screenshots retained.
4. Full-screen navigation received one actual SDK reroute with changed geometry, source `offline`, and zero reroute failures.
5. Embedded navigation also received one offline reroute. Dart received **1 reroute callback and 37 progress callbacks**. Teardown and subsequent cleanup completed without reproducing the earlier exit crash.
6. Delete the owned test region, restore the original airplane/Wi-Fi settings, and clear the system location override.

XCTest supplied a real road detour through the system location interface. The actual SDK performed routing, rendering, and callbacks; no route or reroute callback was fabricated. This is physical-device coverage; **outdoor driving has not been tested**.

## Evidence and reproduction

- Summary: [`build/device-test-reports/summary.json`](build/device-test-reports/summary.json).
- The 51 method calls: [`ios-usb-download-lifecycle-final.json`](build/device-test-reports/ios-usb-download-lifecycle-final.json).
- Disconnection, process restarts, and reroutes: [`report.json`](build/device-test-reports/offline-navigation-20261105-165519/report.json). The adjacent `acceptance.xcresult` and `attachments` contain system test results, recordings, and screenshots.
- Native, plugin, example, bridge, and build logs are under `build/device-test-reports`. Git ignores these generated artifacts.
- Reproduction entry point: [`ios/Tests/run_offline_acceptance.sh`](ios/Tests/run_offline_acceptance.sh). Credentials come from a private local configuration file.

Use `flutter build apk --release` when switching to a release build so platform registration is regenerated. In this Flutter 3.44 environment, `--no-pub` can retain debug-only plugin registration and leave release compilation unable to find `integration_test`. Regenerating platform files allowed the release build to succeed.

## Scope and limits

The repaired navigation teardown did not reproduce the observed crash, and native lifetime checks found no registered handlers retaining disposed views. Instruments heap snapshots and multi-hour download/navigation stress tests have not been performed. These checks cannot establish that the entire third-party SDK is free of memory leaks.

Android coverage in this run includes builds, native guards, and policies. Actual downloads and disconnected rerouting used the USB iPhone selected by the user; those results do not establish Android device rerouting coverage. The regional acceptance also does not exhaust long trips across multiple offline regions, custom styles, every vehicle type, or outdoor weak-GPS conditions.
