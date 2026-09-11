# PadMirror
PadMirror mirrors your iPhone or iPad to a normal macOS window.

**USB: Freeform image confirmed on physical iPad. Wireless: experimental Popyachsa/UxPlay integration; physical validation in progress.**

## Build from source
macOS 14+, Apple Silicon preferred, Xcode 16+ or compatible Command Line Tools.
```sh
./scripts/bootstrap.sh
./scripts/build.sh
./scripts/test.sh
open build/PadMirror.app
```
Open Package.swift in Xcode for source development. Always run the bundled app for privacy permission testing.

## Usage
Connect with a data-capable USB cable, unlock iPad and trust this Mac. Allow camera access. One supported device connects automatically; multiple devices show a selector. Keep QuickTime closed. Validate Freeform and window sharing with [the manual test plan](docs/MANUAL_TEST_PLAN.md).

## AirPlay
Build the wireless bundle using [these instructions](docs/AIRPLAY.md). Select AirPlay, allow Local Network access, then choose PadMirror on the iPad and enter the displayed code. Uses the same macOS window. Audio is off by default. USB-only builds remain dependency-free.

## Privacy and licensing
No recordings, accounts or telemetry. Audio off. [Privacy](PRIVACY.md). GPL-3.0-or-later: you may redistribute and modify under GPL version 3 or any later version. [License](LICENSE), [credits](THIRD_PARTY_NOTICES.md).
