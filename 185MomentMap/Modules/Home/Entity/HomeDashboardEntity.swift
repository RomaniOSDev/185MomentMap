import Foundation

struct HomeDashboardData {
    let totalMemories: Int
    let favoritesCount: Int
    let tripsCount: Int
    let activeDays: Int
    let topMood: Mood?
    let onThisDay: [Memory]
    let recentMemories: [Memory]
    let latestMemories: [Memory]
    let trips: [Trip]
}

struct HomeQuickAction: Identifiable {
    let id: String
    let title: String
    let icon: String
    let color: String
}

enum HomeQuickActionType: String, CaseIterable, Identifiable {
    case addMemory
    case openMap
    case openFeed
    case statistics
    case trips

    var id: String { rawValue }

    var title: String {
        switch self {
        case .addMemory: return "Add"
        case .openMap: return "Map"
        case .openFeed: return "Feed"
        case .statistics: return "Stats"
        case .trips: return "Trips"
        }
    }

    var icon: String {
        switch self {
        case .addMemory: return "plus.circle.fill"
        case .openMap: return "map.fill"
        case .openFeed: return "rectangle.stack.fill"
        case .statistics: return "chart.bar.fill"
        case .trips: return "suitcase.fill"
        }
    }
}
