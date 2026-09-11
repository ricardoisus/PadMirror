// SPDX-License-Identifier: GPL-3.0-or-later
import XCTest
@testable import PadMirror
final class AirPlayTests: XCTestCase {
    func testProtocolEventsAndSecureOptions() {
        AirPlayCases.run { XCTAssertTrue($0, $1) }
    }
}
