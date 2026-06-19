import Foundation

protocol StatisticsInteractorInput: AnyObject {
    func calculateStats() -> StatisticsDisplayData
    func exportData() -> String
    func resetStats()
}

final class StatisticsInteractor: StatisticsInteractorInput {
    private let repository: MemoryRepositoryProtocol
    private let settingsRepository: SettingsRepositoryProtocol
    private let encoder = JSONEncoder()

    init(
        repository: MemoryRepositoryProtocol = MemoryRepository.shared,
        settingsRepository: SettingsRepositoryProtocol = SettingsRepository.shared
    ) {
        self.repository = repository
        self.settingsRepository = settingsRepository
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
    }

    func calculateStats() -> StatisticsDisplayData {
        let memories = repository.fetchPublished()
        let calendar = Calendar.current
        let settings = settingsRepository.load()

        var moodCounts: [Mood: Int] = [:]
        var cityCounts: [String: Int] = [:]
        var dayCounts: [Date: Int] = [:]
        var monthCounts: [Date: Int] = [:]
        var monthMoodCounts: [String: [Mood: Int]] = [:]

        for memory in memories {
            moodCounts[memory.mood, default: 0] += 1

            if let city = memory.cityName {
                cityCounts[city, default: 0] += 1
            }

            let day = memory.date.startOfDay(calendar: calendar)
            dayCounts[day, default: 0] += 1

            let monthKey = memory.date.formatted(pattern: "yyyy-MM")
            monthMoodCounts[monthKey, default: [:]][memory.mood, default: 0] += 1

            let monthComponents = calendar.dateComponents([.year, .month], from: memory.date)
            if let monthStart = calendar.date(from: monthComponents) {
                monthCounts[monthStart, default: 0] += 1
            }
        }

        let favoriteMood = moodCounts.max(by: { $0.value < $1.value })?.key
        let bestMonthDate = monthCounts.max(by: { $0.value < $1.value })?.key
        let bestMonth = bestMonthDate.map { $0.formatted(pattern: "MMMM yyyy") }

        var farthestTitle: String?
        var farthestDistance: Double?
        if let homeLat = settings.homeLatitude, let homeLon = settings.homeLongitude,
           let farthest = LocationHelper.farthestMemory(from: homeLat, homeLon: homeLon, memories: memories) {
            farthestTitle = farthest.memory.title
            farthestDistance = farthest.distanceKm
        }

        let averageMoodByMonth: [String: String] = monthMoodCounts.mapValues { moods in
            moods.max(by: { $0.value < $1.value })?.key.displayName ?? "—"
        }

        let statistics = Statistics(
            totalMemories: memories.count,
            favoriteMood: favoriteMood,
            topCities: cityCounts,
            weeklyActivity: dayCounts,
            monthlyActivity: monthCounts,
            uniqueDays: dayCounts.keys.count,
            favoriteCount: memories.filter(\.isFavorite).count,
            bestMonth: bestMonth,
            farthestMemoryTitle: farthestTitle,
            farthestDistanceKm: farthestDistance,
            averageMoodByMonth: averageMoodByMonth
        )

        let moodChartItems = Mood.allCases.compactMap { mood -> MoodChartItem? in
            let count = moodCounts[mood, default: 0]
            guard count > 0 else { return nil }
            return MoodChartItem(id: mood.displayName, mood: mood, count: count)
        }.sorted { $0.count > $1.count }

        let topCities = cityCounts.sorted { $0.value > $1.value }.prefix(5).map { ($0.key, $0.value) }

        let activityDays = dayCounts.map {
            ActivityDay(id: ISO8601DateFormatter().string(from: $0.key), date: $0.key, count: $0.value)
        }.sorted { $0.date < $1.date }

        let monthlyMoodSummaries = monthMoodCounts.compactMap { key, moods -> MonthlyMoodSummary? in
            guard let dominant = moods.max(by: { $0.value < $1.value }) else { return nil }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM"
            formatter.locale = Locale(identifier: "en_US")
            let displayMonth = formatter.date(from: key).map {
                $0.formatted(pattern: "MMMM yyyy")
            } ?? key
            return MonthlyMoodSummary(
                id: key,
                month: displayMonth,
                dominantMood: dominant.key,
                count: moods.values.reduce(0, +)
            )
        }.sorted { $0.id > $1.id }

        return StatisticsDisplayData(
            statistics: statistics,
            moodChartItems: moodChartItems,
            topCities: Array(topCities),
            activityDays: activityDays,
            monthlyMoodSummaries: monthlyMoodSummaries
        )
    }

    func exportData() -> String {
        let memories = repository.fetchPublished()
        guard let data = try? encoder.encode(memories),
              let json = String(data: data, encoding: .utf8) else { return "[]" }
        return json
    }

    func resetStats() {
        repository.deleteAll()
    }
}
