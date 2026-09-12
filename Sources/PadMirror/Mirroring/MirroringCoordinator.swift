// SPDX-License-Identifier: GPL-3.0-or-later
import AVFoundation
import Combine

@MainActor
final class MirroringCoordinator: ObservableObject {
    enum Mode { case usb, airPlay }
    @Published private(set) var mode: Mode = .usb
    @Published private(set) var switching = false
    let airPlay = AirPlayService()
    @Published var devices: [MirrorDevice] = []
    @Published var selectedID: String?
    @Published var message = "Conecte seu iPad via USB-C"
    @Published var sessionRunning = false
    @Published private(set) var usbPaused = false
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
            do {
                try discovery.enable { [weak self] in
                    Task { @MainActor [weak self] in self?.refresh() }
                }
            } catch { message = error.localizedDescription; return }
            ready = true
            // Public Objective-C notification values are stable across SDKs whose
            // Swift imports moved from Notification.Name to AVCaptureSession.
            let sessionNotifications = [
                Notification.Name("AVCaptureSessionRuntimeErrorNotification"),
                Notification.Name("AVCaptureSessionWasInterruptedNotification")
            ]
            for name in sessionNotifications {
                observers.append(NotificationCenter.default.addObserver(forName: name, object: engine.session, queue: .main) { [weak self] _ in
                    Task { @MainActor [weak self] in
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
                Task { @MainActor [weak self] in self?.refresh() }
            }
            refresh()
        }
    }

    func refresh() {
        guard ready else { return }
        captureDevices = discovery.devices()
        devices = captureDevices.map { MirrorDevice(id: $0.uniqueID, name: $0.localizedName) }
        guard mode == .usb, !switching, !usbPaused else { return }
        let next = DeviceSelection.automaticID(devices: devices, current: selectedID)
        if next != selectedID { select(next) }
        if selectedID == nil {
            message = devices.isEmpty
                ? (hadDevice ? "iPad desconectado. Reconecte o cabo USB-C." : "Conecte seu iPad via USB-C")
                : "Escolha o dispositivo"
        }
    }

    func select(_ id: String?) {
        guard mode == .usb, !switching else { return }
        usbPaused = false
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

    func useAirPlay() {
        guard !switching else { return }
        generation += 1
        selectedID = nil
        sessionRunning = false
        engine.stop()
        mode = .airPlay
        airPlay.start()
    }

    func disconnectUSB() {
        guard mode == .usb, !switching else { return }
        generation += 1
        usbPaused = true
        selectedID = nil
        sessionRunning = false
        message = "USB desconectado."
        engine.stop()
    }

    func useUSB() {
        guard !switching else { return }
        usbPaused = false
        switching = true
        airPlay.stop { [weak self] in
            guard let self else { return }
            self.mode = .usb
            self.switching = false
            self.refresh()
        }
    }

    func shutdown(completion: @escaping () -> Void = {}) {
        generation += 1
        timer?.invalidate()
        timer = nil
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        observers.removeAll()
        engine.stop()
        airPlay.stop(completion: completion)
    }
}
