// SPDX-License-Identifier: GPL-3.0-or-later
import Foundation
import Darwin

// Thin binding to the pinned Popyachsa/UxPlay C ABI. No Rust or GStreamer types
// cross into Swift. All engine lifecycle calls are made on one serial queue.
final class AirPlayCore {
    typealias Create = @convention(c) () -> UnsafeMutableRawPointer?
    typealias SetString = @convention(c) (UnsafeMutableRawPointer?, UnsafePointer<CChar>?) -> Int32
    typealias SetWindow = @convention(c) (UnsafeMutableRawPointer?, UnsafeMutableRawPointer?) -> Int32
    typealias Log = @convention(c) (Int32, UnsafePointer<CChar>?, UnsafeMutableRawPointer?) -> Void
    typealias SetLog = @convention(c) (UnsafeMutableRawPointer?, Log?, UnsafeMutableRawPointer?) -> Void
    typealias Start = @convention(c) (UnsafeMutableRawPointer?) -> Int32
    typealias End = @convention(c) (UnsafeMutableRawPointer?) -> Void

    private let image: UnsafeMutableRawPointer
    private let create: Create
    private let name: SetString
    private let options: SetString
    private let window: SetWindow
    private let log: SetLog
    private let run: Start
    private let stopCore: End
    private let destroy: End
    private var handle: UnsafeMutableRawPointer?
    private var relay: EventRelay?

    final class EventRelay {
        let receive: (AirPlayEvent) -> Void
        init(_ receive: @escaping (AirPlayEvent) -> Void) { self.receive = receive }
    }

    init(path: String) throws {
        guard let image = dlopen(path, RTLD_NOW | RTLD_LOCAL) else { throw AirPlayFailure.missingEngine }
        self.image = image
        func symbol<T>(_ name: String, _ type: T.Type) throws -> T {
            guard let address = dlsym(image, name) else { throw AirPlayFailure.incompatibleEngine }
            return unsafeBitCast(address, to: type)
        }
        create = try symbol("airplay_core_create", Create.self)
        name = try symbol("airplay_core_set_device_name", SetString.self)
        options = try symbol("airplay_core_set_options", SetString.self)
        window = try symbol("airplay_core_set_window", SetWindow.self)
        log = try symbol("airplay_core_set_log_callback", SetLog.self)
        run = try symbol("airplay_core_start", Start.self)
        stopCore = try symbol("airplay_core_stop", End.self)
        destroy = try symbol("airplay_core_destroy", End.self)
        // Intentionally keep dylib loaded until process exit: GStreamer retains
        // registered plugin/type callbacks into this image after engine teardown.
    }

    func start(host: UnsafeMutableRawPointer, receiverName: String, flags: String,
               receive: @escaping (AirPlayEvent) -> Void) throws {
        guard handle == nil, let instance = create() else { throw AirPlayFailure.start }
        handle = instance
        let relay = EventRelay(receive)
        self.relay = relay
        log(instance, { _, message, user in
            guard let message, let user else { return }
            if let event = AirPlayEvent.parse(String(cString: message)) {
                Unmanaged<EventRelay>.fromOpaque(user).takeUnretainedValue().receive(event)
            }
        }, Unmanaged.passUnretained(relay).toOpaque())
        guard window(instance, host) == 0,
              receiverName.withCString({ name(instance, $0) }) == 0,
              flags.withCString({ options(instance, $0) }) == 0,
              run(instance) == 0 else {
            stop()
            throw AirPlayFailure.start
        }
    }

    func stop() {
        guard let handle else { return }
        stopCore(handle) // joins worker; must never run on main thread
        destroy(handle)
        self.handle = nil
        relay = nil // callbacks can no longer reference it after join
    }
}

enum AirPlayFailure: LocalizedError {
    case missingEngine, incompatibleEngine, start
    var errorDescription: String? {
        switch self {
        case .missingEngine: return "A engine AirPlay não está disponível neste build. Use o pacote com suporte wireless."
        case .incompatibleEngine: return "A engine AirPlay é incompatível. Recompile o pacote completo."
        case .start: return "Não foi possível iniciar o AirPlay. Verifique a permissão de rede local e se outro receptor está usando as portas."
        }
    }
}
