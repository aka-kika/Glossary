import AppKit
import SwiftUI
import GlossaryCore

/// Borderless floating panel that can still accept keyboard focus.
final class OverlayPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

/// Owns the summoned overlay: shows/centers/hides it, reads the clipboard on
/// summon, and routes keystrokes to `AppState`.
final class OverlayPanelController {
    private let appState: AppState
    private var panel: OverlayPanel?
    private var keyMonitor: Any?

    /// Virtual key codes (US layout) — avoids importing Carbon here.
    private enum Key {
        static let escape: UInt16 = 53
        static let returnKey: UInt16 = 36
        static let keypadEnter: UInt16 = 76
        static let space: UInt16 = 49
        static let arrowUp: UInt16 = 126
        static let arrowDown: UInt16 = 125
        static let d: UInt16 = 2
        static let c: UInt16 = 8
    }

    init(appState: AppState) {
        self.appState = appState
    }

    // MARK: - Show / hide

    func toggle() {
        if let panel, panel.isVisible { hide() } else { show() }
    }

    func show() {
        let panel = panel ?? makePanel()
        self.panel = panel

        // Auto-load from the clipboard before the view appears.
        let clip = NSPasteboard.general.string(forType: .string) ?? ""
        appState.resolve(clipboard: clip)

        center(panel)
        installKeyMonitor()
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        DispatchQueue.main.async { [weak self] in self?.appState.requestSearchFocus() }
    }

    func hide() {
        removeKeyMonitor()
        appState.reset()
        panel?.orderOut(nil)
    }

    // MARK: - Panel construction

    private func makePanel() -> OverlayPanel {
        let panel = OverlayPanel(
            contentRect: NSRect(x: 0, y: 0, width: Theme.panelWidth, height: Theme.panelHeight),
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
        panel.isMovableByWindowBackground = false
        panel.appearance = NSAppearance(named: .darkAqua)

        let host = NSHostingView(rootView: RootView().environmentObject(appState))
        host.frame = panel.contentLayoutRect
        host.autoresizingMask = [.width, .height]
        panel.contentView = host
        return panel
    }

    private func center(_ panel: NSPanel) {
        guard let screen = NSScreen.main else { panel.center(); return }
        let frame = screen.visibleFrame
        let size = panel.frame.size
        let x = frame.midX - size.width / 2
        // Sit a little above true center — feels more natural (Raycast-style).
        let y = frame.midY - size.height / 2 + frame.height * 0.08
        panel.setFrameOrigin(NSPoint(x: x, y: y))
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

    /// Returns true if the event was consumed (should not reach the text field).
    private func handle(_ event: NSEvent) -> Bool {
        let isCommand = event.modifierFlags.contains(.command)

        switch event.keyCode {
        case Key.escape:
            hide()
            return true

        case Key.arrowDown:
            if appState.mode == .detail { appState.returnToList() }
            appState.moveSelection(by: 1)
            return true

        case Key.arrowUp:
            if appState.mode == .detail { appState.returnToList() }
            appState.moveSelection(by: -1)
            return true

        case Key.returnKey, Key.keypadEnter:
            if appState.mode == .list { appState.focusSelected() }
            else { appState.toggleAnalogy() }
            return true

        case Key.space where appState.mode == .detail:
            appState.toggleAnalogy()
            return true

        case Key.d where isCommand:
            appState.toggleDeepDive()
            return true

        case Key.c where isCommand:
            if let text = appState.copyText() {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(text, forType: .string)
            }
            return true

        default:
            // Everything else (letters, space-in-list-mode, backspace) flows to
            // the search field, whose binding calls AppState.setQuery → List mode.
            return false
        }
    }
}
