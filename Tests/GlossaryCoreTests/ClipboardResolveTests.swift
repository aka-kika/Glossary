import Testing
@testable import GlossaryCore

@Suite("Clipboard resolution")
struct ClipboardResolveTests {

    private func term(_ id: String, _ name: String) -> Term {
        Term(id: id, term: name, whatItIs: "what", analogy: "a", whyItMatters: "w", example: "e")
    }

    private func makeState() -> AppState {
        AppState(terms: [
            term("docker", "Docker"),
            term("api", "API (Application Programming Interface)"),
            term("dns", "DNS (Domain Name System)"),
        ])
    }

    @Test("Exact match (case-insensitive) focuses the term")
    func exactMatch() {
        let s = makeState()
        s.resolve(clipboard: "docker")
        #expect(s.mode == .detail)
        #expect(s.focusedTerm?.id == "docker")
    }

    @Test("Exact match tolerates surrounding whitespace")
    func trimmedMatch() {
        let s = makeState()
        s.resolve(clipboard: "  Docker\n")
        #expect(s.focusedTerm?.id == "docker")
    }

    @Test("Strong fuzzy match focuses the best term")
    func fuzzyMatch() {
        let s = makeState()
        s.resolve(clipboard: "api")
        #expect(s.focusedTerm?.id == "api")
    }

    @Test("Unrelated clipboard leaves list mode, no focus")
    func miss() {
        let s = makeState()
        s.resolve(clipboard: "the quick brown fox")
        #expect(s.mode == .list)
        #expect(s.focusedTerm == nil)
    }

    @Test("Empty clipboard is a no-op miss")
    func emptyClipboard() {
        let s = makeState()
        s.resolve(clipboard: "   ")
        #expect(s.mode == .list)
        #expect(s.focusedTerm == nil)
    }

    @Test("Long prose is not fuzzy-matched even if it contains the letters")
    func longProseIgnored() {
        let s = makeState()
        // contains d..o..c..k..e..r as a subsequence but is clearly prose
        s.resolve(clipboard: "I decided of course to keep every result for review")
        #expect(s.focusedTerm == nil)
    }
}
