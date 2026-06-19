import Foundation

protocol TripsInteractorInput: AnyObject {
    func loadTrips() -> [Trip]
    func saveTrip(_ trip: Trip)
    func deleteTrip(id: UUID)
    func memoryCount(for tripId: UUID) -> Int
}

final class TripsInteractor: TripsInteractorInput {
    private let tripRepository: TripRepositoryProtocol
    private let memoryRepository: MemoryRepositoryProtocol

    init(
        tripRepository: TripRepositoryProtocol = TripRepository.shared,
        memoryRepository: MemoryRepositoryProtocol = MemoryRepository.shared
    ) {
        self.tripRepository = tripRepository
        self.memoryRepository = memoryRepository
    }

    func loadTrips() -> [Trip] { tripRepository.fetchAll() }

    func saveTrip(_ trip: Trip) { tripRepository.save(trip) }

    func deleteTrip(id: UUID) { tripRepository.delete(id: id) }

    func memoryCount(for tripId: UUID) -> Int {
        memoryRepository.fetchForTrip(tripId).count
    }
}
