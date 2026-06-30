import SwiftUI
import GlossaryCore

/// Compact view for Mini (menu-bar) mode: search + a focused term's "What It Is"
/// only. Sizes to its content (the popover uses `.preferredContentSize`), so there's
/// no empty space; the list caps at a few rows. No solid fill — the popover's native
/// material is the surface, which keeps it feeling like a real macOS menu.
struct MiniRootView: View {
    @EnvironmentObject private var state: AppState

    private let rowHeight: CGFloat = 30
    private let maxRows = 6

    var body: some View {
        VStack(spacing: 0) {
            SearchBar(compact: true)
            Divider().overlay(Theme.line)

            if state.mode == .detail, let term = state.focusedTerm {
                VStack(alignment: .leading, spacing: 8) {
                    Text(term.term)
                        .font(.system(.headline))
                        .foregroundStyle(Theme.fg)
                    DisclosureBlock(
                        title: "What It Is",
                        text: term.whatItIs,
                        accent: Theme.whatItIsAccent
                    )
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ResultsList(compact: true)
                    .frame(height: listHeight)
            }
        }
        .frame(width: 300)
        .tint(Theme.accent)
    }

    /// Height that fits the current results, capped — so few results means a short
    /// popover, not a tall one with empty space.
    private var listHeight: CGFloat {
        let count = max(min(state.results.count, maxRows), 1)
        return CGFloat(count) * rowHeight + 12
    }
}
