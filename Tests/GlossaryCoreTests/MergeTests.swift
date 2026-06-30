import Testing
@testable import GlossaryCore

@Suite("Merge new built-ins")
struct MergeTests {

    private func term(_ id: String) -> Term {
        Term(id: id, term: id, whatItIs: "", analogy: "", whyItMatters: "", example: "")
    }

    @Test("Adds built-ins that are new in this build")
    func addsNew() {
        let bundled = [term("a"), term("b"), term("c")]   // c is new this build
        let existing = [term("a"), term("b"), term("custom")]
        let added = Glossary.newBuiltins(bundled: bundled, existing: existing, alreadyMerged: ["a", "b"])
        #expect(added.map(\.id) == ["c"])
    }

    @Test("Never resurrects a built-in the user deleted")
    func respectsDeletions() {
        let bundled = [term("a"), term("b")]
        let existing = [term("a")]                          // user deleted b
        // b was already merged before, so it must NOT come back.
        let added = Glossary.newBuiltins(bundled: bundled, existing: existing, alreadyMerged: ["a", "b"])
        #expect(added.isEmpty)
    }

    @Test("Never duplicates a built-in already present")
    func noDuplicates() {
        let bundled = [term("a"), term("b")]
        let existing = [term("a"), term("b")]
        let added = Glossary.newBuiltins(bundled: bundled, existing: existing, alreadyMerged: [])
        #expect(added.isEmpty)
    }
}
