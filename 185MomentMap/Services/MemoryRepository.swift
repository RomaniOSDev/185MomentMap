import Foundation

protocol MemoryRepositoryProtocol {
    func fetchAll() -> [Memory]
    func fetchPublished() -> [Memory]
    func fetchDrafts() -> [Memory]
    func fetch(id: UUID) -> Memory?
    func fetchForTrip(_ tripId: UUID) -> [Memory]
    func save(_ memory: Memory)
    func update(_ memory: Memory)
    func delete(id: UUID)
    func deleteAll()
    func duplicate(_ memory: Memory) -> Memory
}

final class MemoryRepository: MemoryRepositoryProtocol {
    static let shared = MemoryRepository()

    private let storage: StorageServiceProtocol
    private let storageKey = StorageKeys.memories

    init(storage: StorageServiceProtocol = UserDefaultsStorageService()) {
        self.storage = storage
    }

    func fetchAll() -> [Memory] {
        storage.load(forKey: storageKey)
    }

    func fetchPublished() -> [Memory] {
        fetchAll().filter { !$0.isDraft }
    }

    func fetchDrafts() -> [Memory] {
        fetchAll().filter(\.isDraft)
    }

    func fetch(id: UUID) -> Memory? {
        fetchAll().first { $0.id == id }
    }

    func fetchForTrip(_ tripId: UUID) -> [Memory] {
        fetchPublished().filter { $0.tripId == tripId }.sorted { $0.date < $1.date }
    }

    func save(_ memory: Memory) {
        storage.append(memory, forKey: storageKey)
        NotificationCenter.default.post(name: .memoriesDidChange, object: nil)
    }

    func update(_ memory: Memory) {
        storage.update(memory, forKey: storageKey)
        NotificationCenter.default.post(name: .memoriesDidChange, object: nil)
    }

    func delete(id: UUID) {
        var items = fetchAll()
        items.removeAll { $0.id == id }
        storage.save(items, forKey: storageKey)
        NotificationCenter.default.post(name: .memoriesDidChange, object: nil)
    }

    func deleteAll() {
        storage.delete(forKey: storageKey)
        NotificationCenter.default.post(name: .memoriesDidChange, object: nil)
    }

    func duplicate(_ memory: Memory) -> Memory {
        let copy = Memory(
            title: "\(memory.title) (Copy)",
            address: memory.address,
            latitude: memory.latitude,
            longitude: memory.longitude,
            mood: memory.mood,
            note: memory.note,
            imagesData: memory.allImagesData,
            audioData: memory.audioData,
            tags: memory.tags,
            tripId: memory.tripId,
            date: memory.date,
            isFavorite: false,
            isPinned: false,
            isDraft: false
        )
        save(copy)
        return copy
    }
}

extension Notification.Name {
    static let memoriesDidChange = Notification.Name("memoriesDidChange")
}
