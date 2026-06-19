import Foundation

struct ActivityDay: Identifiable, Hashable {
    let id: String
    let date: Date
    let count: Int
}

struct MonthlyMoodSummary: Identifiable {
    let id: String
    let month: String
    let dominantMood: Mood
    let count: Int
}

struct StatisticsDisplayData {
    let statistics: Statistics
    let moodChartItems: [MoodChartItem]
    let topCities: [(city: String, count: Int)]
    let activityDays: [ActivityDay]
    let monthlyMoodSummaries: [MonthlyMoodSummary]
}
