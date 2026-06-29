import AppKit

// Entry point. The app is a menu-bar agent — no Dock icon, no main menu bar app.
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
