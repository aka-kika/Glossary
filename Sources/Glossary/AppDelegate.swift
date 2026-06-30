import AppKit
import Combine
import ServiceManagement
import GlossaryCore

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let settings = Settings.shared
    private var statusItem: NSStatusItem!
    private var showItem: NSMenuItem!
    private var overlay: OverlayPanelController!
    private var mini: MiniPopoverController!
    private let settingsWindow = SettingsWindowController()
    private var hotkey: GlobalHotkey?
    private var appState: AppState!
    private var cancellables: Set<AnyCancellable> = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Load from the user-editable file (seeded from the bundled terms first run).
        let library = GlossaryLibrary.shared
        appState = AppState(terms: library.bootstrap(), usage: DefaultsUsageStore())
        library.applyTerms = { [weak self] terms in self?.appState.updateTerms(terms) }

        overlay = OverlayPanelController(appState: appState, settings: settings)
        mini = MiniPopoverController(appState: appState, settings: settings)

        setupStatusItem()
        mini.attach(to: statusItem.button)

        registerHotkey()
        applyLaunchAtLogin(settings.launchAtLogin)
        observeSettings()
    }

    // MARK: - Presentation routing

    private func toggle() {
        switch settings.presentation {
        case .overlay:
            mini.hide()
            overlay.toggle()
        case .mini:
            overlay.hide()
            mini.toggle()
        }
    }

    @objc private func showFromMenu() {
        switch settings.presentation {
        case .overlay: overlay.show()
        case .mini:    mini.show()
        }
    }

    @objc private func openSettings() { settingsWindow.show() }
    @objc private func quit() { NSApp.terminate(nil) }

    // MARK: - Status item

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = StatusItemIcon.image()           // matches the app icon's { / }
            button.image?.accessibilityDescription = "Glossary"
        }

        let menu = NSMenu()

        showItem = NSMenuItem(title: "Show Glossary", action: #selector(showFromMenu), keyEquivalent: "")
        showItem.image = StatusItemIcon.image(size: 16)              // the app's { / } glyph
        updateShowShortcut()
        menu.addItem(showItem)

        let settingsItem = NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.image = menuSymbol("gearshape")
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit Glossary", action: #selector(quit), keyEquivalent: "q")
        quitItem.image = menuSymbol("power")
        menu.addItem(quitItem)

        for item in menu.items { item.target = self }
        statusItem.menu = menu
    }

    /// Shows the currently-configured summon hotkey beside "Show Glossary".
    private func updateShowShortcut() {
        let hk = settings.hotkey
        showItem?.keyEquivalent = hk.menuKeyEquivalent
        showItem?.keyEquivalentModifierMask = hk.menuModifierFlags
    }

    private func menuSymbol(_ name: String) -> NSImage? {
        let image = NSImage(systemSymbolName: name, accessibilityDescription: nil)
        image?.isTemplate = true
        return image
    }

    // MARK: - Hotkey

    private func registerHotkey() {
        hotkey = nil  // deinit unregisters the previous one
        let preset = settings.hotkey
        hotkey = GlobalHotkey(keyCode: preset.keyCode, modifiers: preset.modifiers) { [weak self] in
            self?.toggle()
        }
    }

    // MARK: - Launch at login

    private func applyLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                if SMAppService.mainApp.status != .enabled { try SMAppService.mainApp.register() }
            } else {
                if SMAppService.mainApp.status == .enabled { try SMAppService.mainApp.unregister() }
            }
        } catch {
            NSLog("Glossary: launch-at-login change failed: \(error.localizedDescription)")
        }
    }

    // MARK: - React to settings changes

    private func observeSettings() {
        settings.$hotkeyID
            .dropFirst()
            .sink { [weak self] _ in
                self?.registerHotkey()
                self?.updateShowShortcut()
            }
            .store(in: &cancellables)

        settings.$launchAtLogin
            .dropFirst()
            .sink { [weak self] enabled in self?.applyLaunchAtLogin(enabled) }
            .store(in: &cancellables)
    }
}
