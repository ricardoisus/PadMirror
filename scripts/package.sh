#!/bin/bash
# SPDX-License-Identifier: GPL-3.0-or-later
set -euo pipefail
cd "$(dirname "$0")/.."
[[ $# -eq 0 ]] || { echo 'Usage: scripts/package.sh (USB experimental)'; exit 2; }
./scripts/build.sh release
version=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' Resources/Info.plist)
arch=$(uname -m)
name="PadMirror-${version}-usb-${arch}-experimental"
stage=$(mktemp -d "${TMPDIR:-/tmp}/padmirror-package.XXXXXX")
trap 'rm -rf "$stage"' EXIT
ditto build/PadMirror.app "$stage/PadMirror.app"
ln -s /Applications "$stage/Applications"
cp LICENSE "$stage/LICENSE.txt"
cp docs/INSTALL.md "$stage/INSTALL.txt"
cp THIRD_PARTY_NOTICES.md "$stage/THIRD_PARTY_NOTICES.txt"
hdiutil create -volname 'PadMirror USB' -srcfolder "$stage" -ov -format UDZO "build/$name.dmg"
hdiutil verify "build/$name.dmg"
(cd build && shasum -a 256 "$name.dmg" > "$name.dmg.sha256")
echo "Installer: build/$name.dmg"
