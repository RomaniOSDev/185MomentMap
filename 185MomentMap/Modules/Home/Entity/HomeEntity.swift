import SwiftUI

enum HomeTab: Int, CaseIterable {
    case home = 0
    case map = 1
    case feed = 2

    var title: String {
        switch self {
        case .home: return "Home"
        case .map: return "Map"
        case .feed: return "Feed"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .map: return "map.fill"
        case .feed: return "rectangle.stack.fill"
        }
    }
}

enum HomeDestination: Hashable {
    case memoryDetail(UUID)
    case memoryCreate(editingId: UUID?)
    case statistics
    case settings
    case trips
}

struct MapFocusRequest: Equatable {
    let latitude: Double
    let longitude: Double
}
