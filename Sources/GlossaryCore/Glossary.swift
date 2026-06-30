import Foundation

/// Loads and holds the glossary terms.
public struct Glossary: Sendable {
    public let terms: [Term]

    public init(terms: [Term]) {
        self.terms = terms
    }

    /// Decode terms from raw JSON data (the seed `glossary.json` format).
    public static func decode(from data: Data) throws -> Glossary {
        let terms = try JSONDecoder().decode([Term].self, from: data)
        return Glossary(terms: terms)
    }

    /// Load the bundled seed glossary shipped in `Resources/glossary.json`.
    public static func loadBundled() throws -> Glossary {
        guard let url = Bundle.module.url(forResource: "glossary", withExtension: "json") else {
            throw GlossaryError.resourceMissing
        }
        let data = try Data(contentsOf: url)
        return try decode(from: data)
    }
}

public extension Glossary {
    /// Built-in terms that should be merged into an existing user library on an app
    /// update: present in `bundled`, not already in the user's `existing` library,
    /// and not previously merged (so built-ins the user deliberately deleted are not
    /// resurrected). Preserves bundled order.
    static func newBuiltins(
        bundled: [Term],
        existing: [Term],
        alreadyMerged: Set<String>
    ) -> [Term] {
        let existingIDs = Set(existing.map(\.id))
        return bundled.filter { !alreadyMerged.contains($0.id) && !existingIDs.contains($0.id) }
    }
}

public enum GlossaryError: Error, Equatable, Sendable {
    case resourceMissing
}
