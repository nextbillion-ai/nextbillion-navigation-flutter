#!/usr/bin/env bash
set -euo pipefail

# The XCTest restores Wi-Fi/airplane mode in tearDown, including failed tests.
# Keep the phone unlocked. Do not interrupt the runner while its network is off.
task_example="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
task_device="${1:?Supply the USB iPhone UDID}"
task_config="${2:?Supply an absolute path to the private ACCESS_KEY JSON file}"
task_flutter="${FLUTTER_BIN:-flutter}"
task_report="$task_example/build/device-test-reports/offline-navigation-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$task_report"
cd "$task_example"

# AOT is required to launch the same app independently after terminating it.
"$task_flutter" build ios --profile --config-only --no-pub \
  --target=integration_test/offline_navigation_acceptance_app.dart \
  --dart-define-from-file="$task_config"

task_status=0
xcodebuild test -workspace ios/Runner.xcworkspace \
  -scheme OfflineNavigationAcceptance -configuration Profile \
  -destination "platform=iOS,id=$task_device" -parallel-testing-enabled NO \
  -allowProvisioningUpdates SWIFT_ACTIVE_COMPILATION_CONDITIONS=OFFLINE_ACCEPTANCE_UI_TEST \
  -resultBundlePath "$task_report/acceptance.xcresult" \
  > "$task_report/xcode.log" 2>&1 || task_status=$?

xcrun devicectl device copy from --device "$task_device" \
  --source Documents/offline-acceptance-report.json \
  --destination "$task_report/report.json" --domain-type appDataContainer \
  --domain-identifier ai.nextbillion.navigation.nbNavigationFlutterExample || true
echo "Results: $task_report"
exit "$task_status"
