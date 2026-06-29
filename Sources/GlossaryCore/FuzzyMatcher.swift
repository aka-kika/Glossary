import Foundation

/// Subsequence-based fuzzy matcher over term names, with ranking.
public struct FuzzyMatcher: Sendable {
    public init() {}

    private static let boundaries: Set<Character> = [" ", "(", ")", "-", "/", ".", "_"]

    /// Terms whose name fuzzily matches `query`, ranked best-first.
    /// An empty/whitespace query returns all terms in their original order.
    public func search(_ query: String, in terms: [Term]) -> [Term] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return terms }

        return terms
            .compactMap { term -> (term: Term, score: Int)? in
                guard let s = score(query: q, candidate: term.term) else { return nil }
                return (term, s)
            }
            .sorted { lhs, rhs in
                if lhs.score != rhs.score { return lhs.score > rhs.score }
                return lhs.term.term.count < rhs.term.term.count
            }
            .map(\.term)
    }

    /// Score `query` as a subsequence of `candidate`. Higher is better; `nil` = no match.
    public func score(query: String, candidate: String) -> Int? {
        let q = Array(query.lowercased())
        let c = Array(candidate.lowercased())
        guard !q.isEmpty else { return 0 }
        guard q.count <= c.count else { return nil }

        var total = 0
        var qi = 0
        var previousMatch: Int? = nil

        for (ci, ch) in c.enumerated() where qi < q.count {
            guard ch == q[qi] else { continue }
            total += 1                                              // base
            if let prev = previousMatch, prev == ci - 1 { total += 5 }   // contiguous run
            if ci == 0 || Self.boundaries.contains(c[ci - 1]) { total += 8 } // word boundary
            if ci < 4 { total += (4 - ci) }                        // earliness
            previousMatch = ci
            qi += 1
        }

        guard qi == q.count else { return nil }                    // all query chars consumed?

        if c == q { total += 100 }                                 // exact
        else if c.starts(with: q) { total += 20 }                  // prefix
        return total
    }

    /// Highest-scoring term at or above `threshold` — used for clipboard resolution.
    public func bestMatch(query: String, in terms: [Term], threshold: Int) -> Term? {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return nil }

        let best = terms
            .compactMap { term -> (term: Term, score: Int)? in
                guard let s = score(query: q, candidate: term.term) else { return nil }
                return (term, s)
            }
            .max { $0.score < $1.score }

        guard let best, best.score >= threshold else { return nil }
        return best.term
    }
}
