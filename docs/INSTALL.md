# Install PadMirror (experimental USB edition)

Requires macOS 14 or later. Choose arm64 for Apple Silicon; x86_64 for Intel when available. The installer contains the Mac app only; nothing needs to be installed on the iPad.

1. Download the DMG from https://github.com/ricardoisus/PadMirror/releases.
2. Open it and drag PadMirror into Applications. Eject the disk image.
3. Open PadMirror from Applications and allow camera access.
4. Connect your unlocked iPad or iPhone using a data-capable USB cable and trust the Mac. Close QuickTime before connecting.

This experimental build is ad-hoc signed, without Apple Developer ID or notarization. macOS may block the first launch. If you trust this download, follow Apple's per-app instructions in System Settings → Privacy & Security → Open Anyway: https://support.apple.com/en-gb/102445. Do not disable Gatekeeper globally.

This installer supports USB. AirPlay was confirmed working by the user on 2026-09-12 and is available through the wireless source build; it is not included in this USB DMG. Basic USB Freeform mirroring has been observed; rotation, reconnection, hover controls and Meet still require the full physical test plan. A successful build does not validate those scenarios.

To uninstall, quit PadMirror and remove it from Applications.

## Build an installer

Run `./scripts/package.sh` on macOS with compatible Swift Command Line Tools. It builds Release for the host architecture, produces a compressed DMG in `build/`, verifies its integrity and writes a SHA-256 file. The temporary staging directory is cleaned automatically.

Public binary releases must include the matching source revision and GPL license. This USB package does not bundle the third-party wireless engine. Wireless binary distribution additionally requires corresponding source materials for bundled dependencies, as documented in THIRD_PARTY_NOTICES.md.

## Apple signing

A basic Apple developer account is free. Developer ID signing and notarization for Mac distribution require Apple Developer Program membership, currently USD 99 per year (local currency where available). These capabilities are included in the membership. The current USB preview has neither Developer ID nor notarization. Membership alone does not sign or notarize an existing build.

Official membership comparison: https://developer.apple.com/support/compare-memberships/ (checked 2026-09-12).
