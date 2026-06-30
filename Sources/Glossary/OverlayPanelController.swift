import AppKit
import SwiftUI
import Combine
import GlossaryCore

/// Borderless floating panel that can still accept keyboard focus.
final class OverlayPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

/// Owns the centered overlay (Overlay presentation mode): shows/centers/hides it,
/// reads the clipboard on summon, sizes the window to hug its content (instantly,
/// no animation), and routes keystrokes to `AppState`.
final class OverlayPanelController {
    private let appState: AppState
    private let settings: Settings
    private var panel: OverlayPanel?
    private var hostingView: NSHostingView<AnyView>?
    private var keyMonitor: Any?
    private var sizeObserver: AnyCancellable?

    /// Search bar + divider + footer — used to derive the list body height so List
    /// mode keeps the chosen preset's overall size.
    private let chromeHeight: CGFloat = 84

    init(appState: AppState, settings: Settings) {
        self.appState = appState
        self.settings = settings
    }

    var isVisible: Bool { panel?.isVisible ?? false }

    // MARK: - Show / hide

    func toggle() {
        if isVisible { hide() } else { show() }
    }

    func show() {
        if let panel { panel.orderOut(nil) }
        let panel = makePanel()
        self.panel = panel

        if settings.clipboardAutoLoad {
            appState.resolve(clipboard: NSPasteboard.general.string(forType: .string) ?? "")
        } else {
            appState.reset()
        }

        fitToContent(center: true)
        // Re-fit instantly as content changes (mode switch, disclosure, results).
        sizeObserver = appState.objectWillChange
            .sink { [weak self] in DispatchQueue.main.async { self?.fitToContent(center: false) } }

        installKeyMonitor()
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        DispatchQueue.main.async { [weak self] in self?.appState.requestSearchFocus() }
    }

    func hide() {
        sizeObserver?.cancel(); sizeObserver = nil
        removeKeyMonitor()
        appState.reset()
        panel?.orderOut(nil)
    }

    // MARK: - Content-fit sizing (instant — no animation)

    /// Size the panel to the content's ideal height (width fixed by the preset),
    /// keeping the top edge fixed so blocks reveal downward. Instant, no animation.
    private func fitToContent(center: Bool) {
        guard let panel, let host = hostingView else { return }
        host.layoutSubtreeIfNeeded()
        var size = host.fittingSize
        guard size.width > 1, size.height > 1 else { return }

        let visible = (panel.screen ?? NSScreen.main)?.visibleFrame
        if let visible { size.height = min(size.height, visible.height - 40) }

        let old = panel.frame
        var origin = NSPoint(x: old.origin.x, y: old.maxY - size.height)  // anchor top
        if center, let visible {
            origin.x = visible.midX - size.width / 2
            origin.y = visible.midY - size.height / 2 + visible.height * 0.08
        }
        if let visible {
            origin.y = max(visible.minY, min(origin.y, visible.maxY - size.height))
        }
        panel.setFrame(NSRect(origin: origin, size: size), display: true, animate: false)
    }

    // MARK: - Panel construction

    private func makePanel() -> OverlayPanel {
        let preset = settings.panelSize.size
        let appearance = settings.appearance.nsAppearance ?? NSApp.effectiveAppearance
        let isDark = Theme.isDark(appearance)

        let panel = OverlayPanel(
            contentRect: NSRect(origin: .zero, size: preset),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.appearance = appearance

        let visual = NSVisualEffectView()
        visual.material = isDark ? .hudWindow : .menu
        visual.blendingMode = .behindWindow
        visual.state = .active
        visual.appearance = appearance
        visual.wantsLayer = true
        visual.layer?.cornerRadius = Theme.cornerRadius
        visual.layer?.cornerCurve = .continuous
        visual.layer?.masksToBounds = true
        visual.layer?.borderWidth = 1
        visual.layer?.borderColor = NSColor(white: isDark ? 0.9 : 0.0, alpha: 0.10).cgColor

        let root = RootView(width: preset.width, listBodyHeight: preset.height - chromeHeight)
            .environmentObject(appState)
        let host = NSHostingView(rootView: AnyView(root))
        host.translatesAutoresizingMaskIntoConstraints = false
        visual.addSubview(host)
        NSLayoutConstraint.activate([
            host.leadingAnchor.constraint(equalTo: visual.leadingAnchor),
            host.trailingAnchor.constraint(equalTo: visual.trailingAnchor),
            host.topAnchor.constraint(equalTo: visual.topAnchor),
            host.bottomAnchor.constraint(equalTo: visual.bottomAnchor),
        ])
        self.hostingView = host

        panel.contentView = visual
        return panel
    }

    // MARK: - Key routing (see design spec §3)

    private func installKeyMonitor() {
        guard keyMonitor == nil else { return }
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            guard let self else { return event }
            return self.handle(event) ? nil : event
        }
    }

    private func removeKeyMonitor() {
        if let keyMonitor { NSEvent.removeMonitor(keyMonitor) }
        keyMonitor = nil
    }

    /// Returns true if the event was consumed.
    private func handle(_ event: NSEvent) -> Bool {
        let isCommand = event.modifierFlags.contains(.command)

        switch event.keyCode {
        case KeyCode.escape:
            if appState.mode == .detail { appState.returnToList() } else { hide() }
            return true

        case KeyCode.arrowDown:
            if appState.mode == .detail { appState.returnToList() }
            appState.moveSelection(by: 1)
            return true

        case KeyCode.arrowUp:
            if appState.mode == .detail { appState.returnToList() }
            appState.moveSelection(by: -1)
            return true

        case KeyCode.returnKey, KeyCode.keypadEnter:
            if appState.mode == .list { appState.focusSelected() } else { appState.stepDisclosure() }
            return true

        case KeyCode.space where appState.mode == .detail:
            appState.stepDisclosure()
            return true

        case KeyCode.c where isCommand:
            copyActiveTerm(appState)
            return true

        default:
            return false
        }
    }
}

/// Virtual key codes (US layout), shared by the overlay and mini controllers.
enum KeyCode {
    static let escape: UInt16 = 53
    static let returnKey: UInt16 = 36
    static let keypadEnter: UInt16 = 76
    static let space: UInt16 = 49
    static let arrowUp: UInt16 = 126
    static let arrowDown: UInt16 = 125
    static let d: UInt16 = 2
    static let c: UInt16 = 8
}

/// Copies the active term's formatted block to the pasteboard.
func copyActiveTerm(_ appState: AppState) {
    guard let text = appState.copyText() else { return }
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(text, forType: .string)
}
