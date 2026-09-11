#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
configuration="${1:-debug}"
[[ "$configuration" == debug || "$configuration" == release ]] || { echo 'Usage: build.sh [debug|release]'; exit 2; }
swift build -c "$configuration"
bin_path="$(swift build -c "$configuration" --show-bin-path)"
mkdir -p build/PadMirror.app/Contents/MacOS
cp "$bin_path/PadMirror" build/PadMirror.app/Contents/MacOS/PadMirror
cp Resources/Info.plist build/PadMirror.app/Contents/Info.plist
codesign --force --sign - build/PadMirror.app
codesign --verify --strict build/PadMirror.app
echo 'App: build/PadMirror.app — physical iPad validation required.'
