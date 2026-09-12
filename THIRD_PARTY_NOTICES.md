# Third-party notices
PadMirror original code and local engine patches: GPL-3.0-or-later; see LICENSE. Documentation templates were adapted from the user-provided templates; their proprietary product license was not adopted. Apple system frameworks are linked, not redistributed.

## AirPlay engine
Popyachsa AirPlay, Copyright (C) 2026 Recluse — GPL-3.0-or-later.
https://github.com/Recluse/Popyachsa-AirPlay
Pinned commit: c24d4a4c68ea913b4456da67b45d49359d03ffa0.
Preserved LICENSE and NOTICE: ThirdParty/Popyachsa-AirPlay/.

Nested UxPlay fork: https://github.com/Recluse/UxPlay
Pinned commit: 587111368390479b7f65feb881c9257c02e508b5.
UxPlay upstream: https://github.com/FDH2/UxPlay — GPL-3.0.
Credit chain: UxPlay → RPiPlay (https://github.com/FD-/RPiPlay) → shairplay (Juho Vähä-Herttua; https://github.com/juhovh/shairplay) / playfair / openairplay.
Local modifications are an explicit patch applied to an ignored build copy, not silent edits to the upstream submodule.

## Linked/bundled components
GStreamer and GLib (LGPL-2.1 family), libplist (LGPL), OpenSSL (Apache-2.0), FFmpeg/libav and its codec dependencies (including GPL components such as x264/x265), llhttp (MIT), and their transitive dependencies retain their own licenses. Exact versions, available license texts and Homebrew build-source references are copied to Contents/Resources/ThirdPartyNotices and airplay-build.json in wireless builds. Source URLs/build recipes for dependencies are in their package metadata; publish corresponding source materials with any public binary release, including engine pins and local patches. The public v0.1.0-usb-preview.1 release contains only the USB app; no public wireless binary release has been issued.

Popyachsa's broader credit chain also names mjansson/mdns (Unlicense), the standalone Windows mDNS shim (MIT), and permissively licensed Rust crates. Those Windows/Rust components are not included in this macOS C ABI build. Native Apple Bonjour is used.

MirrorKit README/LICENSE were consulted conceptually only. No MirrorKit implementation, UI or assets are included.
