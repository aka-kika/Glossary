import SwiftUI
import GlossaryCore

/// The focused term with 4-tier progressive disclosure (Detail mode).
/// Level 1 (title + What It Is) is always shown; Analogy and Deep Dive reveal
/// independently via their hotkeys.
struct TermDetailView: View {
    @EnvironmentObject private var state: AppState
    let term: Term

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(term.term)
                    .font(.system(.title3, weight: .semibold))
                    .foregroundStyle(Theme.fg)
                    .padding(.bottom, 1)

                // Level 1 — always visible.
                DisclosureBlock(title: "What It Is", text: term.whatItIs, accent: Theme.whatItIsAccent)

                // Level 2 — Analogy.
                if state.isAnalogyShown {
                    DisclosureBlock(title: "Analogy", text: term.analogy, accent: Theme.analogyAccent)
                        .transition(.disclosure)
                }

                // Level 3 — Why It Matters + Example.
                if state.isDeepDiveShown {
                    DisclosureBlock(title: "Why It Matters", text: term.whyItMatters, accent: Theme.whyAccent)
                        .transition(.disclosure)
                    DisclosureBlock(title: "Example", text: term.example, accent: Theme.exampleAccent)
                        .transition(.disclosure)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .animation(.easeOut(duration: 0.16), value: state.isAnalogyShown)
        .animation(.easeOut(duration: 0.16), value: state.isDeepDiveShown)
    }
}

private extension AnyTransition {
    static var disclosure: AnyTransition {
        .move(edge: .top).combined(with: .opacity)
    }
}
