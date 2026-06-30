import AppKit
import Combine
import ServiceManagement
import GlossaryCore

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let settings = Settings.shared
    private var statusItem: NSStatusItem!
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
            button.image = NSImage(
                systemSymbolName: "character.book.closed",
                accessibilityDescription: "Glossary"
            )
            button.image?.isTemplate = true
        }

        let menu = NSMenu()
        menu.addItem(withTitle: "Show Glossary", action: #selector(showFromMenu), keyEquivalent: "")
        let settingsItem = NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ",")
        menu.addItem(settingsItem)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit Glossary", action: #selector(quit), keyEquivalent: "q"))
        for item in menu.items { item.target = self }
        statusItem.menu = menu
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
            .sink { [weak self] _ in self?.registerHotkey() }
            .store(in: &cancellables)

        settings.$launchAtLogin
            .dropFirst()
            .sink { [weak self] enabled in self?.applyLaunchAtLogin(enabled) }
            .store(in: &cancellables)
    }
}
