import Foundation
import Combine

/// Observable view-model holding all glossary UI state and transitions.
/// Pure logic — no AppKit/SwiftUI — so every transition is unit-testable.
public final class AppState: ObservableObject {

    /// The two keyboard modes. See design spec §3.
    public enum Mode: Sendable, Equatable {
        case list      // search field is first responder; typing/arrows
        case detail    // a term is focused; Space / Cmd+D / Cmd+C act on it
    }

    @Published public private(set) var query: String = ""
    @Published public private(set) var results: [Term] = []
    @Published public private(set) var selectionIndex: Int = 0
    @Published public private(set) var mode: Mode = .list
    @Published public private(set) var focusedTerm: Term? = nil

    /// Single-key progressive disclosure. `revealCount` optional blocks are shown,
    /// in order: Analogy (1), Why It Matters (2), Example (3). `Space` steps it —
    /// opening the next block until all are open, then closing them one by one,
    /// then cycling. See `stepDisclosure()`.
    @Published public private(set) var revealCount: Int = 0
    private var disclosureClosing = false
    public static let maxReveal = 3

    public var isAnalogyShown: Bool { revealCount >= 1 }
    public var isWhyShown: Bool { revealCount >= 2 }
    public var isExampleShown: Bool { revealCount >= 3 }

    /// Bumped to ask the UI to (re)focus the search field on each summon.
    @Published public private(set) var focusRequestID: Int = 0

    public let terms: [Term]
    private let matcher: FuzzyMatcher
    private let formatter: TermFormatter

    /// Minimum fuzzy score for a clipboard string to auto-load a term.
    public static let clipboardThreshold = 25
    /// Clipboard strings longer than this are treated as prose, not a term.
    public static let clipboardMaxLength = 48

    public init(
        terms: [Term],
        matcher: FuzzyMatcher = FuzzyMatcher(),
        formatter: TermFormatter = TermFormatter()
    ) {
        self.terms = terms
        self.matcher = matcher
        self.formatter = formatter
        self.results = terms
    }

    // MARK: - List mode

    /// Update the live search query (List mode).
    public func setQuery(_ newValue: String) {
        query = newValue
        results = matcher.search(newValue, in: terms)
        selectionIndex = 0
        mode = .list
        focusedTerm = nil
    }

    /// Move the highlighted result (clamped to bounds).
    public func moveSelection(by delta: Int) {
        guard !results.isEmpty else { selectionIndex = 0; return }
        selectionIndex = max(0, min(selectionIndex + delta, results.count - 1))
    }

    /// Enter Detail mode on the highlighted result.
    public func focusSelected() {
        guard results.indices.contains(selectionIndex) else { return }
        focus(results[selectionIndex])
    }

    // MARK: - Detail mode

    /// Advance single-key disclosure one step (`Space`). Opens the next block;
    /// once all are open, each press closes the last-opened block, then it cycles.
    public func stepDisclosure() {
        guard mode == .detail else { return }
        if disclosureClosing {
            revealCount -= 1
            if revealCount <= 0 { revealCount = 0; disclosureClosing = false }
        } else {
            revealCount += 1
            if revealCount >= Self.maxReveal { revealCount = Self.maxReveal; disclosureClosing = true }
        }
    }

    /// Leave Detail mode, returning to the result list (keeps query/results).
    public func returnToList() {
        mode = .list
        focusedTerm = nil
        resetDisclosure()
    }

    private func resetDisclosure() {
        revealCount = 0
        disclosureClosing = false
    }

    /// Formatted text of the active term for `Cmd+C`, or `nil` if none.
    public func copyText() -> String? {
        let active = focusedTerm ?? (results.indices.contains(selectionIndex) ? results[selectionIndex] : nil)
        return active.map(formatter.format)
    }

    /// Request the search field to take keyboard focus (called on summon).
    public func requestSearchFocus() {
        focusRequestID += 1
    }

    // MARK: - Summon / dismiss

    /// Reset everything (called on dismiss / Escape / hotkey-hide).
    public func reset() {
        query = ""
        results = terms
        selectionIndex = 0
        mode = .list
        focusedTerm = nil
        resetDisclosure()
    }

    /// On summon: resolve the clipboard string to a term, if it cleanly matches.
    public func resolve(clipboard: String) {
        reset()
        let trimmed = clipboard.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // 1. Case-insensitive exact match on the term name.
        if let exact = terms.first(where: { $0.term.lowercased() == trimmed.lowercased() }) {
            focus(exact)
            return
        }

        // 2. Strong fuzzy match — but only for short, single-line strings.
        guard trimmed.count <= Self.clipboardMaxLength,
              !trimmed.contains(where: \.isNewline) else { return }
        if let best = matcher.bestMatch(query: trimmed, in: terms, threshold: Self.clipboardThreshold) {
            focus(best)
        }
        // 3. Miss: stay in List mode (already reset).
    }

    // MARK: - Private

    private func focus(_ term: Term) {
        focusedTerm = term
        mode = .detail
        resetDisclosure()
        if let idx = results.firstIndex(of: term) {
            selectionIndex = idx
        }
    }
}
