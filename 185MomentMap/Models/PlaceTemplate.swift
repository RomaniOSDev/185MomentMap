import Foundation

enum PlaceTemplate: String, CaseIterable, Codable, Identifiable {
    case cafe
    case hotel
    case viewpoint
    case restaurant
    case museum
    case beach

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .cafe: return "Café"
        case .hotel: return "Hotel"
        case .viewpoint: return "Viewpoint"
        case .restaurant: return "Restaurant"
        case .museum: return "Museum"
        case .beach: return "Beach"
        }
    }

    var icon: String {
        switch self {
        case .cafe: return "cup.and.saucer.fill"
        case .hotel: return "bed.double.fill"
        case .viewpoint: return "binoculars.fill"
        case .restaurant: return "fork.knife"
        case .museum: return "building.columns.fill"
        case .beach: return "beach.umbrella.fill"
        }
    }

    var defaultTitle: String {
        switch self {
        case .cafe: return "Cozy Café"
        case .hotel: return "Hotel Stay"
        case .viewpoint: return "Scenic Viewpoint"
        case .restaurant: return "Great Meal"
        case .museum: return "Museum Visit"
        case .beach: return "Beach Day"
        }
    }

    var suggestedTags: [MemoryTag] {
        switch self {
        case .cafe: return [.cafe]
        case .hotel: return [.hotel]
        case .viewpoint: return [.viewpoint]
        case .restaurant: return [.restaurant]
        case .museum: return [.museum]
        case .beach: return [.beach]
        }
    }

    var suggestedMood: Mood {
        switch self {
        case .cafe: return .cozy
        case .hotel: return .relaxed
        case .viewpoint: return .wow
        case .restaurant: return .foodie
        case .museum: return .cultural
        case .beach: return .peaceful
        }
    }
}
