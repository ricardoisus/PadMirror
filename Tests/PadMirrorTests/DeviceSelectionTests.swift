// SPDX-License-Identifier: GPL-3.0-or-later
import XCTest
@testable import PadMirror
final class DeviceSelectionTests: XCTestCase {
    @MainActor
    func testExplicitUSBDisconnectPausesUntilSelection() {
        let coordinator = MirroringCoordinator()
        coordinator.sessionRunning = true
        coordinator.selectedID = "test-device"
        coordinator.disconnectUSB()
        XCTAssertTrue(coordinator.usbPaused)
        XCTAssertFalse(coordinator.sessionRunning)
        XCTAssertNil(coordinator.selectedID)
        coordinator.refresh()
        XCTAssertTrue(coordinator.usbPaused)
        coordinator.select(nil)
        XCTAssertFalse(coordinator.usbPaused)
    }

    func testSelectionTransitions() {
        for item in SelectionCase.all {
            XCTAssertEqual(DeviceSelection.automaticID(devices: item.devices, current: item.current), item.expected, item.name)
        }
    }
}
