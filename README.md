# PadMirror
PadMirror mirrors your iPhone or iPad to a normal macOS window.

**Milestone 1: experimental USB preview. Physical validation pending. AirPlay is not implemented yet.**

## Build from source
macOS 14+, Apple Silicon preferred, Xcode 16+ or compatible Command Line Tools.
```sh
./scripts/bootstrap.sh
./scripts/build.sh
swift test
open build/PadMirror.app
```
Open Package.swift in Xcode for source development. Always run the bundled app for privacy permission testing.

## Usage
Connect with a data-capable USB cable, unlock iPad and trust this Mac. Allow camera access. One supported device connects automatically; multiple devices show a selector. Keep QuickTime closed. Validate Freeform and window sharing with [the manual test plan](docs/MANUAL_TEST_PLAN.md).

## AirPlay
Deferred until USB passes physical validation. Planned Popyachsa/UxPlay integration; no additional dependencies are needed for this USB build.

## Privacy and licensing
No recordings, accounts or telemetry. Audio off. [Privacy](PRIVACY.md). GPL-3.0-or-later: you may redistribute and modify under GPL version 3 or any later version. [License](LICENSE), [credits](THIRD_PARTY_NOTICES.md).
