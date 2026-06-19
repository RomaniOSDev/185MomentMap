import SwiftUI

enum Mood: String, CaseIterable, Codable, Identifiable {
    case happy = "😊"
    case excited = "🤩"
    case relaxed = "😌"
    case romantic = "😍"
    case adventurous = "🧗"
    case nostalgic = "🥹"
    case peaceful = "🧘"
    case fun = "🎉"
    case cozy = "🛋️"
    case wow = "🤯"
    case foodie = "🍜"
    case cultural = "🏛️"
    case nature = "🌿"
    case night = "🌙"
    case chill = "😎"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .happy: return "Happy"
        case .excited: return "Excited"
        case .relaxed: return "Relaxed"
        case .romantic: return "Romantic"
        case .adventurous: return "Adventurous"
        case .nostalgic: return "Nostalgic"
        case .peaceful: return "Peaceful"
        case .fun: return "Fun"
        case .cozy: return "Cozy"
        case .wow: return "Wow"
        case .foodie: return "Foodie"
        case .cultural: return "Cultural"
        case .nature: return "Nature"
        case .night: return "Night"
        case .chill: return "Chill"
        }
    }

    var colorHex: String {
        switch self {
        case .happy: return "#FFD93D"
        case .excited: return "#FF6B6B"
        case .relaxed: return "#6BCB77"
        case .romantic: return "#FF85A1"
        case .adventurous: return "#FF9F43"
        case .nostalgic: return "#A29BFE"
        case .peaceful: return "#74B9FF"
        case .fun: return "#FD79A8"
        case .cozy: return "#DFE6E9"
        case .wow: return "#FDCB6E"
        case .foodie: return "#E17055"
        case .cultural: return "#6C5CE7"
        case .nature: return "#00B894"
        case .night: return "#2D3436"
        case .chill: return "#81ECEC"
        }
    }

    var swiftUIColor: Color {
        Color(hex: colorHex)
    }
}
