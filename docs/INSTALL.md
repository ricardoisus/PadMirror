# Install PadMirror (USB + AirPlay preview)

The complete local installer requires macOS 26.6.2 or later on Apple Silicon (arm64). Always check BUILD.txt and the release notes for the actual minimum OS and architecture. The older USB-only preview requires macOS 14+. The installer contains the Mac app only; nothing needs to be installed on the iPad.

1. Download the DMG from https://github.com/ricardoisus/PadMirror/releases.
2. Open it and drag PadMirror into Applications. Eject the disk image.
3. Open PadMirror from Applications and allow camera access.
4. For USB, connect your unlocked iPad or iPhone using a data-capable USB cable and trust the Mac. Close QuickTime before connecting.
5. For AirPlay, put both devices on the same Wi-Fi, select AirPlay in PadMirror and allow Local Network access. On the iPad, open Screen Mirroring, choose PadMirror and enter the displayed code. No Homebrew installation is needed.

This experimental build is ad-hoc signed, without Apple Developer ID or notarization. macOS may block the first launch. If you trust this download, follow Apple's per-app instructions in System Settings → Privacy & Security → Open Anyway: https://support.apple.com/en-gb/102445. Do not disable Gatekeeper globally.

This installer includes USB + AirPlay. AirPlay was confirmed working by the user on 2026-09-12. Basic USB Freeform mirroring has been observed; rotation, reconnection, hover controls and Meet still require the full physical test plan. A successful build does not validate those scenarios.

To uninstall, quit PadMirror and remove it from Applications.

## Build an installer

Install the build dependencies listed in AIRPLAY.md, then run `./scripts/package.sh` on macOS with compatible Swift Command Line Tools. The default builds and bundles USB + AirPlay; `--usb-only` explicitly selects USB. It builds Release for the host architecture, produces a compressed DMG in `build/`, verifies its integrity and writes a SHA-256 file. The temporary staging directory is cleaned automatically.

Public binary releases must include the matching source revision and GPL license. The complete release includes a separate corresponding-source archive with pinned engine sources, local patches, dependency sources and build recipes. See THIRD_PARTY_NOTICES.md.

To collect dependency sources from the same Mac immediately after packaging, run `HOMEBREW_NO_AUTO_UPDATE=1 brew ruby scripts/collect-airplay-sources.rb build/PadMirror.app build/corresponding-source/dependencies`. Keep installed formula versions and cached bottle manifests until collection finishes; missing sources or patches stop collection. Publish the collected sources together with this repository at the release tag, recursive submodules, local patches and build instructions.

## Apple signing

A basic Apple developer account is free. Developer ID signing and notarization for Mac distribution require Apple Developer Program membership, currently USD 99 per year (local currency where available). These capabilities are included in the membership. The current previews have neither Developer ID nor notarization. Membership alone does not sign or notarize an existing build.

Official membership comparison: https://developer.apple.com/support/compare-memberships/ (checked 2026-09-12).
