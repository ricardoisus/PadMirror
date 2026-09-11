// SPDX-License-Identifier: GPL-3.0-or-later
// Same behavioral cases as XCTest, runnable on Command Line Tools without XCTest.
import Foundation
for item in SelectionCase.all {
    let actual = DeviceSelection.automaticID(devices: item.devices, current: item.current)
    guard actual == item.expected else {
        fputs("FAIL: \(item.name)\n", stderr)
        exit(1)
    }
    print("PASS: \(item.name)")
}
