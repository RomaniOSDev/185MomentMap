import Foundation

protocol HomeInteractorInput: AnyObject {
    func loadSelectedTab() -> HomeTab
    func loadDashboard() -> HomeDashboardData
}

final class HomeInteractor: HomeInteractorInput {
    private let memoryRepository: MemoryRepositoryProtocol
    private let tripRepository: TripRepositoryProtocol
    private let recentlyViewed: RecentlyViewedServiceProtocol

    init(
        memoryRepository: MemoryRepositoryProtocol = MemoryRepository.shared,
        tripRepository: TripRepositoryProtocol = TripRepository.shared,
        recentlyViewed: RecentlyViewedServiceProtocol = RecentlyViewedService.shared
    ) {
        self.memoryRepository = memoryRepository
        self.tripRepository = tripRepository
        self.recentlyViewed = recentlyViewed
    }

    func loadSelectedTab() -> HomeTab {
        .home
    }

    func loadDashboard() -> HomeDashboardData {
        let memories = memoryRepository.fetchPublished()
        let calendar = Calendar.current
        var daySet = Set<Date>()
        var moodCounts: [Mood: Int] = [:]

        for memory in memories {
            daySet.insert(memory.date.startOfDay(calendar: calendar))
            moodCounts[memory.mood, default: 0] += 1
        }

        let recent = recentlyViewed.fetchMemories()
        let latest = memories.sorted { $0.date > $1.date }.prefix(6).map { $0 }
        let onThisDay = MemoryFilterService.onThisDayMemories(from: memories)

        return HomeDashboardData(
            totalMemories: memories.count,
            favoritesCount: memories.filter(\.isFavorite).count,
            tripsCount: tripRepository.fetchAll().count,
            activeDays: daySet.count,
            topMood: moodCounts.max(by: { $0.value < $1.value })?.key,
            onThisDay: onThisDay,
            recentMemories: Array(recent.prefix(8)),
            latestMemories: latest,
            trips: Array(tripRepository.fetchAll().prefix(3))
        )
    }
}
