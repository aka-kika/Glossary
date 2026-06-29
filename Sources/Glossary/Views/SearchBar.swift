import SwiftUI
import GlossaryCore

/// The always-present search field. Stays first responder while the overlay is
/// open; its binding drives `AppState.setQuery`, which keeps us in List mode.
struct SearchBar: View {
    @EnvironmentObject private var state: AppState
    @FocusState private var focused: Bool

    private var queryBinding: Binding<String> {
        Binding(get: { state.query }, set: { state.setQuery($0) })
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Theme.fg3)

            TextField("Search terms…", text: queryBinding)
                .textFieldStyle(.plain)
                .font(.system(size: 21, weight: .regular))
                .foregroundStyle(Theme.fg)
                .focused($focused)
                .onSubmit { state.focusSelected() }
                .accentColor(Theme.accent)
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
        .onAppear { focused = true }
        .onChange(of: state.focusRequestID) { _, _ in focused = true }
    }
}
