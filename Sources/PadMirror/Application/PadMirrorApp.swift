// SPDX-License-Identifier: GPL-3.0-or-later
import AppKit
import SwiftUI
import Combine

@main
struct PadMirrorApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.regular)
        withExtendedLifetime(delegate) { app.run() }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let coordinator = MirroringCoordinator()
    private var window: NSWindow!
    private var connectionObservation: AnyCancellable?
    func applicationDidFinishLaunching(_ notification: Notification) {
        let menu = NSMenu()
        let root = NSMenuItem()
        menu.addItem(root)
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "Quit PadMirror", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        root.submenu = appMenu
        NSApp.mainMenu = menu
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 900, height: 650),
            styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        window.title = "PadMirror"
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 360, height: 280)
        window.collectionBehavior = [.fullScreenPrimary]
        window.contentView = NSHostingView(rootView: MirrorContentView(coordinator: coordinator, airPlay: coordinator.airPlay))
        connectionObservation = coordinator.$mode
            .combineLatest(coordinator.$sessionRunning, coordinator.airPlay.$state)
            .map { mode, running, state in mode == .usb ? running : state == .streaming }
            .removeDuplicates()
            .sink { [weak self] connected in self?.updateWindowChrome(connected: connected) }
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        coordinator.begin()
    }
    private func updateWindowChrome(connected: Bool) {
        // Keep the same window and renderers so sharing and capture stay attached.
        window.titleVisibility = connected ? .hidden : .visible
        window.titlebarAppearsTransparent = connected
        if connected {
            window.styleMask.insert(.fullSizeContentView)
        } else {
            window.styleMask.remove(.fullSizeContentView)
        }
        for button: NSWindow.ButtonType in [.closeButton, .miniaturizeButton, .zoomButton] {
            window.standardWindowButton(button)?.isHidden = connected
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        window.makeKeyAndOrderFront(nil)
        return true
    }
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        coordinator.shutdown { sender.reply(toApplicationShouldTerminate: true) }
        // Keep Cocoa's run loop alive while the engine joins its worker.
        return .terminateLater
    }
}
