import Cocoa
import WebKit

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
    var window: NSWindow!
    var web: WKWebView!
    let status = NSTextField(labelWithString: "Sign in to Instagram to check the badge")
    let developerBar = NSStackView()
    var developerPanelVisible = false
    var developerMenuItem: NSMenuItem!
    var webTopWithPanel: NSLayoutConstraint!
    var webTopWithoutPanel: NSLayoutConstraint!
    var report: [String: Any] = ["state": "starting"]
    var detectedBadge = ""
    var testing = false

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set the Dock icon explicitly as well as declaring it in Info.plist.
        if let iconURL = Bundle.main.url(forResource: "AppIcon", withExtension: "icns"),
           let icon = NSImage(contentsOf: iconURL) {
            NSApp.applicationIconImage = icon
        }
        makeMenu()
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        config.userContentController.add(self, name: "badge")
        if let path = Bundle.main.path(forResource: "detector", ofType: "js"), let js = try? String(contentsOfFile: path, encoding: .utf8) {
            config.userContentController.addUserScript(WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true))
        }
        if let path = Bundle.main.path(forResource: "layout", ofType: "js"),
           let js = try? String(contentsOfFile: path, encoding: .utf8) {
            config.userContentController.addUserScript(WKUserScript(source: js, injectionTime: .atDocumentEnd, forMainFrameOnly: true))
        }
        web = WKWebView(frame: .zero, configuration: config)
        web.navigationDelegate = self
        web.uiDelegate = self
        let root = NSView()
        let bar = developerBar
        bar.orientation = .horizontal
        bar.spacing = 10
        for (title, action) in [("Instagram", #selector(home)), ("Messages", #selector(inbox)), ("Reload", #selector(reload)), ("Test Badge", #selector(testBadge)), ("Diagnostics", #selector(diagnostics))] {
            bar.addArrangedSubview(NSButton(title: title, target: self, action: action))
        }
        status.font = .systemFont(ofSize: 11)
        status.textColor = .secondaryLabelColor
        status.lineBreakMode = .byTruncatingTail
        for view in [bar, status, web!] {
            view.translatesAutoresizingMaskIntoConstraints = false
            root.addSubview(view)
        }
        webTopWithPanel = web.topAnchor.constraint(equalTo: status.bottomAnchor, constant: 8)
        webTopWithoutPanel = web.topAnchor.constraint(equalTo: root.topAnchor)
        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: root.topAnchor, constant: 10),
            bar.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 12),
            status.topAnchor.constraint(equalTo: bar.bottomAnchor, constant: 6),
            status.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 12),
            status.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -12),
            web.leadingAnchor.constraint(equalTo: root.leadingAnchor),
            web.trailingAnchor.constraint(equalTo: root.trailingAnchor),
            web.bottomAnchor.constraint(equalTo: root.bottomAnchor)
        ])
        updateDeveloperPanel()
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1150, height: 800), styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: false)
        window.title = "InstagramDock"
        window.minSize = NSSize(width: 740, height: 500)
        window.contentView = root
        window.delegate = self
        window.isReleasedWhenClosed = false
        // AppKit persists the frame in this app's preferences across launches.
        if !window.setFrameUsingName("InstagramDockMainWindow") {
            window.center()
        }
        window.setFrameAutosaveName("InstagramDockMainWindow")
        showWindow()
        home()
    }
    func makeMenu() {
        let menu = NSMenu()
        let item = NSMenuItem()
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "Show InstagramDock", action: #selector(showWindow), keyEquivalent: "0").target = self
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "Quit InstagramDock", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        item.submenu = appMenu
        menu.addItem(item)
        let edit = NSMenuItem()
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(withTitle: "Undo", action: Selector(("undo:")), keyEquivalent: "z")
        editMenu.addItem(withTitle: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        edit.submenu = editMenu
        menu.addItem(edit)
        let viewItem = NSMenuItem()
        let viewMenu = NSMenu(title: "View")
        developerMenuItem = viewMenu.addItem(withTitle: "Show Developer Panel", action: #selector(toggleDeveloperPanel), keyEquivalent: "d")
        developerMenuItem.keyEquivalentModifierMask = [.command, .shift]
        developerMenuItem.target = self
        viewMenu.addItem(.separator())
        viewMenu.addItem(withTitle: "Reload", action: #selector(reload), keyEquivalent: "r").target = self
        viewMenu.addItem(withTitle: "Home", action: #selector(home), keyEquivalent: "1").target = self
        viewMenu.addItem(withTitle: "Messages", action: #selector(inbox), keyEquivalent: "2").target = self
        viewItem.submenu = viewMenu
        menu.addItem(viewItem)
        NSApp.mainMenu = menu
    }
    @objc func toggleDeveloperPanel() {
        developerPanelVisible.toggle()
        updateDeveloperPanel()
    }
    func updateDeveloperPanel() {
        developerBar.isHidden = !developerPanelVisible
        status.isHidden = !developerPanelVisible
        if developerPanelVisible {
            webTopWithoutPanel.isActive = false
            webTopWithPanel.isActive = true
        } else {
            webTopWithPanel.isActive = false
            webTopWithoutPanel.isActive = true
        }
        developerMenuItem.title = developerPanelVisible ? "Hide Developer Panel" : "Show Developer Panel"
        developerMenuItem.state = developerPanelVisible ? .on : .off
    }
    @objc func showWindow() { window.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true) }
    @objc func home() { web.load(URLRequest(url: URL(string: "https://www.instagram.com/")!)) }
    @objc func inbox() { web.load(URLRequest(url: URL(string: "https://www.instagram.com/direct/inbox/")!)) }
    @objc func reload() { web.reload() }
    @objc func testBadge() {
        guard !testing else { return }
        testing = true
        NSApp.dockTile.badgeLabel = "7"
        status.stringValue = "Test: the Dock should display 7 for five seconds"
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let self = self else { return }
            self.testing = false
            NSApp.dockTile.badgeLabel = self.detectedBadge
            self.updateStatus()
        }
    }
    func updateStatus() {
        guard !testing else { return }
        let state = report["state"] as? String ?? "unknown"
        if state == "known" { status.stringValue = "Badge: \(detectedBadge.isEmpty ? "0" : detectedBadge) · \(report["source"] as? String ?? "")" }
        else if state == "indicator" { status.stringValue = "Unread activity detected, but Instagram does not expose a number" }
        else if state == "login" { status.stringValue = "Sign in with your Instagram account" }
        else if state == "settling" { status.stringValue = "No counter: checking whether to clear the badge (about 10 seconds)" }
        else { status.stringValue = "Count unavailable · try Home, then Messages" }
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.frameInfo.isMainFrame, let host = message.frameInfo.securityOrigin.host as String?, host == "instagram.com" || host.hasSuffix(".instagram.com"), let body = message.body as? [String: Any] else { return }
        report = body
        report["checkedAt"] = ISO8601DateFormatter().string(from: Date())
        if body["state"] as? String == "known", let n = body["count"] as? Int, (0...9999).contains(n) {
            detectedBadge = n == 0 ? "" : "\(n)\((body["minimum"] as? Bool == true) ? "+" : "")"
        } else if body["state"] as? String == "indicator" { detectedBadge = "•" }
        else if body["state"] as? String == "login" { detectedBadge = "" }
        // Unknown state keeps the previous badge rather than inventing a zero.
        if !testing { NSApp.dockTile.badgeLabel = detectedBadge }
        updateStatus()
    }
    @objc func diagnostics() {
        var payload = report
        payload["appVersion"] = "0.6"
        payload["badge"] = detectedBadge
        payload["persistentSession"] = web.configuration.websiteDataStore.isPersistent
        let data = (try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted, .sortedKeys])) ?? Data()
        let text = String(data: data, encoding: .utf8) ?? "Diagnostics unavailable"
        let alert = NSAlert()
        alert.messageText = "Badge Diagnostics"
        alert.informativeText = text + "\n\nDoes not contain passwords, names or message text. A count with + is a lower bound, not an exact total. If the state is unknown, a previous badge may be out of date."
        alert.addButton(withTitle: "Close")
        alert.addButton(withTitle: "Copy Diagnostics")
        if alert.runModal() == .alertSecondButtonReturn { NSPasteboard.general.clearContents(); NSPasteboard.general.setString(text, forType: .string) }
    }
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.saveFrame(usingName: "InstagramDockMainWindow")
        sender.orderOut(nil)
        return false
    }
    func applicationWillTerminate(_ notification: Notification) {
        window?.saveFrame(usingName: "InstagramDockMainWindow")
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool { showWindow(); return true }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else { decisionHandler(.cancel); return }
        let host = url.host ?? ""
        if url.scheme == "https" && (host == "instagram.com" || host.hasSuffix(".instagram.com")) { decisionHandler(.allow) }
        else {
            if navigationAction.navigationType == .linkActivated && ["https", "http"].contains(url.scheme ?? "") { NSWorkspace.shared.open(url) }
            decisionHandler(.cancel)
        }
    }
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url, navigationAction.targetFrame == nil {
            let host = url.host ?? ""
            if url.scheme == "https" && (host == "instagram.com" || host.hasSuffix(".instagram.com")) { webView.load(navigationAction.request) }
            else if ["https", "http"].contains(url.scheme ?? "") { NSWorkspace.shared.open(url) }
        }
        return nil
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) { status.stringValue = "Page failed to load (error \((error as NSError).code))" }
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) { status.stringValue = "Page stopped: choose Reload" }
}
let application = NSApplication.shared
let delegate = AppDelegate()
application.setActivationPolicy(.regular)
application.delegate = delegate
application.run()
