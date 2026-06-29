import Testing
@testable import GlossaryCore

@Suite("Fuzzy matcher")
struct FuzzyMatcherTests {

    private let matcher = FuzzyMatcher()

    private func term(_ id: String, _ name: String) -> Term {
        Term(id: id, term: name, whatItIs: "", analogy: "", whyItMatters: "", example: "")
    }

    private var sample: [Term] {
        [
            term("docker", "Docker"),
            term("dns", "DNS (Domain Name System)"),
            term("api", "API (Application Programming Interface)"),
            term("deployment", "Deployment"),
            term("git", "Git / Version Control"),
        ]
    }

    @Test("Empty query returns all terms in original order")
    func emptyReturnsAll() {
        let out = matcher.search("   ", in: sample)
        #expect(out.map(\.id) == sample.map(\.id))
    }

    @Test("Prefix match ranks first")
    func prefixWins() {
        let out = matcher.search("doc", in: sample)
        #expect(out.first?.id == "docker")
    }

    @Test("Exact name match scores highest")
    func exactBeatsPartial() {
        let exact = matcher.score(query: "Docker", candidate: "Docker")!
        let partial = matcher.score(query: "doc", candidate: "Docker")!
        #expect(exact > partial)
    }

    @Test("Non-subsequence query does not match")
    func noMatch() {
        #expect(matcher.score(query: "zzz", candidate: "Docker") == nil)
        #expect(matcher.search("zzz", in: sample).isEmpty)
    }

    @Test("Query longer than candidate does not match")
    func tooLong() {
        #expect(matcher.score(query: "dockerized", candidate: "Docker") == nil)
    }

    @Test("Matching is case-insensitive")
    func caseInsensitive() {
        #expect(matcher.score(query: "DOCKER", candidate: "docker") != nil)
    }

    @Test("Subsequence across word boundaries matches (acp-style)")
    func acronymSubsequence() {
        // 'dns' is a subsequence of "DNS (Domain Name System)"
        #expect(matcher.score(query: "dns", candidate: "DNS (Domain Name System)") != nil)
    }

    @Test("bestMatch returns nil below threshold and a term above it")
    func bestMatchThreshold() {
        #expect(matcher.bestMatch(query: "Docker", in: sample, threshold: 25)?.id == "docker")
        #expect(matcher.bestMatch(query: "zzz", in: sample, threshold: 25) == nil)
    }
}
