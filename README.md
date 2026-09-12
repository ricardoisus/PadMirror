# PadMirror
PadMirror mirrors your iPhone or iPad to a normal macOS window.

**USB and AirPlay mirroring work: USB Freeform was observed on a physical iPad; the user confirmed AirPlay working on 2026-09-12. Extended physical checks remain pending.**

## Build from source
For a drag-and-drop Mac installer, see [installation instructions](docs/INSTALL.md) and [downloads](https://github.com/ricardoisus/PadMirror/releases). Initial installers are experimental USB builds, without Apple notarization.

macOS 14+, Apple Silicon preferred, Xcode 16+ or compatible Command Line Tools.
```sh
./scripts/bootstrap.sh
./scripts/build.sh
./scripts/test.sh
open build/PadMirror.app
```
Generate a DMG for your Mac's architecture with `./scripts/package.sh`.
Open Package.swift in Xcode for source development. Always run the bundled app for privacy permission testing.

## Usage
Connect with a data-capable USB cable, unlock iPad and trust this Mac. Allow camera access. One supported device connects automatically; multiple devices show a selector. Keep QuickTime closed. Validate Freeform and window sharing with [the manual test plan](docs/MANUAL_TEST_PLAN.md).

## Connected window
While USB capture is running or AirPlay is streaming, the title and window buttons hide automatically. Hover over the image to show USB/AirPlay controls and disconnect; move the pointer outside the window to hide the controls again. No presentation toggle is needed. The image keeps its aspect ratio, including any black bars.

USB **Desconectar** pauses capture until you click **USB** to reconnect. Connection messages, AirPlay pairing instructions and normal window buttons return when the session stops. In Meet, share the PadMirror **window**; its name remains available in the picker. Controls are part of the shared image while hovered.

## AirPlay
Build the wireless bundle using [these instructions](docs/AIRPLAY.md). Select AirPlay, allow Local Network access, then choose PadMirror on the iPad and enter the displayed code. Uses the same macOS window. Audio is off by default. USB-only builds remain dependency-free.

## Privacy and licensing
No recordings, accounts or telemetry. Audio off. [Privacy](PRIVACY.md). GPL-3.0-or-later: you may redistribute and modify under GPL version 3 or any later version. [License](LICENSE), [credits](THIRD_PARTY_NOTICES.md).
