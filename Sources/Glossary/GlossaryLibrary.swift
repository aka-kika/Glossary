import AppKit
import GlossaryCore

/// Manages the user-editable glossary file in Application Support. On first run it
/// seeds the file from the bundled 54 terms; thereafter the file is the source of
/// truth, so terms can be added without rebuilding the app.
final class GlossaryLibrary: ObservableObject {
    static let shared = GlossaryLibrary()

    @Published private(set) var status: String = ""
    @Published private(set) var termCount: Int = 0

    /// Set by AppDelegate to push reloaded terms into the running app.
    var applyTerms: (([Term]) -> Void)?

    private let fileManager = FileManager.default
    private let defaults = UserDefaults.standard
    private let mergedKey = "mergedBuiltinIDs"

    /// Built-in ids we've already offered to the user's library, so deleted
    /// built-ins aren't resurrected and only genuinely new ones get merged.
    private var mergedBuiltinIDs: Set<String> {
        get { Set(defaults.stringArray(forKey: mergedKey) ?? []) }
        set { defaults.set(Array(newValue), forKey: mergedKey) }
    }

    /// `~/Library/Application Support/Glossary/glossary.json`
    var fileURL: URL {
        let base = (try? fileManager.url(
            for: .applicationSupportDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true
        )) ?? fileManager.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support")
        return base
            .appendingPathComponent("Glossary", isDirectory: true)
            .appendingPathComponent("glossary.json")
    }

    /// The exact JSON shape for a new term — also copied by the template button.
    static let termTemplate = """
    {
      "id": "my-term",
      "term": "My Term",
      "whatItIs": "One-sentence plain summary.",
      "analogy": "A vivid everyday comparison.",
      "whyItMatters": "Why it's useful in one sentence.",
      "example": "A concrete example."
    }
    """

    // MARK: - Lifecycle

    /// Ensure the file exists (seed first run), merge any new built-ins from this
    /// app version, and return the loaded terms.
    func bootstrap() -> [Term] {
        if fileManager.fileExists(atPath: fileURL.path) {
            mergeNewBuiltins(announce: false)
        } else {
            seedFresh()
        }
        return loadFromDisk(announce: false)
    }

    // MARK: - Actions (wired to Settings buttons)

    func reload() {
        applyTerms?(loadFromDisk(announce: true))
    }

    /// Add built-in terms introduced in this app version that the user doesn't
    /// already have (and hasn't deleted), preserving their custom terms and edits.
    @discardableResult
    func mergeNewBuiltins(announce: Bool) -> Int {
        guard let bundled = try? Glossary.loadBundled().terms else { return 0 }

        // Read the user's current library; if it's unreadable, leave the merge
        // record untouched so we retry once the JSON is fixed.
        guard let data = try? Data(contentsOf: fileURL),
              var terms = try? JSONDecoder().decode([Term].self, from: data) else {
            if announce { status = "Couldn't read your file — fix the JSON, then try again." }
            return 0
        }

        let toAdd = Glossary.newBuiltins(
            bundled: bundled, existing: terms, alreadyMerged: mergedBuiltinIDs
        )
        if !toAdd.isEmpty {
            terms.append(contentsOf: toAdd)
            try? prettyEncoded(terms).write(to: fileURL)
            termCount = terms.count
        }
        mergedBuiltinIDs = mergedBuiltinIDs.union(bundled.map(\.id))

        if announce {
            status = toAdd.isEmpty
                ? "No new built-in terms to add."
                : "Added \(toAdd.count) new built-in term\(toAdd.count == 1 ? "" : "s")."
        }
        return toAdd.count
    }

    /// Manual trigger for the Settings button.
    func mergeBuiltins() {
        mergeNewBuiltins(announce: true)
        applyTerms?(loadFromDisk(announce: false))
    }

    func resetToDefault() {
        seedFresh()
        status = "Reset to the built-in defaults."
        applyTerms?(loadFromDisk(announce: false))
    }

    func revealInFinder() {
        NSWorkspace.shared.activateFileViewerSelecting([fileURL])
    }

    func openInEditor() {
        NSWorkspace.shared.open(fileURL)
    }

    func copyTemplate() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(Self.termTemplate, forType: .string)
        status = "Template copied — paste it into the [ … ] list, then Reload."
    }

    // MARK: - Disk

    /// Write the bundled terms as the file and mark all of them as already-merged.
    private func seedFresh() {
        let dir = fileURL.deletingLastPathComponent()
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        guard let terms = try? Glossary.loadBundled().terms else { return }
        try? prettyEncoded(terms).write(to: fileURL)
        mergedBuiltinIDs = Set(terms.map(\.id))
    }

    private func loadFromDisk(announce: Bool) -> [Term] {
        do {
            let data = try Data(contentsOf: fileURL)
            let terms = try JSONDecoder().decode([Term].self, from: data)
            termCount = terms.count
            if announce { status = "Reloaded \(terms.count) terms." }
            return terms
        } catch {
            let fallback = (try? Glossary.loadBundled().terms) ?? []
            termCount = fallback.count
            status = "Couldn't read your file: \(error.localizedDescription). "
                + "Using the built-in \(fallback.count) for now — fix the JSON and Reload."
            return fallback
        }
    }

    /// Pretty JSON with fields in a fixed, human-friendly order (matching the
    /// template) — Foundation's `JSONEncoder` won't preserve field order, and this
    /// file is meant to be hand-edited.
    private func prettyEncoded(_ terms: [Term]) -> Data {
        var out = "[\n"
        for (i, t) in terms.enumerated() {
            out += "  {\n"
            out += "    \"id\": \(json(t.id)),\n"
            out += "    \"term\": \(json(t.term)),\n"
            out += "    \"whatItIs\": \(json(t.whatItIs)),\n"
            out += "    \"analogy\": \(json(t.analogy)),\n"
            out += "    \"whyItMatters\": \(json(t.whyItMatters)),\n"
            out += "    \"example\": \(json(t.example))\n"
            out += (i == terms.count - 1) ? "  }\n" : "  },\n"
        }
        out += "]\n"
        return Data(out.utf8)
    }

    /// Escape a Swift string into a JSON string literal (with surrounding quotes).
    private func json(_ s: String) -> String {
        var r = "\""
        for scalar in s.unicodeScalars {
            switch scalar {
            case "\"": r += "\\\""
            case "\\": r += "\\\\"
            case "\n": r += "\\n"
            case "\r": r += "\\r"
            case "\t": r += "\\t"
            default:
                if scalar.value < 0x20 {
                    r += String(format: "\\u%04x", scalar.value)
                } else {
                    r.unicodeScalars.append(scalar)
                }
            }
        }
        return r + "\""
    }
}
