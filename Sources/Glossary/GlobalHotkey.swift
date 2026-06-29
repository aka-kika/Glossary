import AppKit
import Carbon.HIToolbox

/// A single system-wide hotkey registered via Carbon `RegisterEventHotKey`.
/// Works without Accessibility permission. Main-thread only.
final class GlobalHotkey {
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    private let id: UInt32
    private let handler: () -> Void

    private static var nextID: UInt32 = 1
    private static var instances: [UInt32: GlobalHotkey] = [:]
    private static let signature: OSType = 0x474C5359  // 'GLSY'

    /// Convenience for the app's summon hotkey: Option + Space.
    static func optionSpace(handler: @escaping () -> Void) -> GlobalHotkey? {
        GlobalHotkey(keyCode: UInt32(kVK_Space), modifiers: UInt32(optionKey), handler: handler)
    }

    init?(keyCode: UInt32, modifiers: UInt32, handler: @escaping () -> Void) {
        self.handler = handler
        self.id = GlobalHotkey.nextID
        GlobalHotkey.nextID += 1

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
        GlobalHotkey.instances[id] = self
    }

    deinit {
        if let hotKeyRef { UnregisterEventHotKey(hotKeyRef) }
        if let eventHandlerRef { RemoveEventHandler(eventHandlerRef) }
        GlobalHotkey.instances[id] = nil
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
        GlobalHotkey.instances[firedID.id]?.handler()
        return noErr
    }
}
