// SPDX-License-Identifier: GPL-3.0-or-later
#if canImport(XCTest)
@testable import PadMirror
#endif

enum AirPlayCases {
    static func run(_ check: (Bool, String) -> Void) {
        check(AirPlayEvent.parse("PADMIRROR_RECEIVER_READY") == .ready, "explicit readiness event")
        check(AirPlayEvent.parse("Begin streaming to GStreamer video pipeline") == .streaming, "video start event")
        check(AirPlayEvent.parse("Open connections: 0") == .disconnected, "last connection closed")
        check(AirPlayEvent.parse("Open connections: 1") == nil, "partial connection is not teardown")
        check(AirPlayEvent.parse("Title: Begin streaming to GStreamer video pipeline") == nil, "metadata cannot fake streaming")
        check(AirPlayEvent.parse("Title: stopping") == nil, "metadata cannot stop receiver")
        check(AirPlayEvent.parse("This packet indicates video stream is stopping") == nil, "normal packet is not fatal")
        check(AirPlayEvent.parse("stopping: engine started with an option it does not accept") == .failed, "fatal startup detected")
        check(AirPlayEvent.parse("begin video stream wxh = 1920x1080; source 1080x1920") == .dimensions(1920, 1080), "landscape dimensions parsed")
        check(AirPlayEvent.parse("begin video stream wxh = 1080x1920; source 1080x1920") == .dimensions(1080, 1920), "portrait dimensions parsed")
        check(AirPlayEvent.parse("begin video stream wxh = 0x1920;") == nil, "zero dimension rejected")
        check(AirPlayEvent.parse("begin video stream wxh = 999999x999999;") == nil, "unbounded dimensions rejected")
        let muted = AirPlayOptions.make(code: "012345", audio: false) ?? ""
        check(muted.contains("-pw 012345"), "leading zeros retained in access code")
        check(muted.contains("-as fakesink") && !muted.contains("-hls") && !muted.contains("-nohold"), "muted mirroring without HLS or takeover")
        check(muted.contains("-rc /dev/null"), "user uxplay config cannot enable recording")
        check(AirPlayOptions.make(code: "123456 -hls", audio: true) == nil, "options injection rejected")
        check(AirPlayOptions.make(code: "123", audio: false) == nil, "invalid code rejected")
        check(AirPlayOptions.make(code: "123456", audio: true)?.contains("-as osxaudiosink") == true, "optional device audio uses native sink")
    }
}
