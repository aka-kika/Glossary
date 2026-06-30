import SwiftUI
import AppKit

/// The Settings window. Bindings write straight through to the `Settings` store
/// (UserDefaults); the AppDelegate reacts to the changes that need live effect.
struct SettingsView: View {
    @ObservedObject private var settings = Settings.shared
    @ObservedObject private var library = GlossaryLibrary.shared

    private var version: String {
        (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String).map { "v\($0)" } ?? "v0.1.0"
    }

    private var prettyPath: String {
        library.fileURL.path.replacingOccurrences(of: NSHomeDirectory(), with: "~")
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            form
        }
        .frame(width: 480, height: 580)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 14) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 52, height: 52)
            VStack(alignment: .leading, spacing: 3) {
                Text("Glossary").font(.title2.weight(.semibold))
                Text("Keyboard-first glossary · \(version)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 18)
    }

    // MARK: - Form

    private var form: some View {
        Form {
            Section {
                Picker("Summon hotkey", selection: $settings.hotkeyID) {
                    ForEach(HotkeyPreset.all) { preset in
                        Text(preset.label).tag(preset.id)
                    }
                }
                Picker("Window style", selection: $settings.presentation) {
                    ForEach(PresentationMode.allCases) { mode in
                        Text(mode.label).tag(mode)
                    }
                }
            } header: {
                Label("Summon", systemImage: "command")
            }

            Section {
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
            } header: {
                Label("Appearance", systemImage: "paintpalette")
            } footer: {
                if settings.presentation == .mini {
                    Text("Mini mode opens a compact panel from the menu-bar icon showing only the “What It Is” summary. Panel size applies to Overlay mode.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Toggle("Launch at login", isOn: $settings.launchAtLogin)
                Toggle("Auto-load matching term from clipboard", isOn: $settings.clipboardAutoLoad)
            } header: {
                Label("Behavior", systemImage: "switch.2")
            }

            Section {
                Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                    GridRow {
                        glossaryButton("Open File…", "doc.text") { library.openInEditor() }
                        glossaryButton("Reveal in Finder", "folder") { library.revealInFinder() }
                    }
                    GridRow {
                        glossaryButton("Reload", "arrow.clockwise") { library.reload() }
                        glossaryButton("Copy Template", "doc.on.clipboard") { library.copyTemplate() }
                    }
                    GridRow {
                        glossaryButton("Add Built-ins", "sparkles") { library.mergeBuiltins() }
                        glossaryButton("Reset Glossary", "arrow.counterclockwise", role: .destructive) {
                            library.resetToDefault()
                        }
                    }
                }
                .padding(.vertical, 2)
            } header: {
                Label("Glossary", systemImage: "text.book.closed")
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Add terms by editing the file — paste the template inside the [ … ] list, then Reload. \(library.termCount) terms loaded.")
                    Text(prettyPath).font(.system(.caption2, design: .monospaced))
                    if !library.status.isEmpty {
                        Text(library.status).foregroundStyle(.primary)
                    }
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }

            Section {
                Button("Reset All Settings to Defaults", role: .destructive) {
                    settings.resetToDefaults()
                }
            }
        }
        .formStyle(.grouped)
    }

    private func glossaryButton(
        _ title: String,
        _ symbol: String,
        role: ButtonRole? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(role: role, action: action) {
            Label(title, systemImage: symbol)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
    }
}
