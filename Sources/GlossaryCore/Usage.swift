import Foundation

/// Per-term usage record used for frecency ranking.
public struct UsageStat: Codable, Equatable, Sendable {
    public var count: Int
    public var lastOpened: Date

    public init(count: Int = 0, lastOpened: Date = .distantPast) {
        self.count = count
        self.lastOpened = lastOpened
    }
}

/// Frecency = open frequency weighted by how recently the term was last opened,
/// so old habits fade. Higher is "more relevant". Returns 0 for never-opened.
public func frecencyScore(count: Int, lastOpened: Date, now: Date) -> Double {
    guard count > 0 else { return 0 }
    let age = now.timeIntervalSince(lastOpened)
    let weight: Double
    switch age {
    case ..<3_600:       weight = 6     // < 1 hour
    case ..<86_400:      weight = 4     // < 1 day
    case ..<604_800:     weight = 2     // < 1 week
    case ..<2_592_000:   weight = 1     // < ~1 month
    case ..<31_536_000:  weight = 0.5   // < ~1 year
    default:             weight = 0.25
    }
    return Double(count) * weight
}

/// Records and supplies per-term usage. Persistence is an implementation detail
/// (UserDefaults in the app, in-memory in tests).
public protocol UsageStore: AnyObject {
    func stat(for id: String) -> UsageStat
    func record(_ id: String, now: Date)
    func reset()
}

public extension UsageStore {
    /// Frecency score for a term id at `now`.
    func score(for id: String, now: Date) -> Double {
        let s = stat(for: id)
        return frecencyScore(count: s.count, lastOpened: s.lastOpened, now: now)
    }
}

/// Non-persistent store — the default for `AppState` and for tests.
public final class InMemoryUsageStore: UsageStore {
    private var stats: [String: UsageStat] = [:]

    public init() {}

    public func stat(for id: String) -> UsageStat { stats[id] ?? UsageStat() }

    public func record(_ id: String, now: Date) {
        var s = stats[id] ?? UsageStat()
        s.count += 1
        s.lastOpened = now
        stats[id] = s
    }

    public func reset() { stats.removeAll() }
}
