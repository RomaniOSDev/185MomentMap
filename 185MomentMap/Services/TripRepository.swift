import Foundation

protocol TripRepositoryProtocol {
    func fetchAll() -> [Trip]
    func fetch(id: UUID) -> Trip?
    func save(_ trip: Trip)
    func update(_ trip: Trip)
    func delete(id: UUID)
}

final class TripRepository: TripRepositoryProtocol {
    static let shared = TripRepository()

    private let storage: StorageServiceProtocol
    private let storageKey = StorageKeys.trips

    init(storage: StorageServiceProtocol = UserDefaultsStorageService()) {
        self.storage = storage
    }

    func fetchAll() -> [Trip] {
        storage.load(forKey: storageKey).sorted { $0.createdAt > $1.createdAt }
    }

    func fetch(id: UUID) -> Trip? {
        fetchAll().first { $0.id == id }
    }

    func save(_ trip: Trip) {
        storage.append(trip, forKey: storageKey)
        NotificationCenter.default.post(name: .tripsDidChange, object: nil)
    }

    func update(_ trip: Trip) {
        storage.update(trip, forKey: storageKey)
        NotificationCenter.default.post(name: .tripsDidChange, object: nil)
    }

    func delete(id: UUID) {
        var items: [Trip] = storage.load(forKey: storageKey)
        items.removeAll { $0.id == id }
        storage.save(items, forKey: storageKey)
        NotificationCenter.default.post(name: .tripsDidChange, object: nil)
    }
}

extension Notification.Name {
    static let tripsDidChange = Notification.Name("tripsDidChange")
    static let settingsDidChange = Notification.Name("settingsDidChange")
}
