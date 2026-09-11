// SPDX-License-Identifier: GPL-3.0-or-later
import Foundation
#if canImport(XCTest)
@testable import PadMirror
#endif
struct SelectionCase {
    let name: String
    let devices: [MirrorDevice]
    let current: String?
    let expected: String?
    static var all: [SelectionCase] {
        let ipad = MirrorDevice(id: "a", name: "iPad")
        let iphone = MirrorDevice(id: "b", name: "iPhone")
        return [
            .init(name: "single device auto-connects", devices: [ipad], current: nil, expected: "a"),
            .init(name: "multiple devices require choice", devices: [ipad, iphone], current: nil, expected: nil),
            .init(name: "existing choice survives hotplug", devices: [ipad, iphone], current: "b", expected: "b"),
            .init(name: "disconnect clears choice", devices: [], current: "a", expected: nil),
            .init(name: "reconnect selects sole device", devices: [ipad], current: "gone", expected: "a"),
            .init(name: "stale choice does not pick arbitrary device", devices: [ipad, iphone], current: "gone", expected: nil)
        ]
    }
}
