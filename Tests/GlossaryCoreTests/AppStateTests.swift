import Testing
@testable import GlossaryCore

@Suite("AppState transitions")
struct AppStateTests {

    private func term(_ id: String, _ name: String) -> Term {
        Term(id: id, term: name, whatItIs: "what", analogy: "analogy", whyItMatters: "why", example: "ex")
    }

    private func makeState() -> AppState {
        AppState(terms: [
            term("docker", "Docker"),
            term("dns", "DNS"),
            term("api", "API"),
        ])
    }

    @Test("Starts in list mode showing all terms")
    func initialState() {
        let s = makeState()
        #expect(s.mode == .list)
        #expect(s.results.count == 3)
        #expect(s.selectionIndex == 0)
        #expect(s.focusedTerm == nil)
    }

    @Test("Typing filters and resets selection to top")
    func queryFilters() {
        let s = makeState()
        s.moveSelection(by: 2)
        s.setQuery("d")
        #expect(s.selectionIndex == 0)
        #expect(s.results.allSatisfy { $0.term.lowercased().contains("d") })
    }

    @Test("Selection is clamped within bounds")
    func selectionClamps() {
        let s = makeState()
        s.moveSelection(by: -1)
        #expect(s.selectionIndex == 0)
        s.moveSelection(by: 99)
        #expect(s.selectionIndex == 2)
    }

    @Test("Enter focuses the highlighted term and enters detail mode")
    func focusEntersDetail() {
        let s = makeState()
        s.moveSelection(by: 1)
        s.focusSelected()
        #expect(s.mode == .detail)
        #expect(s.focusedTerm?.id == "dns")
        #expect(s.isAnalogyShown == false)
        #expect(s.isDeepDiveShown == false)
    }

    @Test("Disclosure toggles are independent and only work in detail mode")
    func disclosureToggles() {
        let s = makeState()
        s.toggleAnalogy()                 // ignored in list mode
        #expect(s.isAnalogyShown == false)

        s.focusSelected()
        s.toggleDeepDive()
        #expect(s.isDeepDiveShown == true)
        #expect(s.isAnalogyShown == false)   // independent
        s.toggleAnalogy()
        #expect(s.isAnalogyShown == true)
        s.toggleAnalogy()
        #expect(s.isAnalogyShown == false)
    }

    @Test("returnToList exits detail and clears disclosure")
    func returnToList() {
        let s = makeState()
        s.focusSelected()
        s.toggleAnalogy()
        s.returnToList()
        #expect(s.mode == .list)
        #expect(s.focusedTerm == nil)
        #expect(s.isAnalogyShown == false)
    }

    @Test("copyText returns formatted text for the active term")
    func copyText() {
        let s = makeState()
        s.focusSelected()
        let text = s.copyText()
        #expect(text?.contains("Docker") == true)
        #expect(text?.contains("What It Is") == true)
        #expect(text?.contains("Example") == true)
    }

    @Test("reset clears everything back to initial")
    func reset() {
        let s = makeState()
        s.setQuery("api")
        s.focusSelected()
        s.reset()
        #expect(s.mode == .list)
        #expect(s.query == "")
        #expect(s.results.count == 3)
        #expect(s.focusedTerm == nil)
    }
}
