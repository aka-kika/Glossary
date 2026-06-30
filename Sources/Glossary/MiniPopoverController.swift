import AppKit
import SwiftUI
import GlossaryCore

/// Owns the Mini presentation mode: an `NSPopover` anchored to the menu-bar item
/// showing search + only the "What It Is" summary. Keyboard-driven like the overlay,
/// minus the analogy / deep-dive toggles.
final class MiniPopoverController {
    private let appState: AppState
    private let settings: Settings
    private weak var statusButton: NSStatusBarButton?
    private var popover: NSPopover?
    private var keyMonitor: Any?

    init(appState: AppState, settings: Settings) {
        self.appState = appState
        self.settings = settings
    }

    func attach(to button: NSStatusBarButton?) { statusButton = button }

    var isVisible: Bool { popover?.isShown ?? false }

    func toggle() {
        if isVisible { hide() } else { show() }
    }

    func show() {
        guard let button = statusButton else { return }

        let appearance = settings.appearance.nsAppearance ?? NSApp.effectiveAppearance
        let host = NSHostingController(rootView: MiniRootView().environmentObject(appState))
        // Track the SwiftUI content's ideal size so the popover stays compact and
        // grows/shrinks with the content instead of being a fixed box.
        host.sizingOptions = [.preferredContentSize]

        let popover = NSPopover()
        popover.behavior = .transient
        popover.animates = true
        popover.appearance = appearance
        popover.contentViewController = host
        self.popover = popover

        if settings.clipboardAutoLoad {
            appState.resolve(clipboard: NSPasteboard.general.string(forType: .string) ?? "")
        } else {
            appState.reset()
        }

        installKeyMonitor()
        NSApp.activate(ignoringOtherApps: true)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        DispatchQueue.main.async { [weak self] in self?.appState.requestSearchFocus() }
    }

    func hide() {
        removeKeyMonitor()
        appState.reset()
        popover?.performClose(nil)
        popover = nil
    }

    // MARK: - Key routing (mini subset: no analogy / deep dive)

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
            if appState.mode == .list { appState.focusSelected() }
            return true
        case KeyCode.c where isCommand:
            copyActiveTerm(appState)
            return true
        default:
            return false
        }
    }
}
