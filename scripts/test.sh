#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
if xcrun swift -e 'import XCTest' >/dev/null 2>&1; then
    swift test
else
    echo 'XCTest unavailable in Command Line Tools; running the shared behavioral cases directly.'
    mkdir -p .build/checks
    xcrun swiftc Sources/PadMirror/Models/MirrorDevice.swift Sources/PadMirror/Mirroring/AirPlay/AirPlayEvents.swift Tests/PadMirrorTests/SelectionCases.swift Tests/PadMirrorTests/AirPlayCases.swift scripts/testing/main.swift -o .build/checks/selection-tests
    .build/checks/selection-tests
fi
