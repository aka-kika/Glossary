import AppKit
import Carbon.HIToolbox

/// A single system-wide hotkey registered via Carbon `RegisterEventHotKey`.
/// Works without Accessibility permission. Main-thread only.
///
/// Handlers are stored by id (not the object), so releasing a `GlobalHotkey`
/// actually deinits it and unregisters the key — letting the hotkey be rebound.
/// The Carbon event handler is installed exactly once.
final class GlobalHotkey {
    private var hotKeyRef: EventHotKeyRef?
    private let id: UInt32

    private static var nextID: UInt32 = 1
    private static var handlers: [UInt32: () -> Void] = [:]
    private static var eventHandlerRef: EventHandlerRef?
    private static let signature: OSType = 0x474C5359  // 'GLSY'

    init?(keyCode: UInt32, modifiers: UInt32, handler: @escaping () -> Void) {
        self.id = GlobalHotkey.nextID
        GlobalHotkey.nextID += 1
        GlobalHotkey.installHandlerIfNeeded()

        let hotKeyID = EventHotKeyID(signature: GlobalHotkey.signature, id: id)
        let status = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        guard status == noErr else { return nil }
        GlobalHotkey.handlers[id] = handler
    }

    deinit {
        if let hotKeyRef { UnregisterEventHotKey(hotKeyRef) }
        GlobalHotkey.handlers[id] = nil
    }

    /// Install the shared Carbon event handler the first time it's needed.
    private static func installHandlerIfNeeded() {
        guard eventHandlerRef == nil else { return }
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: OSType(kEventHotKeyPressed)
        )
        InstallEventHandler(
            GetApplicationEventTarget(),
            GlobalHotkey.dispatch,
            1,
            &eventType,
            nil,
            &eventHandlerRef
        )
    }

    /// C callback — looks up the firing hotkey by id and invokes its handler.
    private static let dispatch: EventHandlerUPP = { _, eventRef, _ -> OSStatus in
        var firedID = EventHotKeyID()
        GetEventParameter(
            eventRef,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &firedID
        )
        GlobalHotkey.handlers[firedID.id]?()
        return noErr
    }
}
