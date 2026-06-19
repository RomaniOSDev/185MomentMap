import Foundation

protocol MemoryCreateInteractorInput: AnyObject {
    func geocodeAddress(_ address: String) async -> (lat: Double, lon: Double)?
    func saveMemory(_ memory: Memory)
    func updateMemory(_ memory: Memory)
    func validateForm(_ form: MemoryFormData, hasCoordinates: Bool, isDraft: Bool) -> ValidationResult
    func fetchMemory(id: UUID) -> Memory?
    func loadTrips() -> [Trip]
}

final class MemoryCreateInteractor: MemoryCreateInteractorInput {
    private let repository: MemoryRepositoryProtocol
    private let tripRepository: TripRepositoryProtocol
    private let mapService: MapService

    init(
        repository: MemoryRepositoryProtocol = MemoryRepository.shared,
        tripRepository: TripRepositoryProtocol = TripRepository.shared,
        mapService: MapService = MapService()
    ) {
        self.repository = repository
        self.tripRepository = tripRepository
        self.mapService = mapService
    }

    func geocodeAddress(_ address: String) async -> (lat: Double, lon: Double)? {
        guard let result = await mapService.geocodeAddress(address) else { return nil }
        return (result.latitude, result.longitude)
    }

    func saveMemory(_ memory: Memory) {
        repository.save(memory)
    }

    func updateMemory(_ memory: Memory) {
        repository.update(memory)
    }

    func validateForm(_ form: MemoryFormData, hasCoordinates: Bool, isDraft: Bool) -> ValidationResult {
        let trimmedTitle = form.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedTitle.isEmpty {
            return .invalid(message: "Title is required.")
        }
        if !isDraft {
            if form.mood == nil {
                return .invalid(message: "Please select a mood.")
            }
            let hasAddress = !form.address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            if !hasAddress && !hasCoordinates {
                return .invalid(message: "Please enter an address or coordinates.")
            }
        }
        return .valid
    }

    func fetchMemory(id: UUID) -> Memory? {
        repository.fetch(id: id)
    }

    func loadTrips() -> [Trip] {
        tripRepository.fetchAll()
    }
}
