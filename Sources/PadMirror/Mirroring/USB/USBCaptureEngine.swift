// SPDX-License-Identifier: GPL-3.0-or-later
import AVFoundation
import os

final class USBCaptureEngine {
    let session = AVCaptureSession()
    private let queue = DispatchQueue(label: "org.padmirror.usb.capture", qos: .userInitiated)
    private let logger = Logger(subsystem: "org.padmirror.PadMirror", category: "USBCapture")

    func start(device: AVCaptureDevice, completion: @escaping (Result<Void, Error>) -> Void) {
        queue.async { [self] in
            session.stopRunning()
            session.beginConfiguration()
            session.inputs.forEach { session.removeInput($0) }
            do {
                let input = try AVCaptureDeviceInput(device: device)
                guard session.canAddInput(input) else { throw USBError.input }
                session.addInput(input)
                // Keep device-native negotiation; do not force scaling or a frame rate.
                session.commitConfiguration()
                session.startRunning()
                let result: Result<Void, Error> = session.isRunning ? .success(()) : .failure(USBError.input)
                logger.info("Capture session start completed; running=\(self.session.isRunning)")
                DispatchQueue.main.async { completion(result) }
            } catch {
                session.commitConfiguration()
                logger.error("Capture input failed")
                DispatchQueue.main.async { completion(.failure(USBError.input)) }
            }
        }
    }

    func stop() {
        queue.async { [self] in
            session.stopRunning()
            session.beginConfiguration()
            session.inputs.forEach { session.removeInput($0) }
            session.commitConfiguration()
        }
    }
}
