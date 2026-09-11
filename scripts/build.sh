#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
configuration="${1:-debug}"
[[ "$configuration" == debug || "$configuration" == release ]] || { echo 'Usage: build.sh [debug|release]'; exit 2; }
swift build -c "$configuration"
bin_path="$(swift build -c "$configuration" --show-bin-path)"
# Recreate generated output so a USB-only build cannot retain stale wireless libs.
rm -rf build/PadMirror.app
mkdir -p build/PadMirror.app/Contents/MacOS
cp "$bin_path/PadMirror" build/PadMirror.app/Contents/MacOS/PadMirror
cp Resources/Info.plist build/PadMirror.app/Contents/Info.plist
if [[ "${2:-}" == --with-airplay ]]; then
    [[ -f .build/airplay-engine/uxplay-core.dylib ]] || { echo 'Run scripts/build-airplay.sh first'; exit 1; }
    python3 scripts/bundle-airplay.py build/PadMirror.app
fi
codesign --force --sign - build/PadMirror.app
codesign --verify --strict build/PadMirror.app
echo 'App: build/PadMirror.app — validate the selected backend with a physical iPad.'
