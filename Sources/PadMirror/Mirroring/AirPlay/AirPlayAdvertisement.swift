// SPDX-License-Identifier: GPL-3.0-or-later
import Foundation

// DNSServiceRegister can return success while macOS is still withholding the
// advertisement pending Local Network consent. Resolve our own password-protected
// Bonjour service before telling the UI it is discoverable. Runs on main run loop.
final class AirPlayAdvertisement: NSObject, NetServiceBrowserDelegate, NetServiceDelegate {
    private var browser: NetServiceBrowser?
    private var service: NetService?
    private var expectedName = ""
    private var completion: ((Bool) -> Void)?

    func start(name: String, completion: @escaping (Bool) -> Void) {
        stop()
        expectedName = name
        self.completion = completion
        let browser = NetServiceBrowser()
        self.browser = browser
        browser.delegate = self
        browser.searchForServices(ofType: "_airplay._tcp.", inDomain: "local.")
    }
    func stop() {
        browser?.stop()
        browser?.delegate = nil
        browser = nil
        service?.stop()
        service?.delegate = nil
        service = nil
        completion = nil
    }
    private func finish(_ ready: Bool) {
        let callback = completion
        stop()
        callback?(ready)
    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        guard service.name == expectedName, self.service == nil else { return }
        self.service = service
        service.delegate = self
        service.resolve(withTimeout: 8)
    }
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String: NSNumber]) {
        finish(false)
    }
    func netServiceDidResolveAddress(_ sender: NetService) {
        guard let data = sender.txtRecordData() else { finish(false); return }
        let txt = NetService.dictionary(fromTXTRecord: data)
        finish(sender.port > 0 && txt["pw"] == Data("true".utf8))
    }
    func netService(_ sender: NetService, didNotResolve errorDict: [String: NSNumber]) { finish(false) }
}
