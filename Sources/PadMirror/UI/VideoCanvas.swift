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

struct MirrorContentView: View {
    @ObservedObject var coordinator: MirroringCoordinator
    var body: some View {
        ZStack {
            VideoCanvas(session: coordinator.engine.session)
            if !coordinator.sessionRunning {
                VStack(spacing: 18) {
                    Image(systemName: "ipad.and.iphone").font(.system(size: 42))
                    Text(coordinator.message).multilineTextAlignment(.center)
                    Text("Desbloqueie o dispositivo e use um cabo de dados.")
                        .font(.caption).foregroundStyle(.secondary)
                    if coordinator.selectedID != nil {
                        Button("Tentar novamente") { coordinator.select(coordinator.selectedID) }
                    }
                }.padding(32).frame(maxWidth: 480)
            }
            if coordinator.devices.count > 1 {
                VStack {
                    Picker("Dispositivo", selection: Binding(get: { coordinator.selectedID ?? "" },
                        set: { coordinator.select($0.isEmpty ? nil : $0) })) {
                        Text("Escolha…").tag("")
                        ForEach(coordinator.devices) { Text($0.name).tag($0.id) }
                    }.frame(width: 300).padding().background(.regularMaterial)
                    Spacer()
                }
            }
        }.background(.black).foregroundStyle(.white).preferredColorScheme(.dark)
    }
}
