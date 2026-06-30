import SwiftUI

/// The Settings form. Bindings write straight through to the `Settings` store
/// (UserDefaults); the AppDelegate reacts to the changes that need live effect.
struct SettingsView: View {
    @ObservedObject private var settings = Settings.shared
    @ObservedObject private var library = GlossaryLibrary.shared

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
                Button("Open Glossary File…") { library.openInEditor() }
                Button("Reveal in Finder") { library.revealInFinder() }
                Button("Reload") { library.reload() }
                Button("Copy New-Term Template") { library.copyTemplate() }
                Button("Add New Built-in Terms") { library.mergeBuiltins() }
                Button("Reset Glossary to Default", role: .destructive) { library.resetToDefault() }
            } header: {
                Text("Glossary")
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Add terms by editing the file — paste the template inside the [ … ] list, then Reload. No rebuild needed. \(library.termCount) terms loaded.")
                    if !library.status.isEmpty {
                        Text(library.status).foregroundStyle(.secondary)
                    }
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
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
        .frame(width: 460, height: 620)
    }
}
