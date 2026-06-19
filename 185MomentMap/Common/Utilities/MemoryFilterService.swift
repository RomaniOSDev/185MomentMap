import Foundation
import CoreLocation

enum DateRangeFilter: String, CaseIterable, Identifiable, Codable {
    case all
    case week
    case month
    case year

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: return "All Time"
        case .week: return "This Week"
        case .month: return "This Month"
        case .year: return "This Year"
        }
    }
}

struct MemoryFilterCriteria: Equatable {
    var mood: Mood?
    var tags: Set<MemoryTag> = []
    var tripId: UUID?
    var favoritesOnly: Bool = false
    var dateRange: DateRangeFilter = .all
    var searchQuery: String = ""
    var nearMeEnabled: Bool = false
    var nearMeLatitude: Double?
    var nearMeLongitude: Double?
    var nearMeRadiusKm: Double = 10
    var includeDrafts: Bool = false
}

enum MemoryFilterService {
    static func apply(_ criteria: MemoryFilterCriteria, to memories: [Memory]) -> [Memory] {
        var result = memories

        if !criteria.includeDrafts {
            result = result.filter { !$0.isDraft }
        }

        if criteria.favoritesOnly {
            result = result.filter(\.isFavorite)
        }

        if let mood = criteria.mood {
            result = result.filter { $0.mood == mood }
        }

        if !criteria.tags.isEmpty {
            result = result.filter { !Set($0.tags).isDisjoint(with: criteria.tags) }
        }

        if let tripId = criteria.tripId {
            result = result.filter { $0.tripId == tripId }
        }

        result = filterByDateRange(criteria.dateRange, memories: result)

        if !criteria.searchQuery.isEmpty {
            result = extendedSearch(criteria.searchQuery, in: result)
        }

        if criteria.nearMeEnabled,
           let lat = criteria.nearMeLatitude,
           let lon = criteria.nearMeLongitude {
            result = result.filter {
                LocationHelper.distanceKm(
                    from: lat, lon1: lon,
                    to: $0.latitude, lon2: $0.longitude
                ) <= criteria.nearMeRadiusKm
            }
        }

        return result
    }

    static func extendedSearch(_ query: String, in memories: [Memory]) -> [Memory] {
        let q = query.lowercased()
        return memories.filter { memory in
            memory.title.localizedCaseInsensitiveContains(q)
                || (memory.address?.localizedCaseInsensitiveContains(q) ?? false)
                || (memory.note?.localizedCaseInsensitiveContains(q) ?? false)
                || memory.mood.displayName.localizedCaseInsensitiveContains(q)
                || memory.mood.rawValue.contains(q)
                || memory.tags.contains { $0.displayName.localizedCaseInsensitiveContains(q) }
        }
    }

    static func filterByDateRange(_ range: DateRangeFilter, memories: [Memory]) -> [Memory] {
        guard range != .all else { return memories }
        let calendar = Calendar.current
        let now = Date()
        let start: Date?
        switch range {
        case .all: start = nil
        case .week: start = calendar.date(byAdding: .day, value: -7, to: now)
        case .month: start = calendar.date(byAdding: .month, value: -1, to: now)
        case .year: start = calendar.date(byAdding: .year, value: -1, to: now)
        }
        guard let start else { return memories }
        return memories.filter { $0.date >= start }
    }

    static func sortWithPinnedFirst(_ memories: [Memory], by sort: FeedSortOption) -> [Memory] {
        let pinned = memories.filter(\.isPinned)
        let unpinned = memories.filter { !$0.isPinned }
        return sortMemories(pinned, by: sort) + sortMemories(unpinned, by: sort)
    }

    static func sortMemories(_ memories: [Memory], by option: FeedSortOption) -> [Memory] {
        switch option {
        case .dateNewest:
            return memories.sorted { $0.date > $1.date }
        case .dateOldest:
            return memories.sorted { $0.date < $1.date }
        case .title:
            return memories.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }
    }

    static func onThisDayMemories(from memories: [Memory], referenceDate: Date = Date()) -> [Memory] {
        let calendar = Calendar.current
        let refComponents = calendar.dateComponents([.month, .day], from: referenceDate)
        return memories.filter { memory in
            let components = calendar.dateComponents([.month, .day], from: memory.date)
            return components.month == refComponents.month && components.day == refComponents.day
                && !calendar.isDate(memory.date, inSameDayAs: referenceDate)
        }.sorted { $0.date > $1.date }
    }

    static func nearbyMemories(
        from memories: [Memory],
        centerLat: Double,
        centerLon: Double,
        limit: Int = 10
    ) -> [(memory: Memory, distanceKm: Double)] {
        memories
            .map { memory in
                (memory, LocationHelper.distanceKm(
                    from: centerLat, lon1: centerLon,
                    to: memory.latitude, lon2: memory.longitude
                ))
            }
            .sorted { $0.1 < $1.1 }
            .prefix(limit)
            .map { ($0.0, $0.1) }
    }
}

enum LocationHelper {
    static func distanceKm(from lat1: Double, lon1: Double, to lat2: Double, lon2: Double) -> Double {
        let loc1 = CLLocation(latitude: lat1, longitude: lon1)
        let loc2 = CLLocation(latitude: lat2, longitude: lon2)
        return loc1.distance(from: loc2) / 1000
    }

    static func farthestMemory(from homeLat: Double, homeLon: Double, memories: [Memory]) -> (memory: Memory, distanceKm: Double)? {
        memories
            .map { ($0, distanceKm(from: homeLat, lon1: homeLon, to: $0.latitude, lon2: $0.longitude)) }
            .max(by: { $0.1 < $1.1 })
            .map { ($0.0, $0.1) }
    }
}
