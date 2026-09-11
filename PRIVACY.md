# Privacy
USB video is processed locally. Optional AirPlay reception uses the local network, requires an ephemeral access password and is off at launch. No accounts, telemetry, video recordings, frame files, cloud APIs or external URL/HLS playback. Audio defaults to off.

The announced receiver name includes the Mac name and is visible on the local network while enabled. The access code remains only in process memory and the UI until disabled; it is never saved to preferences or logs. Technical Unified Logging contains only recognized state events, dimensions and error categories, not raw engine messages, device identifiers or screen content. GStreamer caches plugin metadata in the app's caches directory. Dependencies are bundled; upstream GUI, auto-update and analytics are not used.
