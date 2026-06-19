import Foundation

struct Statistics: Codable {
    var totalMemories: Int
    var favoriteMood: Mood?
    var topCities: [String: Int]
    var weeklyActivity: [Date: Int]
    var monthlyActivity: [Date: Int]
    var uniqueDays: Int
    var favoriteCount: Int
    var bestMonth: String?
    var farthestMemoryTitle: String?
    var farthestDistanceKm: Double?
    var averageMoodByMonth: [String: String]
}
