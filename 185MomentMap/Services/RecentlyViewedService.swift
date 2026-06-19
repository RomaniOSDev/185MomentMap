import Foundation

protocol RecentlyViewedServiceProtocol {
    func recordView(memoryId: UUID)
    func fetchEntries() -> [RecentlyViewedEntry]
    func fetchMemories() -> [Memory]
}

final class RecentlyViewedService: RecentlyViewedServiceProtocol {
    static let shared = RecentlyViewedService()

    private let storage: StorageServiceProtocol
    private let memoryRepository: MemoryRepositoryProtocol
    private let storageKey = StorageKeys.recentlyViewed

    init(
        storage: StorageServiceProtocol = UserDefaultsStorageService(),
        memoryRepository: MemoryRepositoryProtocol = MemoryRepository.shared
    ) {
        self.storage = storage
        self.memoryRepository = memoryRepository
    }

    func recordView(memoryId: UUID) {
        var entries: [RecentlyViewedEntry] = storage.load(forKey: storageKey)
        entries.removeAll { $0.memoryId == memoryId }
        entries.insert(RecentlyViewedEntry(id: UUID(), memoryId: memoryId, viewedAt: Date()), at: 0)
        if entries.count > AppConstants.maxRecentlyViewed {
            entries = Array(entries.prefix(AppConstants.maxRecentlyViewed))
        }
        storage.save(entries, forKey: storageKey)
    }

    func fetchEntries() -> [RecentlyViewedEntry] {
        storage.load(forKey: storageKey)
    }

    func fetchMemories() -> [Memory] {
        fetchEntries().compactMap { memoryRepository.fetch(id: $0.memoryId) }
    }
}
