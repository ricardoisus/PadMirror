// SPDX-License-Identifier: GPL-3.0-or-later
import Foundation

struct MirrorDevice: Identifiable, Equatable {
    let id: String
    let name: String
}

enum DeviceSelection {
    static func automaticID(devices: [MirrorDevice], current: String?) -> String? {
        if let current, devices.contains(where: { $0.id == current }) { return current }
        return devices.count == 1 ? devices.first?.id : nil
    }
}
