import Cocoa

final class AboutWindowController: NSWindowController {
    private let resources: Bundle
    private var licenseWindow: NSWindow?

    init(bundle: Bundle = .main) {
        resources = bundle
        let panel = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 440),
            styleMask: [.titled, .closable], backing: .buffered, defer: false
        )
        panel.title = "About InstagramDock"
        panel.isReleasedWhenClosed = false
        super.init(window: panel)
        panel.contentView = makeContent()
        panel.center()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    private func label(_ text: String, size: CGFloat, weight: NSFont.Weight = .regular,
                       secondary: Bool = false) -> NSTextField {
        let field = NSTextField(wrappingLabelWithString: text)
        field.font = .systemFont(ofSize: size, weight: weight)
        field.alignment = .center
        field.textColor = secondary ? .secondaryLabelColor : .labelColor
        field.translatesAutoresizingMaskIntoConstraints = false
        field.widthAnchor.constraint(equalToConstant: 364).isActive = true
        field.setContentCompressionResistancePriority(.required, for: .vertical)
        return field
    }

    private func makeContent() -> NSView {
        let root = NSView()
        let column = NSStackView()
        column.orientation = .vertical
        column.alignment = .centerX
        column.spacing = 12
        column.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(column)

        let icon = NSImageView()
        if let url = resources.url(forResource: "AppIcon", withExtension: "icns") {
            icon.image = NSImage(contentsOf: url)
        }
        icon.imageScaling = .scaleProportionallyUpOrDown
        icon.setAccessibilityLabel("InstagramDock app icon")
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 88),
            icon.heightAnchor.constraint(equalToConstant: 88)
        ])
        column.addArrangedSubview(icon)
        column.addArrangedSubview(label("InstagramDock", size: 23, weight: .bold))
        let version = resources.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
        column.addArrangedSubview(label("Version \(version)", size: 12, secondary: true))
        column.addArrangedSubview(label(
            "A native macOS companion for Instagram with unread-message badges in the Dock.", size: 13
        ))
        column.addArrangedSubview(label("© 2026 Gianrolando Scaringi", size: 12))
        column.addArrangedSubview(label("Open-source software · MIT License", size: 12, secondary: true))
        column.addArrangedSubview(label(
            "Independent project. Not affiliated with or endorsed by Instagram or Meta.",
            size: 11, secondary: true
        ))

        let buttons = NSStackView()
        buttons.orientation = .horizontal
        buttons.spacing = 12
        buttons.addArrangedSubview(NSButton(title: "GitHub", target: self, action: #selector(openGitHub)))
        buttons.addArrangedSubview(NSButton(title: "License", target: self, action: #selector(showLicense)))
        column.addArrangedSubview(buttons)
        NSLayoutConstraint.activate([
            column.centerXAnchor.constraint(equalTo: root.centerXAnchor),
            column.topAnchor.constraint(equalTo: root.topAnchor, constant: 24),
            column.bottomAnchor.constraint(equalTo: root.bottomAnchor, constant: -24)
        ])
        return root
    }

    @objc private func openGitHub() {
        NSWorkspace.shared.open(URL(string: "https://github.com/gianrolando/InstagramDock")!)
    }

    @objc func showLicense() {
        if let existing = licenseWindow {
            existing.makeKeyAndOrderFront(nil)
            return
        }
        let text: String
        do {
            guard let url = resources.url(forResource: "LICENSE", withExtension: "txt") else {
                throw CocoaError(.fileNoSuchFile)
            }
            text = try String(contentsOf: url, encoding: .utf8)
        } catch {
            let alert = NSAlert()
            alert.messageText = "License unavailable"
            alert.informativeText = "The bundled license could not be opened. You can find it in the GitHub repository."
            alert.addButton(withTitle: "Close")
            alert.runModal()
            return
        }
        let panel = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 640, height: 470),
            styleMask: [.titled, .closable, .resizable], backing: .buffered, defer: false
        )
        panel.title = "MIT License — InstagramDock"
        panel.minSize = NSSize(width: 420, height: 300)
        panel.isReleasedWhenClosed = false
        let scroll = NSScrollView(frame: panel.contentView!.bounds)
        scroll.hasVerticalScroller = true
        scroll.autoresizingMask = [.width, .height]
        let body = NSTextView(frame: scroll.bounds)
        body.string = text
        body.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        body.isEditable = false
        body.isSelectable = true
        body.isVerticallyResizable = true
        body.isHorizontallyResizable = false
        body.autoresizingMask = [.width]
        body.textContainerInset = NSSize(width: 18, height: 18)
        body.textContainer?.widthTracksTextView = true
        body.textContainer?.containerSize = NSSize(width: scroll.contentSize.width, height: .greatestFiniteMagnitude)
        scroll.documentView = body
        panel.contentView = scroll
        panel.center()
        licenseWindow = panel
        panel.makeKeyAndOrderFront(nil)
    }
}
