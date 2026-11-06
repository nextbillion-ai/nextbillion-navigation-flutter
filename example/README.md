# nb_navigation_flutter_example

Demonstrates how to use the nb_navigation_flutter plugin.

## Getting Started
Run the example project to see how to use the plugin.
* Option1 : Run with the following command:
```shell
flutter run --dart-define=ACCESS_KEY=your_access_key
```
* Option2: Start without a build-time key and enter it on the home screen. The
  runtime entry is obscured and is not saved to files or diagnostic history.

### iOS integration

The example uses Swift Package Manager exclusively. SPM is already enabled in
`pubspec.yaml`; run `flutter pub get` from the example directory before building
or opening `ios/Runner.xcworkspace`. Native dependencies are declared in the
plugin's `ios/nb_navigation_flutter/Package.swift`.

## Offline download manager

Open **Offline Downloads** from the home screen. The page uses the Navigation SDK's
native routing and map download APIs and does not require location permission.

- **Available**: country/name/ID filtering, download size, update availability.
- **Tasks**: independent routing tile counts and map byte counts; download,
  pause, resume, cancel, and deletion confirmation.
- **Installed**: local packages and completeness, available without an online catalog.
- **Diagnostics**: all five routing modes, network policy, configuration/support checks,
  idempotent initialization, preview refresh, health, progress subscription,
  page-session rebinding, shutdown/reinitialization, and the last 80 method calls.
- Every region's information button opens versions, installation state, errors,
  and local-only or fetch-if-missing boundary queries. Call details and records
  can be copied; credentials are redacted.

Shutdown is process-wide. Close navigation first. Leaving the manager only
releases its own subscription/session and does not cancel SDK downloads.

## Physical-device acceptance

The account-free suite calls the actual native bridge, checks every data method's
missing-account protection, platform-specific policy behavior, shutdown, and the
real manager's error/diagnostic UI:

```sh
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/offline_bridge_test.dart --no-dds -d <physical-device-id>
```

For real downloads, copy `offline_test_config.example.json` to
`offline_test_config.local.json` (ignored by Git) and fill in a valid `ACCESS_KEY`.
Optionally select a fresh region with `OFFLINE_TEST_REGION_ID`; zero selects a
small region supporting both datasets within `OFFLINE_TEST_MAX_BYTES`.
`OFFLINE_TEST_MIN_ROUTING_BYTES` defaults to 20 MiB so pause/resume/cancel can
reach an active transfer before a small or cached routing download completes.

```sh
flutter drive --driver=test_driver/integration_test.dart \
  --target=integration_test/offline_download_device_test.dart \
  --dart-define-from-file=offline_test_config.local.json \
  --device-connection attached --no-dds -d <physical-device-id>
```

This suite requires successful catalog/boundary requests, an active task before
pause/resume/cancel, complete routing and map installation, local restoration
after engine shutdown/reinitialization, and actual deletion of its test region.
It excludes installed/partial/active regions so it never deliberately deletes
pre-existing user data. Cleanup is bounded and failures are recorded.

The driver writes `build/integration_response_data.json`, including per-method
parameters, responses, timings, failure stage, and cleanup outcomes even on a
failure. A successful engine reinitialization test is distinct from a process
restart or a physically disconnected network test; those flags remain false
until separately exercised.

## Device verification — 2026-11-05

| Device | Coverage | Result |
| --- | --- | --- |
| USB iPhone, iOS 26.6.1 | 19 offline methods plus progress subscription/cancellation; 51 recorded calls | Passed |
| Same USB iPhone | Missing-account guards, policies, manager/diagnostic UI, malformed route geometry | 5 cases passed |
| Samsung SM-E5260, Android 13 | Same native bridge suite | 5 cases passed |
| Local regression | Plugin library and widgets / example | 250 passed, 0 skipped / 11 passed |

The latest strict USB acceptance used a fresh Lexington, Virginia region (6148). It checked
real routing activity before pause and cancel, required successful routing/map
control results, completed both installations, restored local state after engine
shutdown/reinitialization, and deleted the test region. Cleanup reported no
errors. The run also exposed and verified fixes for iOS 4.1.4 boundary-detail
loading and Android shutdown before engine registration.

Per-method parameters, results, timings and cleanup outcomes are in
`build/device-test-reports/ios-usb-download-lifecycle-final.json`; the concise
summary is `build/device-test-reports/summary.json`. These build artifacts are
ignored by Git. Physical network disconnection, OS process cold starts, and
deviation/rerouting were not exercised by this download-management suite.
Those scenarios passed the separate navigation acceptance below. Detailed review,
coverage and remaining limits are in [the test report](TEST_REPORT_2026-11-05.md).

### Disconnected navigation and cold process launch

`ios/Tests/run_offline_acceptance.sh <USB-iPhone-UDID> <absolute-private-config-path>`
runs the separate `OfflineNavigationAcceptance` Xcode UI-test scheme. It uses an
AOT build so XCTest can terminate and launch the same installed application
without a Flutter debugger or a reinstall. Keep the phone unlocked and let the
test finish so its teardown can restore the original Wi-Fi and airplane states.
Use a device with its system language set to English for permission-alert checks.

The test downloads a fresh region, switches airplane mode on and Wi-Fi off,
verifies network unreachability, calculates an offline route, and checks actual
base-map features. It then terminates the OS process, relaunches without
reinstalling, and repeats the offline checks. System GPS input follows a real
road detour; full-screen and embedded navigation must both produce a real SDK
reroute with changed geometry and an offline source. Embedded navigation must
also deliver the Dart reroute callback. This covers system location input on a
physical phone; it does not replace an outdoor driving test.

The example-only native probes are enabled by the UI-test environment and
compilation condition. Launch phases invoke the same Dart actions as the test
page; the probes never supply routes or fake callbacks.
The runner stores per-process calls, results and screenshots under
`build/device-test-reports`. Only the fresh test region is deleted. On failure,
its persisted ownership record allows cleanup on a subsequent run.

