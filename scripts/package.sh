#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
cd "$(dirname "$0")/.."
mode="${1:---with-airplay}"
[[ $# -le 1 && ( "$mode" == --with-airplay || "$mode" == --usb-only ) ]] || { echo 'Usage: scripts/package.sh [--with-airplay|--usb-only]'; exit 2; }
if [[ "$mode" == --with-airplay ]]; then
    ./scripts/build-airplay.sh
    ./scripts/build.sh release --with-airplay
    python3 scripts/verify-airplay-bundle.py build/PadMirror.app
    edition=usb-airplay
else
    ./scripts/build.sh release
    edition=usb
fi
version=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Resources/Info.plist)
arch=$(uname -m)
minimum=$(/usr/libexec/PlistBuddy -c 'Print :LSMinimumSystemVersion' build/PadMirror.app/Contents/Info.plist)
name="PadMirror-${version}-${edition}-${arch}-macOS${minimum}-experimental"
stage=$(mktemp -d "${TMPDIR:-/tmp}/padmirror-package.XXXXXX")
trap 'rm -rf "$stage"' EXIT
ditto build/PadMirror.app "$stage/PadMirror.app"
ln -s /Applications "$stage/Applications"
cp LICENSE "$stage/LICENSE.txt"
cp docs/INSTALL.md "$stage/INSTALL.txt"
cp THIRD_PARTY_NOTICES.md "$stage/THIRD_PARTY_NOTICES.txt"
printf 'PadMirror %s\nEdition: %s\nArchitecture: %s\nMinimum macOS: %s\n' "$version" "$edition" "$arch" "$minimum" > "$stage/BUILD.txt"
hdiutil create -volname "PadMirror $edition" -srcfolder "$stage" -ov -format UDZO "build/$name.dmg"
hdiutil verify "build/$name.dmg"
(cd build && shasum -a 256 "$name.dmg" > "$name.dmg.sha256")
echo "Installer: build/$name.dmg"
