import Foundation

protocol FeedInteractorInput: AnyObject {
    func loadMemories() -> [Memory]
    func loadDrafts() -> [Memory]
    func applyFilters(criteria: MemoryFilterCriteria, sort: FeedSortOption) -> [Memory]
    func loadOnThisDayMemories() -> [Memory]
    func loadRecentlyViewed() -> [Memory]
    func deleteMemory(id: UUID)
    func toggleFavorite(memory: Memory) -> Memory
    func togglePinned(memory: Memory) -> Memory
    func loadTrips() -> [Trip]
}

final class FeedInteractor: FeedInteractorInput {
    private let repository: MemoryRepositoryProtocol
    private let recentlyViewed: RecentlyViewedServiceProtocol
    private let tripRepository: TripRepositoryProtocol

    init(
        repository: MemoryRepositoryProtocol = MemoryRepository.shared,
        recentlyViewed: RecentlyViewedServiceProtocol = RecentlyViewedService.shared,
        tripRepository: TripRepositoryProtocol = TripRepository.shared
    ) {
        self.repository = repository
        self.recentlyViewed = recentlyViewed
        self.tripRepository = tripRepository
    }

    func loadMemories() -> [Memory] {
        repository.fetchPublished()
    }

    func loadDrafts() -> [Memory] {
        repository.fetchDrafts()
    }

    func applyFilters(criteria: MemoryFilterCriteria, sort: FeedSortOption) -> [Memory] {
        let filtered = MemoryFilterService.apply(criteria, to: loadMemories())
        return MemoryFilterService.sortWithPinnedFirst(filtered, by: sort)
    }

    func loadOnThisDayMemories() -> [Memory] {
        MemoryFilterService.onThisDayMemories(from: loadMemories())
    }

    func loadRecentlyViewed() -> [Memory] {
        recentlyViewed.fetchMemories()
    }

    func deleteMemory(id: UUID) {
        repository.delete(id: id)
    }

    func toggleFavorite(memory: Memory) -> Memory {
        var updated = memory
        updated.isFavorite.toggle()
        repository.update(updated)
        return updated
    }

    func togglePinned(memory: Memory) -> Memory {
        var updated = memory
        updated.isPinned.toggle()
        repository.update(updated)
        return updated
    }

    func loadTrips() -> [Trip] {
        tripRepository.fetchAll()
    }
}
