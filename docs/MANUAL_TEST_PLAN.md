# Physical validation — milestone 1

Status USB: Freeform real observado na janela após relato positivo do usuário. Rotação, latência, Meet e reconexão ainda não validados. Processo QuickTime estava aberto nessa observação; repetir com ele fechado.

Local checks: Debug and Release builds pass; ad-hoc signature verified; initial NSWindow inspected visually. After accepting the locally observed external/muxed source (transport other), the session started but the preview remained black. This is NOT successful mirroring; connect/unlock/trust the physical iPad to continue diagnosis. Six device-selection cases pass using the CLT runner. Full XCTest, Release build and app artifact upload passed on GitHub Actions for code commit 527e37f (run 34548785404).

1. Build with `./scripts/build.sh`; quit QuickTime and other capture apps.
2. Open `build/PadMirror.app`. Without iPad, expect a normal resizable window and a USB connection hint.
3. Allow camera access when macOS asks. If denied, enable PadMirror under System Settings → Privacy & Security → Camera and relaunch.
4. Connect iPad Pro 11-inch M2 with a data-capable USB-C cable. Unlock it and accept Trust This Computer (enter passcode on the iPad).
5. Expect the real iPad screen automatically. Report whether it is absent, black, frozen, or live. A running capture session alone is NOT a pass.
6. Open Freeform; draw with Apple Pencil. Check responsiveness. Compare with QuickTime in a separate run, never simultaneously. Do not claim measured milliseconds without a high-speed external-camera test.
7. Rotate portrait → landscape → portrait. Check image orientation and cropping. Resize the Mac window and enter fullscreen; image must remain proportional.
8. In Google Meet select Share → Window → PadMirror. A second participant must see live Freeform, not a black image. macOS may separately request screen recording permission for the browser.
9. Disconnect, reconnect and repeat unlock/trust as required. Try closing and reopening PadMirror.
10. If available, connect a second iOS device. A selector must appear; switching must not leave an old stream or freeze the UI.
11. Deny camera access in a separate run; verify the actionable message. Test another capture app competing for the device.

## Return these results
- macOS/iPadOS versions; build commit.
- Real image without QuickTime: yes/no.
- Rotation and resize: pass/fail.
- Pencil latency versus separate QuickTime run: comparable/worse.
- Remote Meet participant sees live window: yes/no.
- Disconnect/reconnect: pass/fail.
- Any displayed error (do not include personal screen content).

## Technical logs
Use Console.app and filter subsystem `org.padmirror.PadMirror`, or:
```sh
log stream --level info --predicate 'subsystem == "org.padmirror.PadMirror"'
```
Logs intentionally omit device names, IDs and frames.

## Later gates (not implemented)
AirPlay enable, pairing/rejection, Wi-Fi video/audio, rotation, clean shutdown, USB return and consented fallback. These cannot be marked passed by the USB build.

## Automatic connected interface
- With live USB video, verify the title/window buttons hide automatically, without any presentation button or shortcut. Move the pointer outside the window: only the proportional image and any black bars remain.
- Hover over the image: USB/AirPlay and Desconectar appear. Move out again: controls disappear. Repeat over the top edge and in fullscreen.
- Click USB Desconectar and wait at least three seconds: capture stays stopped, the normal title returns, and USB reconnects only when clicked. Also unplug/replug during this pause; it must remain paused.
- Unplug while streaming normally: status and title return, and reconnecting restores automatic capture and clean chrome.
- Resize and switch USB/AirPlay repeatedly; the same renderers and window must remain attached.
- With live AirPlay, verify identical chrome/hover behavior, including the bottom disconnect control. Disconnect and verify pairing/status UI and window buttons return.
- Share the same window in Meet. A remote participant must confirm live content without title/controls when the pointer is outside, and visible controls while hovering.
- User confirmed the preceding manual presentation implementation visually. These new automatic/hover checks remain pending physical validation; build/tests are not proof of remote capture.
