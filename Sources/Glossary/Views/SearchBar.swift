import SwiftUI
import GlossaryCore

/// The always-present search field. Stays first responder while the overlay is
/// open; its binding drives `AppState.setQuery`, which keeps us in List mode.
/// `compact` is used by Mini mode.
struct SearchBar: View {
    var compact: Bool = false

    @EnvironmentObject private var state: AppState
    @FocusState private var focused: Bool

    private var queryBinding: Binding<String> {
        Binding(get: { state.query }, set: { state.setQuery($0) })
    }

    var body: some View {
        HStack(spacing: compact ? 8 : 11) {
            Image(systemName: "magnifyingglass")
                .font(.system(compact ? .subheadline : .body, weight: .medium))
                .foregroundStyle(Theme.fg3)

            TextField("Search terms…", text: queryBinding)
                .textFieldStyle(.plain)
                .font(.system(compact ? .body : .title3))
                .foregroundStyle(Theme.fg)
                .focused($focused)
                .onSubmit { state.focusSelected() }
                .accentColor(Theme.accent)
        }
        .padding(.horizontal, compact ? 12 : 16)
        .frame(height: compact ? 38 : 46)
        .onAppear { focused = true }
        .onChange(of: state.focusRequestID) { _, _ in focused = true }
    }
}
