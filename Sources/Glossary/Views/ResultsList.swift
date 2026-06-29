import SwiftUI
import GlossaryCore

/// The scrollable, keyboard-navigated list of matching terms (List mode).
struct ResultsList: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        if state.results.isEmpty {
            VStack {
                Spacer()
                Text("No matches")
                    .font(.system(size: 15))
                    .foregroundStyle(Theme.fg3)
                Spacer()
            }
            .frame(maxWidth: .infinity)
        } else {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(Array(state.results.enumerated()), id: \.element.id) { index, term in
                            ResultRow(term: term, isSelected: index == state.selectionIndex)
                                .id(index)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
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

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 2)
                .fill(isSelected ? Theme.accent : .clear)
                .frame(width: 3, height: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text(term.term)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Theme.fg)
                Text(term.whatItIs)
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.fg3)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isSelected ? Theme.accent.opacity(0.16) : .clear)
        )
        .contentShape(Rectangle())
    }
}
