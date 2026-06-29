import Foundation

/// A single glossary entry. Mirrors the seed `glossary.json` schema exactly.
public struct Term: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let term: String
    public let whatItIs: String
    public let analogy: String
    public let whyItMatters: String
    public let example: String

    public init(
        id: String,
        term: String,
        whatItIs: String,
        analogy: String,
        whyItMatters: String,
        example: String
    ) {
        self.id = id
        self.term = term
        self.whatItIs = whatItIs
        self.analogy = analogy
        self.whyItMatters = whyItMatters
        self.example = example
    }
}
