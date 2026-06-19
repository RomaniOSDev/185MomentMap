import Foundation
import MapKit

protocol MapInteractorInput: AnyObject {
    func loadMemories() -> [Memory]
    func getMemories(criteria: MemoryFilterCriteria) -> [Memory]
    func getRouteCoordinates(for tripId: UUID?) -> [CLLocationCoordinate2D]
    func getHeatmapData(from memories: [Memory]) -> [(coordinate: CLLocationCoordinate2D, intensity: Double)]
    func getNearbyMemories(from memories: [Memory], centerLat: Double, centerLon: Double) -> [(memory: Memory, distanceKm: Double)]
    func loadSavedRegion() -> SavedMapRegion?
    func saveMapRegion(_ region: SavedMapRegion)
    func loadTrips() -> [Trip]
}

final class MapInteractor: MapInteractorInput {
    private let repository: MemoryRepositoryProtocol
    private let tripRepository: TripRepositoryProtocol
    private let settingsRepository: SettingsRepositoryProtocol

    init(
        repository: MemoryRepositoryProtocol = MemoryRepository.shared,
        tripRepository: TripRepositoryProtocol = TripRepository.shared,
        settingsRepository: SettingsRepositoryProtocol = SettingsRepository.shared
    ) {
        self.repository = repository
        self.tripRepository = tripRepository
        self.settingsRepository = settingsRepository
    }

    func loadMemories() -> [Memory] {
        repository.fetchPublished()
    }

    func getMemories(criteria: MemoryFilterCriteria) -> [Memory] {
        MemoryFilterService.apply(criteria, to: loadMemories())
    }

    func getRouteCoordinates(for tripId: UUID?) -> [CLLocationCoordinate2D] {
        guard let tripId else { return [] }
        return repository.fetchForTrip(tripId).map {
            CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
        }
    }

    func getHeatmapData(from memories: [Memory]) -> [(coordinate: CLLocationCoordinate2D, intensity: Double)] {
        memories.map { memory in
            (
                CLLocationCoordinate2D(latitude: memory.latitude, longitude: memory.longitude),
                0.4
            )
        }
    }

    func getNearbyMemories(
        from memories: [Memory],
        centerLat: Double,
        centerLon: Double
    ) -> [(memory: Memory, distanceKm: Double)] {
        MemoryFilterService.nearbyMemories(
            from: memories,
            centerLat: centerLat,
            centerLon: centerLon
        )
    }

    func loadSavedRegion() -> SavedMapRegion? {
        settingsRepository.load().lastMapRegion
    }

    func saveMapRegion(_ region: SavedMapRegion) {
        settingsRepository.saveMapRegion(region)
    }

    func loadTrips() -> [Trip] {
        tripRepository.fetchAll()
    }
}
