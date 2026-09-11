// swift-tools-version: 5.10
// SPDX-License-Identifier: GPL-3.0-or-later
import PackageDescription
let package = Package(
    name: "PadMirror", platforms: [.macOS(.v14)],
    products: [.executable(name: "PadMirror", targets: ["PadMirror"])],
    targets: [.executableTarget(name: "PadMirror"),
              .testTarget(name: "PadMirrorTests", dependencies: ["PadMirror"])])
