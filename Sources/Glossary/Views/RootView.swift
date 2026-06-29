import SwiftUI
import GlossaryCore

/// The whole overlay: search bar on top, then results (List mode) or the focused
/// term (Detail mode), then a keyboard-hint footer. Wrapped in glassmorphism.
struct RootView: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        VStack(spacing: 0) {
            SearchBar()
            Divider().overlay(Theme.line)

            Group {
                if state.mode == .detail, let term = state.focusedTerm {
                    TermDetailView(term: term)
                } else {
                    ResultsList()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            HintFooter()
        }
        .frame(width: Theme.panelWidth, height: Theme.panelHeight)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .strokeBorder(Theme.line, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .tint(Theme.accent)
        .environment(\.colorScheme, .dark)
    }
}

/// Compact keyboard hints along the bottom edge.
private struct HintFooter: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        HStack(spacing: 16) {
            if state.mode == .detail {
                hint("space", "Analogy")
                hint("⌘D", "Deep dive")
                hint("⌘C", "Copy")
            } else {
                hint("↑↓", "Navigate")
                hint("↵", "Open")
            }
            Spacer()
            hint("esc", "Close")
        }
        .font(.system(size: 11, weight: .medium))
        .foregroundStyle(Theme.fg3)
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(Theme.line2)
    }

    private func hint(_ key: String, _ label: String) -> some View {
        HStack(spacing: 5) {
            Text(key)
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(Theme.fg2)
                .padding(.horizontal, 5)
                .padding(.vertical, 1)
                .background(Theme.line, in: RoundedRectangle(cornerRadius: 4))
            Text(label)
        }
    }
}
