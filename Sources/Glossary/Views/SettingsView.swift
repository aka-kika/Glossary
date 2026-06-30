import SwiftUI

/// The Settings form. Bindings write straight through to the `Settings` store
/// (UserDefaults); the AppDelegate reacts to the changes that need live effect.
struct SettingsView: View {
    @ObservedObject private var settings = Settings.shared

    var body: some View {
        Form {
            Section("Summon") {
                Picker("Hotkey", selection: $settings.hotkeyID) {
                    ForEach(HotkeyPreset.all) { preset in
                        Text(preset.label).tag(preset.id)
                    }
                }
                Picker("Window style", selection: $settings.presentation) {
                    ForEach(PresentationMode.allCases) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
            }

            Section("Appearance") {
                Picker("Panel size", selection: $settings.panelSize) {
                    ForEach(PanelSize.allCases) { size in
                        Text(size.label).tag(size)
                    }
                }
                .disabled(settings.presentation == .mini)

                Picker("Theme", selection: $settings.appearance) {
                    ForEach(AppearanceMode.allCases) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
            }

            Section("Behavior") {
                Toggle("Launch at login", isOn: $settings.launchAtLogin)
                Toggle("Auto-load matching term from clipboard", isOn: $settings.clipboardAutoLoad)
            }

            Section {
                Button("Reset to Defaults", role: .destructive) {
                    settings.resetToDefaults()
                }
            } footer: {
                Text("Mini mode opens a small panel from the menu-bar icon showing only the “What It Is” summary. Panel size applies to Overlay mode.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .frame(width: 440, height: 470)
    }
}
