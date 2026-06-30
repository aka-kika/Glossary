import Testing
import Foundation
@testable import GlossaryCore

@Suite("Frecency & usage ranking")
struct UsageTests {

    private func term(_ id: String, _ name: String) -> Term {
        Term(id: id, term: name, whatItIs: "w", analogy: "a", whyItMatters: "y", example: "e")
    }

    private func makeState(now: Date, store: UsageStore) -> AppState {
        AppState(
            terms: [term("a", "Alpha"), term("b", "Bravo"), term("c", "Charlie")],
            usage: store,
            clock: { now }
        )
    }

    @Test("More opens scores higher than fewer")
    func frequencyMatters() {
        let now = Date()
        #expect(frecencyScore(count: 5, lastOpened: now, now: now)
              > frecencyScore(count: 1, lastOpened: now, now: now))
    }

    @Test("Recent use scores higher than stale use for the same count")
    func recencyMatters() {
        let now = Date()
        let recent = now.addingTimeInterval(-60)            // a minute ago
        let stale  = now.addingTimeInterval(-60 * 86_400)   // ~2 months ago
        #expect(frecencyScore(count: 3, lastOpened: recent, now: now)
              > frecencyScore(count: 3, lastOpened: stale, now: now))
    }

    @Test("Never-opened scores zero")
    func zeroWhenUnused() {
        #expect(frecencyScore(count: 0, lastOpened: .distantPast, now: Date()) == 0)
    }

    @Test("Opening a term floats it to the top of the browse list")
    func openedTermFloatsUp() {
        let now = Date()
        let store = InMemoryUsageStore()
        let s = makeState(now: now, store: store)

        // Initially original order.
        #expect(s.results.map(\.id) == ["a", "b", "c"])

        // Open "Charlie" a couple of times.
        s.moveSelection(by: 2); s.focusSelected()   // focus c
        s.returnToList()
        s.focusSelected()                            // focus c again (selection stayed on c)
        s.returnToList()

        #expect(s.results.first?.id == "c")
    }

    @Test("Frecency only breaks ties — it never beats a better text match")
    func usageDoesNotOverrideRelevance() {
        let now = Date()
        let store = InMemoryUsageStore()
        // Heavily used "Bravo".
        for _ in 0..<10 { store.record("b", now: now) }
        let s = makeState(now: now, store: store)

        // Query clearly matches Alpha better than Bravo.
        s.setQuery("alph")
        #expect(s.results.first?.id == "a")
    }
}
