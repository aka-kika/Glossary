import SwiftUI
import GlossaryCore

/// The scrollable, keyboard-navigated list of matching terms (List mode).
/// `compact` (Mini mode) drops the subtitle and tightens everything.
struct ResultsList: View {
    var compact: Bool = false

    @EnvironmentObject private var state: AppState

    var body: some View {
        if state.results.isEmpty {
            Text("No matches")
                .font(.system(.subheadline))
                .foregroundStyle(Theme.fg3)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: compact ? 1 : 2) {
                        ForEach(Array(state.results.enumerated()), id: \.element.id) { index, term in
                            ResultRow(term: term, isSelected: index == state.selectionIndex, compact: compact)
                                .id(index)
                        }
                    }
                    .padding(.horizontal, compact ? 6 : 8)
                    .padding(.vertical, compact ? 6 : 8)
                }
                .onChange(of: state.selectionIndex) { _, newValue in
                    withAnimation(.easeOut(duration: 0.12)) {
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
        }
    }
}

private struct ResultRow: View {
    let term: Term
    let isSelected: Bool
    var compact: Bool = false

    var body: some View {
        HStack(spacing: compact ? 9 : 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(isSelected ? Theme.accent : .clear)
                .frame(width: 3, height: compact ? 14 : 20)

            if compact {
                Text(term.term)
                    .font(.system(.callout, weight: .medium))
                    .foregroundStyle(Theme.fg)
                    .lineLimit(1)
            } else {
                VStack(alignment: .leading, spacing: 1) {
                    Text(term.term)
                        .font(.system(.body, weight: .medium))
                        .foregroundStyle(Theme.fg)
                    Text(term.whatItIs)
                        .font(.system(.caption))
                        .foregroundStyle(Theme.fg3)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, compact ? 8 : 10)
        .padding(.vertical, compact ? 5 : 7)
        .background(
            RoundedRectangle(cornerRadius: compact ? 7 : 9, style: .continuous)
                .fill(isSelected ? Theme.accent.opacity(0.16) : .clear)
        )
        .contentShape(Rectangle())
    }
}
