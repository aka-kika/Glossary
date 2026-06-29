import AppKit
import GlossaryCore

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var panelController: OverlayPanelController!
    private var hotkey: GlobalHotkey?
    private var appState: AppState!

    func applicationDidFinishLaunching(_ notification: Notification) {
        let glossary = (try? Glossary.loadBundled()) ?? Glossary(terms: [])
        appState = AppState(terms: glossary.terms)
        panelController = OverlayPanelController(appState: appState)

        setupStatusItem()

        // Global summon hotkey: Option + Space.
        hotkey = GlobalHotkey.optionSpace { [weak self] in
            self?.panelController.toggle()
        }
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(
                systemSymbolName: "character.book.closed",
                accessibilityDescription: "Glossary"
            )
            button.image?.isTemplate = true
        }

        let menu = NSMenu()
        menu.addItem(withTitle: "Show Glossary   ⌥Space", action: #selector(showPanel), keyEquivalent: "")
        menu.addItem(.separator())
        let quit = NSMenuItem(title: "Quit Glossary", action: #selector(quit), keyEquivalent: "q")
        menu.addItem(quit)
        for item in menu.items { item.target = self }
        statusItem.menu = menu
    }

    @objc private func showPanel() { panelController.show() }
    @objc private func quit() { NSApp.terminate(nil) }
}
