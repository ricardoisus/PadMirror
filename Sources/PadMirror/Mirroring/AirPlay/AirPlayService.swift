// SPDX-License-Identifier: GPL-3.0-or-later
import AppKit
import Combine
import os

@MainActor
final class AirPlayService: ObservableObject {
    @Published private(set) var state: AirPlayState = .off
    @Published private(set) var accessCode = ""
    @Published private(set) var message = "Use o espelhamento de tela do iPad na mesma rede Wi-Fi."
    @Published private(set) var resolution = ""
    @Published var deviceAudio = false
    let receiverName = "PadMirror – \(Host.current().localizedName ?? "Mac")"
    private let advertisement = AirPlayAdvertisement()
    private var host: NSView?
    private var generation = 0
    private let queue = DispatchQueue(label: "org.padmirror.airplay.lifecycle", qos: .userInitiated)
    private let worker = Worker()
    private var startupTimeout: Task<Void, Never>?
    private let logger = Logger(subsystem: "org.padmirror.PadMirror", category: "AirPlay")

    // Only accessed on queue. Holding this separately makes ownership explicit.
    private final class Worker: @unchecked Sendable { var core: AirPlayCore? }

    func attach(_ view: NSView) { host = view }

    func start() {
        guard state == .off || state == .failed, let host else { return }
        generation += 1
        let attempt = generation
        accessCode = String(format: "%06d", Int.random(in: 0...999999))
        guard let flags = AirPlayOptions.make(code: accessCode, audio: deviceAudio) else { return }
        state = .starting
        resolution = ""
        message = "Iniciando o receptor AirPlay…"
        let name = receiverName
        let path = Bundle.main.bundleURL.appendingPathComponent("Contents/Frameworks/uxplay-core.dylib").path
        let plugins = Bundle.main.bundleURL.appendingPathComponent("Contents/PlugIns/GStreamer").path
        let registry = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("org.padmirror.PadMirror", isDirectory: true)
        try? FileManager.default.createDirectory(at: registry, withIntermediateDirectories: true)
        queue.async { [worker, weak self] in
            do {
                worker.core?.stop()
                if worker.core == nil {
                    // Scoped plugin set shipped in the app; never load plugins from
                    // user shell paths or execute an external plugin scanner.
                    setenv("GST_PLUGIN_SYSTEM_PATH_1_0", plugins, 1)
                    setenv("GST_PLUGIN_PATH_1_0", "", 1)
                    setenv("GST_REGISTRY_FORK", "no", 1)
                    setenv("GST_REGISTRY_1_0", registry.appendingPathComponent("gstreamer.bin").path, 1)
                    worker.core = try AirPlayCore(path: path)
                }
                try worker.core?.start(host: Unmanaged.passUnretained(host).toOpaque(), receiverName: name, flags: flags) { [weak self] event in
                    Task { @MainActor [weak self] in self?.receive(event, attempt: attempt) }
                }
            } catch {
                Task { @MainActor [weak self] in
                    guard let self, self.generation == attempt else { return }
                    self.state = .failed
                    self.message = error.localizedDescription
                    self.accessCode = ""
                }
            }
        }
        startupTimeout = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 60_000_000_000)
            guard !Task.isCancelled, let self, self.generation == attempt, self.state == .starting else { return }
            self.receive(.failed, attempt: attempt)
        }
    }

    private func receive(_ event: AirPlayEvent, attempt: Int) {
        guard generation == attempt, state != .stopping, state != .off else { return }
        switch event {
        case .ready:
            message = "Permita o acesso à rede local no aviso do macOS. Confirmando o anúncio AirPlay…"
            advertisement.start(name: receiverName) { [weak self] confirmed in
                Task { @MainActor [weak self] in
                    guard let self, self.generation == attempt, self.state == .starting else { return }
                    if confirmed {
                        self.startupTimeout?.cancel()
                        self.state = .ready
                        self.message = "No iPad: Central de Controle → Espelhamento de Tela."
                        self.logger.info("Bonjour advertisement resolved; password required")
                    } else { self.receive(.failed, attempt: attempt) }
                }
            }
        case .streaming:
            advertisement.stop()
            startupTimeout?.cancel()
            state = .streaming
            message = "AirPlay conectado"
            logger.info("Video stream started")
        case .disconnected:
            if state == .streaming {
                state = .ready
                message = "Dispositivo desconectado. O receptor continua disponível."
            }
        case .dimensions(let width, let height): resolution = "\(width) × \(height)"
        case .failed:
            advertisement.stop()
            generation += 1
            startupTimeout?.cancel()
            state = .failed
            accessCode = ""
            message = AirPlayFailure.start.localizedDescription
            queue.async { [worker] in worker.core?.stop() }
            logger.error("Receiver failed; stopping engine")
        }
    }

    func stop(completion: @escaping () -> Void = {}) {
        advertisement.stop()
        generation += 1 // invalidates queued worker callbacks and startup timeout
        startupTimeout?.cancel()
        accessCode = ""
        state = .stopping
        queue.async { [worker, weak self] in
            worker.core?.stop()
            Task { @MainActor [weak self] in
                self?.state = .off
                self?.message = "Receptor AirPlay desligado."
                self?.resolution = ""
                completion()
            }
        }
    }
}
