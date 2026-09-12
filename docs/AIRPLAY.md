# Wireless integration

The complete USB + AirPlay DMG is available from https://github.com/ricardoisus/PadMirror/releases/tag/v0.1.0-airplay-preview.1. Its local Apple Silicon build requires macOS 26.6.2+ and includes runtime dependencies.

## Build and use
```sh
# Installs native build/runtime dependencies; no Rust needed.
brew install cmake ninja pkg-config gstreamer libplist openssl@3
./scripts/build-airplay.sh
./scripts/build.sh release --with-airplay
python3 scripts/verify-airplay-bundle.py build/PadMirror.app
open build/PadMirror.app
```
Select AirPlay. Allow the macOS Local Network prompt. The app waits until its password-protected Bonjour advertisement resolves before showing the access code. On iPad, select PadMirror in Screen Mirroring, enter the code shown on Mac, then open Freeform. Disconnect USB to prove the wireless path.

The receiver is OFF at launch. A new six-digit password is generated for each activation and is never saved or logged. This uses UxPlay's supported `-pw` authentication, rather than pretending the eight-function ABI has an Allow/Reject callback. The password remains valid until the receiver is disabled; stop/re-enable revokes it. Device audio defaults to off and can be enabled while the receiver is stopped. No second-client takeover flag, no automatic fallback or automatic switch away from an active wireless session. The explicit USB button stops AirPlay before resuming wired capture.

## Integration decision
Popyachsa commit `c24d4a4c68ea913b4456da67b45d49359d03ffa0` references UxPlay commit `587111368390479b7f65feb881c9257c02e508b5`. Both are kept as nested git submodules. Swift loads the eight-function C ABI using dlopen/dlsym. The Cocoa main loop owns the window; the engine receives an NSView inside the same VideoCanvas area. No upstream Rust GUI, tray, updater or HLS player is included.

A helper cannot directly use a pointer to an NSView in the host process. Passing surfaces or frames via IPC would add a separate transport and lifecycle before testing wireless. The documented macOS C ABI already handles rendering and rotation; we chose that path for this milestone. Tradeoff: engine crashes can affect the app. A future helper can replace it if actual stability measurements justify the extra transport.

Engine start/stop/destroy are serialized off the main thread. Stop joins the engine worker while the Cocoa loop remains responsive. The host view outlives the engine. The dylib stays loaded until process exit because GStreamer retains registered callbacks. Generation tokens ignore callbacks from stopped/replaced runs.

## Rendering and privacy
`-vd vtdec -vs avlayer -vsync no -fps 60`: upstream VideoToolbox decoder and AVSampleBufferDisplayLayer sink. The upstream sink currently copies decoded NV12 planes into a CVPixelBuffer; this is not a zero-copy claim. USB still uses PreviewLayer directly and is unaffected.

`-rc /dev/null` prevents a user's unrelated UxPlay config from enabling dumps, recording, HLS or custom network output. No `-hls`, `-mp4`, `-vdmp`, `-admp`, keyfile or registration file options. The receiver accepts screen mirroring on the local network; external URL/HLS playback is disabled. The bundled GStreamer plugin set is explicit and excludes HTTP/HLS/RTMP source plugins.

A reproducible patch in `patches/0001-embedded-privacy-and-readiness.patch` suppresses upstream log printing in library mode after forwarding events, and adds an engine-initialized marker. Swift accepts only known anchored status/dimension markers; raw metadata and client identities are not logged. Engine initialization is not proof of advertisement: macOS can hold DNSServiceRegister requests pending Local Network permission. A separate Bonjour resolve confirms discoverability and `pw=true` before UI readiness. Raw frames are never logged or stored. GStreamer writes only its plugin registry cache in the app's caches directory.

## Packaging and compatibility
`bundle-airplay.py` copies a closed Mach-O dependency graph into the app, rewrites dependency references to loader-relative paths, signs each library and copies package license texts/versions. `verify-airplay-bundle.py` loads the bundled registry and checks real plugin factories and all ABI exports, plus nested signatures.

The Swift USB app targets macOS 14+. A wireless bundle built using Homebrew bottles is conservatively marked with the build host's OS version; compiling the engine with a lower deployment target does not lower its precompiled dependencies' minimum OS. The local build was produced on macOS 26.6.2. A separate CI build on macOS 14 validates that environment; cross-version universal release packaging remains a later milestone. This is an ad-hoc signed experimental build, without Apple notarization.

## Remaining physical checks
- Receiver appears on iPad on the same Wi-Fi after permission.
- Wrong code rejects; right code connects; changed code invalidates the old one.
- Freeform and Pencil video with USB disconnected; portrait/landscape; resize and fullscreen.
- Audio is silent by default; optional native audio works without echo.
- Stop while connecting, disconnect/reconnect, repeat start/stop, quit during connection.
- Reconnect USB while streaming: offer an explicit switch; no silent takeover.
- Google Meet participant sees the AirPlay image in the same PadMirror window.

## Evidências em 2026-09-12
CI USB/wireless passou no run 34599799897. Rebuild local e 24 checks comportamentais passaram; bundle validado com 17 factories, oito símbolos e assinaturas. A versão atual resolveu seu anúncio Bonjour com pw=true e mostrou o código na janela. Em seguida, o usuário confirmou AirPlay funcionando em 2026-09-12. A confirmação valida o funcionamento básico relatado; os cenários específicos acima ainda não foram detalhados.
