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

public enum GlossaryError: Error, Equatable, Sendable {
    case resourceMissing
}
