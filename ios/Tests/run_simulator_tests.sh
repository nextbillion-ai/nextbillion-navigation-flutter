#!/usr/bin/env bash
set -euo pipefail

# First build example with: flutter build ios --simulator --debug --no-pub
# Supply an already booted simulator ID, or use the default "booted" target.
task_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
task_build="$task_root/example/build/ios/Debug-iphonesimulator"
task_sdk="$(xcrun --sdk iphonesimulator --show-sdk-path)"
task_arch="$(uname -m)"
task_temp="$(mktemp -d "${TMPDIR:-/tmp}/nb-navigation-tests.XXXXXX")"
trap 'rm -rf "$task_temp"' EXIT
test -f "$task_build/nb_navigation_flutter.o" || {
  echo 'Build the example for iOS Simulator in Debug first.' >&2
  exit 1
}
xcrun --sdk iphonesimulator swiftc \
  -target "$task_arch-apple-ios13.0-simulator" -sdk "$task_sdk" \
  -parse-as-library -I "$task_build" -F "$task_build" \
  "$task_root/ios/Tests/NavigationRegressionTests.swift" \
  "$task_build/nb_navigation_flutter.o" \
  -framework Flutter -framework Nbmap -framework NbmapCoreNavigation \
  -framework NbmapNavigation -framework NBTurf -framework UIKit \
  -Xlinker -rpath -Xlinker "$task_build" -o "$task_temp/regression-tests"
xcrun simctl spawn "${1:-booted}" "$task_temp/regression-tests"
