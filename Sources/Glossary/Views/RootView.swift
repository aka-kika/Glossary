import SwiftUI
import GlossaryCore

/// The whole overlay: search bar on top, then results (List mode) or the focused
/// term (Detail mode), then a keyboard-hint footer. Wrapped in glassmorphism.
struct RootView: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.colorScheme) private var scheme

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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Let the window vibrancy carry the surface. In dark we add a strong KIKA
        // tint for legibility over the dark HUD material + a faint top sheen; in
        // light we keep the tint very light so it reads as a native translucent
        // panel rather than a flat white fill.
        .background {
            ZStack {
                Theme.bg.opacity(scheme == .dark ? 0.72 : 0.14)
                if scheme == .dark {
                    LinearGradient(
                        colors: [Color.white.opacity(0.05), .clear],
                        startPoint: .top, endPoint: .center
                    )
                }
            }
        }
        .tint(Theme.accent)
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
            hint("esc", state.mode == .detail ? "Back" : "Close")
        }
        .font(.system(.caption2, weight: .medium))
        .foregroundStyle(Theme.fg3)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Theme.line2)
    }

    private func hint(_ key: String, _ label: String) -> some View {
        HStack(spacing: 4) {
            Text(key)
                .font(.system(.caption2, design: .monospaced, weight: .semibold))
                .foregroundStyle(Theme.fg2)
                .padding(.horizontal, 4)
                .padding(.vertical, 1)
                .background(Theme.line, in: RoundedRectangle(cornerRadius: 4))
            Text(label)
        }
    }
}
