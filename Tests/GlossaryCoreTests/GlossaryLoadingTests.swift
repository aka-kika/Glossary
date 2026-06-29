import Testing
import Foundation
@testable import GlossaryCore

@Suite("Glossary loading")
struct GlossaryLoadingTests {

    @Test("Bundled glossary decodes all 24 seed terms")
    func loadsBundled() throws {
        let glossary = try Glossary.loadBundled()
        #expect(glossary.terms.count == 24)
    }

    @Test("Every term has all required, non-empty fields")
    func fieldsPresent() throws {
        let glossary = try Glossary.loadBundled()
        for t in glossary.terms {
            #expect(!t.id.isEmpty)
            #expect(!t.term.isEmpty)
            #expect(!t.whatItIs.isEmpty)
            #expect(!t.analogy.isEmpty)
            #expect(!t.whyItMatters.isEmpty)
            #expect(!t.example.isEmpty)
        }
    }

    @Test("Term ids are unique")
    func uniqueIDs() throws {
        let glossary = try Glossary.loadBundled()
        let ids = Set(glossary.terms.map(\.id))
        #expect(ids.count == glossary.terms.count)
    }

    @Test("Decodes from raw JSON data")
    func decodesRawData() throws {
        let json = """
        [{"id":"x","term":"X","whatItIs":"a","analogy":"b","whyItMatters":"c","example":"d"}]
        """.data(using: .utf8)!
        let glossary = try Glossary.decode(from: json)
        #expect(glossary.terms.first?.term == "X")
    }
}
