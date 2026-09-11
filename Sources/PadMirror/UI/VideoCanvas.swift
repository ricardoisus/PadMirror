// SPDX-License-Identifier: GPL-3.0-or-later
import AppKit
import AVFoundation
import SwiftUI

final class USBFrameRenderer: NSView {
    let preview = AVCaptureVideoPreviewLayer()

    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor
        preview.videoGravity = .resizeAspect
        layer?.addSublayer(preview)

    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func layout() {
        super.layout()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        preview.frame = bounds
        CATransaction.commit()
    }
    override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2 { window?.zoom(nil) } else { super.mouseDown(with: event) }
    }
}

struct VideoCanvas: NSViewRepresentable {
    let session: AVCaptureSession
    func makeNSView(context: Context) -> USBFrameRenderer {
        let view = USBFrameRenderer()
        view.preview.session = session
        return view
    }
    func updateNSView(_ view: USBFrameRenderer, context: Context) {}
}

struct AirPlayCanvas: NSViewRepresentable {
    let service: AirPlayService
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor
        service.attach(view)
        return view
    }
    func updateNSView(_ view: NSView, context: Context) {}
}

struct MirrorContentView: View {
    @ObservedObject var coordinator: MirroringCoordinator
    @State private var hovering = false
    var body: some View {
        ZStack {
            VideoCanvas(session: coordinator.engine.session)
                .opacity(coordinator.mode == .usb ? 1 : 0)
                .allowsHitTesting(coordinator.mode == .usb)
            AirPlayCanvas(service: coordinator.airPlay)
                .opacity(coordinator.mode == .airPlay ? 1 : 0)
                .allowsHitTesting(coordinator.mode == .airPlay)
            if coordinator.mode == .usb && !coordinator.sessionRunning {
                VStack(spacing: 18) {
                    Image(systemName: "ipad.and.iphone").font(.system(size: 42))
                    Text(coordinator.message).multilineTextAlignment(.center)
                    Text("Desbloqueie o dispositivo e use um cabo de dados.")
                        .font(.caption).foregroundStyle(.secondary)
                    if coordinator.selectedID != nil {
                        Button("Tentar novamente") { coordinator.select(coordinator.selectedID) }
                    }
                    Button("Usar AirPlay") { coordinator.useAirPlay() }
                        .disabled(coordinator.switching)
                }.padding(32).frame(maxWidth: 480)
            }
            if coordinator.mode == .airPlay {
                AirPlayOverlay(service: coordinator.airPlay, hovering: hovering)
            }
            VStack {
                HStack(spacing: 14) {
                    Button("USB") { coordinator.useUSB() }
                        .disabled(coordinator.mode == .usb || coordinator.switching)
                    Button("AirPlay") { coordinator.useAirPlay() }
                        .disabled(coordinator.mode == .airPlay || coordinator.switching)
                    if coordinator.mode == .usb && coordinator.devices.count > 1 {
                        Picker("Dispositivo", selection: Binding(get: { coordinator.selectedID ?? "" },
                            set: { coordinator.select($0.isEmpty ? nil : $0) })) {
                            Text("Escolha…").tag("")
                            ForEach(coordinator.devices) { Text($0.name).tag($0.id) }
                        }.frame(maxWidth: 260)
                    }
                    Spacer()
                    if coordinator.mode == .airPlay && !coordinator.devices.isEmpty {
                        Button("USB disponível — trocar") { coordinator.useUSB() }
                            .disabled(coordinator.switching)
                    }
                }.padding(12).background(.ultraThinMaterial)
                    .opacity(hovering || !coordinator.sessionRunning && coordinator.mode == .usb ? 1 : 0)
                Spacer()
            }
        }.background(.black).foregroundStyle(.white).preferredColorScheme(.dark)
            .onHover { hovering = $0 }
    }
}

private struct AirPlayOverlay: View {
    @ObservedObject var service: AirPlayService
    let hovering: Bool
    var body: some View {
        if service.state != .streaming {
            VStack(spacing: 16) {
                Image(systemName: "airplayvideo").font(.system(size: 40))
                Text(service.receiverName).font(.title2)
                Text(service.message).multilineTextAlignment(.center)
                if service.state == .ready {
                    Text("Código de acesso").font(.caption).foregroundStyle(.secondary)
                    Text(service.accessCode).font(.system(size: 36, weight: .medium, design: .monospaced))
                    Text("Digite este código no iPad quando solicitado.").font(.caption)
                }
                if service.state == .off || service.state == .failed {
                    Toggle("Áudio do dispositivo", isOn: $service.deviceAudio).toggleStyle(.checkbox)
                    Button("Ativar receptor AirPlay") { service.start() }
                }
                if service.state == .starting || service.state == .stopping { ProgressView() }
                if service.state == .ready || service.state == .starting {
                    Button("Desativar AirPlay") { service.stop() }
                }
            }.padding(32).frame(maxWidth: 560)
        } else if hovering {
            VStack {
                Spacer()
                HStack {
                    Text("AirPlay · \(service.resolution)").font(.caption)
                    Spacer()
                    Button("Desconectar e desativar") { service.stop() }
                }.padding(12).background(.ultraThinMaterial)
            }
        }
    }
}
