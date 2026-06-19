import Foundation

protocol MemoryDetailInteractorInput: AnyObject {
    func getMemory(id: UUID) -> Memory?
    func deleteMemory(id: UUID)
    func shareMemory(memory: Memory) -> String
    func duplicateMemory(_ memory: Memory) -> Memory
    func togglePin(_ memory: Memory) -> Memory
    func recordRecentlyViewed(memoryId: UUID)
    func tripName(for tripId: UUID?) -> String?
}

final class MemoryDetailInteractor: MemoryDetailInteractorInput {
    private let repository: MemoryRepositoryProtocol
    private let tripRepository: TripRepositoryProtocol
    private let recentlyViewed: RecentlyViewedServiceProtocol

    init(
        repository: MemoryRepositoryProtocol = MemoryRepository.shared,
        tripRepository: TripRepositoryProtocol = TripRepository.shared,
        recentlyViewed: RecentlyViewedServiceProtocol = RecentlyViewedService.shared
    ) {
        self.repository = repository
        self.tripRepository = tripRepository
        self.recentlyViewed = recentlyViewed
    }

    func getMemory(id: UUID) -> Memory? { repository.fetch(id: id) }
    func deleteMemory(id: UUID) { repository.delete(id: id) }
    func shareMemory(memory: Memory) -> String { memory.shareText }

    func duplicateMemory(_ memory: Memory) -> Memory {
        repository.duplicate(memory)
    }

    func togglePin(_ memory: Memory) -> Memory {
        var updated = memory
        updated.isPinned.toggle()
        repository.update(updated)
        return updated
    }

    func recordRecentlyViewed(memoryId: UUID) {
        recentlyViewed.recordView(memoryId: memoryId)
    }

    func tripName(for tripId: UUID?) -> String? {
        guard let tripId else { return nil }
        return tripRepository.fetch(id: tripId)?.name
    }
}
