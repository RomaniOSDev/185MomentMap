import Foundation

enum FeedSortOption: String, CaseIterable, Identifiable {
    case dateNewest
    case dateOldest
    case title

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dateNewest: return "Newest First"
        case .dateOldest: return "Oldest First"
        case .title: return "By Title"
        }
    }
}

struct FeedSection: Identifiable {
    let id: String
    let title: String
    let memories: [Memory]
}
