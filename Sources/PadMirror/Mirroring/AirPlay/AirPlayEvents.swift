// SPDX-License-Identifier: GPL-3.0-or-later
import Foundation

enum AirPlayState: Equatable {
    case off, starting, ready, streaming, stopping, failed
}

enum AirPlayEvent: Equatable {
    case ready, streaming, disconnected, failed
    case dimensions(Int, Int)

    // Upstream callback includes client-controlled metadata. Accept only anchored
    // engine markers; never persist raw messages or interpret them as commands.
    static func parse(_ text: String) -> AirPlayEvent? {
        if text == "PADMIRROR_RECEIVER_READY" { return .ready }
        if text == "Begin streaming to GStreamer video pipeline" { return .streaming }
        if text == "Open connections: 0" { return .disconnected }
        let prefix = "begin video stream wxh = "
        if text.hasPrefix(prefix) {
            let size = text.dropFirst(prefix.count).prefix(while: { $0 != ";" })
            let parts = size.split(separator: "x")
            if parts.count == 2, let w = Int(parts[0]), let h = Int(parts[1]),
               (1...8192).contains(w), (1...8192).contains(h) { return .dimensions(w, h) }
        }
        let failures = ["stopping", "Could not initialize dnssd library!", "Error initializing raop",
                        "DNSServiceRegister call returned", "No DNS-SD Server found"]
        if failures.contains(where: { text.hasPrefix($0) }) { return .failed }
        if text.hasPrefix("dnssd_register") && text.contains("failed with error code") { return .failed }
        return nil
    }
}

enum AirPlayOptions {
    static func make(code: String, audio: Bool) -> String? {
        guard code.count == 6, code.utf8.allSatisfy({ (48...57).contains($0) }) else { return nil }
        // Override ~/.uxplayrc; no recording/HLS, no persisted pair registrations,
        // no second-client takeover. Password required by the existing protocol.
        return "-rc /dev/null -nh -nc -vs avlayer -vd vtdec -vsync no -fps 60 -as \(audio ? "osxaudiosink" : "fakesink") -pw \(code)"
    }
}
