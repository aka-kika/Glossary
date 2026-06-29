import Foundation

/// Produces the plain-text block copied to the clipboard via `Cmd+C`.
public struct TermFormatter: Sendable {
    public init() {}

    public func format(_ term: Term) -> String {
        """
        \(term.term)

        What It Is
        \(term.whatItIs)

        Analogy
        \(term.analogy)

        Why It Matters
        \(term.whyItMatters)

        Example
        \(term.example)
        """
    }
}
