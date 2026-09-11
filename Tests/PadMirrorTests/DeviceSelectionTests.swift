// SPDX-License-Identifier: GPL-3.0-or-later
import XCTest
@testable import PadMirror
final class DeviceSelectionTests: XCTestCase {
    func testSelectionTransitions() {
        for item in SelectionCase.all {
            XCTAssertEqual(DeviceSelection.automaticID(devices: item.devices, current: item.current), item.expected, item.name)
        }
    }
}
