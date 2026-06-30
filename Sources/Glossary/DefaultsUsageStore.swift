import Foundation
import GlossaryCore

/// `UsageStore` persisted in UserDefaults as a JSON `[id: UsageStat]` map.
final class DefaultsUsageStore: UsageStore {
    private let defaults = UserDefaults.standard
    private let key = "termUsage"
    private var stats: [String: UsageStat]

    init() {
        if let data = defaults.data(forKey: key),
           let decoded = try? JSONDecoder().decode([String: UsageStat].self, from: data) {
            stats = decoded
        } else {
            stats = [:]
        }
    }

    func stat(for id: String) -> UsageStat { stats[id] ?? UsageStat() }

    func record(_ id: String, now: Date) {
        var s = stats[id] ?? UsageStat()
        s.count += 1
        s.lastOpened = now
        stats[id] = s
        save()
    }

    func reset() {
        stats.removeAll()
        save()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(stats) {
            defaults.set(data, forKey: key)
        }
    }
}
