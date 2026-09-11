// SPDX-License-Identifier: GPL-3.0-or-later
import AVFoundation
import CoreMediaIO
import os

final class USBDeviceDiscovery {
    private var lastCounts = ""
    private var discovery: AVCaptureDevice.DiscoverySession?
    private let logger = Logger(subsystem: "org.padmirror.PadMirror", category: "USBDiscovery")

    func enable() throws {
        for (selector, value) in [
            (kCMIOHardwarePropertyAllowScreenCaptureDevices, UInt32(1)),
            (kCMIOHardwarePropertyAllowWirelessScreenCaptureDevices, UInt32(0))
        ] {
            var address = CMIOObjectPropertyAddress(mSelector: UInt32(selector),
                mScope: UInt32(kCMIOObjectPropertyScopeGlobal), mElement: UInt32(kCMIOObjectPropertyElementMain))
            var flag = value
            let status = CMIOObjectSetPropertyData(CMIOObjectID(kCMIOObjectSystemObject),
                &address, 0, nil, UInt32(MemoryLayout<UInt32>.size), &flag)
            guard status == noErr else {
                logger.error("CMIO opt-in failed: \(status)")
                throw USBError.discovery
            }
        }
        discovery = AVCaptureDevice.DiscoverySession(deviceTypes: [.external], mediaType: .muxed, position: .unspecified)
        logger.info("Screen capture discovery enabled; wireless excluded")
    }

    func devices() -> [AVCaptureDevice] {
        // Screen-capture sources can report 'othr', even when tethered.
        // Do not require transportType == 'usb '. Wireless was disabled above.
        // External + muxed excludes ordinary video-only webcams; physical validation
        // remains necessary to identify the platform-provided screen source.
        let candidates = discovery?.devices ?? []
        let connected = candidates.filter { $0.isConnected }
        let counts = "muxed=\(candidates.count) connected=\(connected.count)"
        if counts != lastCounts {
            logger.info("Discovery counts: \(counts, privacy: .public)")
            lastCounts = counts
        }
        return connected
    }
}

enum USBError: LocalizedError {
    case discovery, input, permission
    var errorDescription: String? {
        switch self {
        case .discovery: return "Não foi possível procurar o iPad. Feche e abra o PadMirror."
        case .input: return "Não foi possível acessar o iPad. Desbloqueie, confirme ‘Confiar neste computador’ e reconecte o cabo. Outro app pode estar usando a captura."
        case .permission: return "Permita o acesso à câmera em Ajustes do Sistema → Privacidade e Segurança → Câmera para mostrar a tela do iPad."
        }
    }
}
