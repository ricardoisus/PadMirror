// SPDX-License-Identifier: GPL-3.0-or-later
import AVFoundation
import Combine

@MainActor
final class MirroringCoordinator: ObservableObject {
    @Published var devices: [MirrorDevice] = []
    @Published var selectedID: String?
    @Published var message = "Conecte seu iPad via USB-C"
    @Published var sessionRunning = false
    let engine = USBCaptureEngine()
    private let discovery = USBDeviceDiscovery()
    private var timer: Timer?
    private var observers: [NSObjectProtocol] = []
    private var captureDevices: [AVCaptureDevice] = []
    private var generation = 0
    private var ready = false
    private var hadDevice = false

    func begin() {
        guard timer == nil else { return }
        Task {
            let allowed: Bool
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: allowed = true
            case .notDetermined: allowed = await AVCaptureDevice.requestAccess(for: .video)
            default: allowed = false
            }
            guard allowed else { message = USBError.permission.localizedDescription; return }
            do { try discovery.enable() } catch { message = error.localizedDescription; return }
            ready = true
            for name in [AVCaptureDevice.wasConnectedNotification, AVCaptureDevice.wasDisconnectedNotification] {
                observers.append(NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                    Task { @MainActor in self?.refresh() }
                })
            }
            for name in [AVCaptureSession.runtimeErrorNotification, AVCaptureSession.wasInterruptedNotification] {
                observers.append(NotificationCenter.default.addObserver(forName: name, object: engine.session, queue: .main) { [weak self] _ in
                    Task { @MainActor in
                        guard let self else { return }
                        self.generation += 1
                        self.engine.stop()
                        self.sessionRunning = false
                        self.message = USBError.input.localizedDescription
                    }
                })
            }
            // Handles delayed trust/unlock publication as well as hotplug notifications.
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                Task { @MainActor in self?.refresh() }
            }
            refresh()
        }
    }

    func refresh() {
        guard ready else { return }
        captureDevices = discovery.devices()
        devices = captureDevices.map { MirrorDevice(id: $0.uniqueID, name: $0.localizedName) }
        let next = DeviceSelection.automaticID(devices: devices, current: selectedID)
        if next != selectedID { select(next) }
        if selectedID == nil {
            message = devices.isEmpty
                ? (hadDevice ? "iPad desconectado. Reconecte o cabo USB-C." : "Conecte seu iPad via USB-C")
                : "Escolha o dispositivo"
        }
    }

    func select(_ id: String?) {
        generation += 1
        let attempt = generation
        selectedID = id
        sessionRunning = false
        guard let device = captureDevices.first(where: { $0.uniqueID == id }) else {
            engine.stop()
            message = "iPad desconectado. Reconecte o cabo USB-C."
            return
        }
        hadDevice = true
        message = "Conectando ao dispositivo…"
        engine.start(device: device) { [weak self] result in
            guard let self, self.generation == attempt else { return }
            switch result {
            case .success:
                self.sessionRunning = true
                self.message = "Sessão iniciada; confirme a imagem na janela."
            case .failure(let error): self.message = error.localizedDescription
            }
        }
    }

    func shutdown() {
        generation += 1
        timer?.invalidate()
        timer = nil
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        observers.removeAll()
        engine.stop()
    }
}
