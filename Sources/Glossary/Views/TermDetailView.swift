import SwiftUI
import GlossaryCore

/// The focused term with single-key progressive disclosure (Detail mode).
/// Level 1 (title + What It Is) is always shown; Space reveals Analogy → Why It
/// Matters → Example, then closes them. Sizes to its visible blocks (the window
/// hugs the content); reveal is instant — no animation, by request.
struct TermDetailView: View {
    @EnvironmentObject private var state: AppState
    let term: Term

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(term.term)
                .font(.system(.title3, weight: .semibold))
                .foregroundStyle(Theme.fg)
                .padding(.bottom, 1)

            DisclosureBlock(title: "What It Is", text: term.whatItIs, accent: Theme.whatItIsAccent)
            if state.isAnalogyShown {
                DisclosureBlock(title: "Analogy", text: term.analogy, accent: Theme.analogyAccent)
            }
            if state.isWhyShown {
                DisclosureBlock(title: "Why It Matters", text: term.whyItMatters, accent: Theme.whyAccent)
            }
            if state.isExampleShown {
                DisclosureBlock(title: "Example", text: term.example, accent: Theme.exampleAccent)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
