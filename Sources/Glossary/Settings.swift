import AppKit
import Combine

// MARK: - Option enums

enum PresentationMode: String, CaseIterable, Identifiable {
    case overlay, mini
    var id: String { rawValue }
    var label: String {
        switch self {
        case .overlay: return "Overlay (centered)"
        case .mini:    return "Mini (menu bar)"
        }
    }
}

enum PanelSize: String, CaseIterable, Identifiable {
    case small, medium, large
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
    // Width is fixed; height sets the List-mode size (rows shown). Detail mode hugs
    // its content, so this height doesn't apply there.
    var size: CGSize {
        switch self {
        case .small:  return CGSize(width: 520, height: 380)
        case .medium: return CGSize(width: 640, height: 440)
        case .large:  return CGSize(width: 760, height: 540)
        }
    }
}

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system, dark, light
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
    var nsAppearance: NSAppearance? {
        switch self {
        case .system: return nil
        case .dark:   return NSAppearance(named: .darkAqua)
        case .light:  return NSAppearance(named: .aqua)
        }
    }
}

/// A 2-key summon chord. `modifiers` use Carbon modifier masks.
struct HotkeyPreset: Identifiable, Equatable {
    let id: String
    let label: String
    let keyCode: UInt32
    let modifiers: UInt32

    // Carbon modifier masks (avoid importing Carbon here).
    private static let cmd: UInt32 = 0x0100
    private static let option: UInt32 = 0x0800
    private static let control: UInt32 = 0x1000
    // Virtual key codes.
    private static let space: UInt32 = 49
    private static let escape: UInt32 = 53
    private static let grave: UInt32 = 50

    static let all: [HotkeyPreset] = [
        .init(id: "opt-esc",        label: "⌥ Esc",        keyCode: escape, modifiers: option),
        .init(id: "ctrl-space",     label: "⌃ Space",      keyCode: space,  modifiers: control),
        .init(id: "ctrl-grave",     label: "⌃ ` (backtick)", keyCode: grave, modifiers: control),
        .init(id: "opt-space",      label: "⌥ Space",      keyCode: space,  modifiers: option),
        .init(id: "cmd-esc",        label: "⌘ Esc",        keyCode: escape, modifiers: cmd),
        .init(id: "ctrl-opt-space", label: "⌃⌥ Space",     keyCode: space,  modifiers: control | option),
    ]
    static let defaultID = "opt-esc"
    static func preset(id: String) -> HotkeyPreset { all.first { $0.id == id } ?? all[0] }

    /// Menu-item key equivalent for displaying the shortcut.
    var menuKeyEquivalent: String {
        switch keyCode {
        case 49: return " "        // space
        case 53: return "\u{1b}"   // escape ⎋
        case 50: return "`"        // backtick
        default: return ""
        }
    }

    var menuModifierFlags: NSEvent.ModifierFlags {
        var flags: NSEvent.ModifierFlags = []
        if modifiers & 0x0100 != 0 { flags.insert(.command) }
        if modifiers & 0x0800 != 0 { flags.insert(.option) }
        if modifiers & 0x1000 != 0 { flags.insert(.control) }
        if modifiers & 0x0200 != 0 { flags.insert(.shift) }
        return flags
    }
}

// MARK: - Settings store (UserDefaults-backed)

final class Settings: ObservableObject {
    static let shared = Settings()

    private enum Key {
        static let presentation = "presentation"
        static let panelSize = "panelSize"
        static let appearance = "appearance"
        static let hotkeyID = "hotkeyID"
        static let launchAtLogin = "launchAtLogin"
        static let clipboardAutoLoad = "clipboardAutoLoad"
    }

    private let defaults = UserDefaults.standard

    @Published var presentation: PresentationMode {
        didSet { defaults.set(presentation.rawValue, forKey: Key.presentation) }
    }
    @Published var panelSize: PanelSize {
        didSet { defaults.set(panelSize.rawValue, forKey: Key.panelSize) }
    }
    @Published var appearance: AppearanceMode {
        didSet { defaults.set(appearance.rawValue, forKey: Key.appearance) }
    }
    @Published var hotkeyID: String {
        didSet { defaults.set(hotkeyID, forKey: Key.hotkeyID) }
    }
    @Published var launchAtLogin: Bool {
        didSet { defaults.set(launchAtLogin, forKey: Key.launchAtLogin) }
    }
    @Published var clipboardAutoLoad: Bool {
        didSet { defaults.set(clipboardAutoLoad, forKey: Key.clipboardAutoLoad) }
    }

    var hotkey: HotkeyPreset { HotkeyPreset.preset(id: hotkeyID) }

    private init() {
        presentation = PresentationMode(rawValue: defaults.string(forKey: Key.presentation) ?? "") ?? .overlay
        panelSize = PanelSize(rawValue: defaults.string(forKey: Key.panelSize) ?? "") ?? .medium
        appearance = AppearanceMode(rawValue: defaults.string(forKey: Key.appearance) ?? "") ?? .dark
        hotkeyID = defaults.string(forKey: Key.hotkeyID) ?? HotkeyPreset.defaultID
        launchAtLogin = defaults.object(forKey: Key.launchAtLogin) as? Bool ?? false
        clipboardAutoLoad = defaults.object(forKey: Key.clipboardAutoLoad) as? Bool ?? true
    }

    func resetToDefaults() {
        presentation = .overlay
        panelSize = .medium
        appearance = .dark
        hotkeyID = HotkeyPreset.defaultID
        launchAtLogin = false
        clipboardAutoLoad = true
    }
}
