import SwiftUI

enum MemoryTag: String, CaseIterable, Codable, Identifiable, Hashable {
    case beach
    case museum
    case restaurant
    case hike
    case cafe
    case hotel
    case viewpoint
    case park
    case shopping
    case nightlife

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .beach: return "Beach"
        case .museum: return "Museum"
        case .restaurant: return "Restaurant"
        case .hike: return "Hike"
        case .cafe: return "Café"
        case .hotel: return "Hotel"
        case .viewpoint: return "Viewpoint"
        case .park: return "Park"
        case .shopping: return "Shopping"
        case .nightlife: return "Nightlife"
        }
    }

    var icon: String {
        switch self {
        case .beach: return "beach.umbrella"
        case .museum: return "building.columns"
        case .restaurant: return "fork.knife"
        case .hike: return "figure.hiking"
        case .cafe: return "cup.and.saucer"
        case .hotel: return "bed.double"
        case .viewpoint: return "binoculars"
        case .park: return "leaf"
        case .shopping: return "bag"
        case .nightlife: return "moon.stars"
        }
    }
}
