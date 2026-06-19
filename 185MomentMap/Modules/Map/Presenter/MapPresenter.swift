import Foundation
import MapKit
import Combine

protocol MapPresenterInput: AnyObject {
    func viewDidLoad()
    func didSelectMoodFilter(_ mood: Mood?)
    func didSelectTripFilter(_ tripId: UUID?)
    func didSelectTagFilter(_ tag: MemoryTag?)
    func didSelectAnnotation(memory: Memory)
    func didTapShowAll()
    func didChangeMapType(_ type: MapDisplayType)
    func didChangeVisualizationMode(_ mode: MapVisualizationMode)
    func focusOn(latitude: Double, longitude: Double)
    func updateNearMe(latitude: String, longitude: String, radiusKm: Double, enabled: Bool)
    func toggleNearbySheet()
    func saveCurrentRegion(_ region: SavedMapRegion)
}

@MainActor
final class MapPresenter: ObservableObject, MapPresenterInput {
    @Published var memories: [Memory] = []
    @Published var selectedMoodFilter: Mood?
    @Published var selectedTripId: UUID?
    @Published var selectedTag: MemoryTag?
    @Published var mapType: MapDisplayType = .standard
    @Published var visualizationMode: MapVisualizationMode = .pins
    @Published var focusCoordinate: CLLocationCoordinate2D?
    @Published var focusRequestID = UUID()
    @Published var overlayData = MapOverlayData()
    @Published var savedRegion: SavedMapRegion?
    @Published var trips: [Trip] = []
    @Published var nearMeEnabled = false
    @Published var nearMeLatitude = ""
    @Published var nearMeLongitude = ""
    @Published var nearMeRadiusKm: Double = AppConstants.defaultNearMeRadiusKm
    @Published var showNearbySheet = false
    @Published var nearbyItems: [(memory: Memory, distanceKm: Double)] = []
    @Published var showNearMePanel = false

    var onMemorySelected: ((Memory) -> Void)?

    private let interactor: MapInteractorInput
    private let router: MapRouterInput
    private var cancellables = Set<AnyCancellable>()

    init(interactor: MapInteractorInput, router: MapRouterInput) {
        self.interactor = interactor
        self.router = router

        NotificationCenter.default.publisher(for: .memoriesDidChange)
            .merge(with: NotificationCenter.default.publisher(for: .tripsDidChange))
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateUI() }
            .store(in: &cancellables)
    }

    func viewDidLoad() {
        savedRegion = interactor.loadSavedRegion()
        trips = interactor.loadTrips()
        let settings = SettingsRepository.shared.load()
        nearMeRadiusKm = settings.defaultNearMeRadiusKm
        if let lat = settings.homeLatitude { nearMeLatitude = String(lat) }
        if let lon = settings.homeLongitude { nearMeLongitude = String(lon) }
        updateUI()
    }

    func didSelectMoodFilter(_ mood: Mood?) {
        selectedMoodFilter = mood
        updateUI()
    }

    func didSelectTripFilter(_ tripId: UUID?) {
        selectedTripId = tripId
        if tripId != nil { visualizationMode = .route }
        updateUI()
    }

    func didSelectTagFilter(_ tag: MemoryTag?) {
        selectedTag = tag
        updateUI()
    }

    func didSelectAnnotation(memory: Memory) {
        router.navigateToMemoryDetail(memory: memory)
    }

    func didTapShowAll() {
        selectedMoodFilter = nil
        selectedTripId = nil
        selectedTag = nil
        nearMeEnabled = false
        visualizationMode = .pins
        updateUI()
    }

    func didChangeMapType(_ type: MapDisplayType) {
        mapType = type
    }

    func didChangeVisualizationMode(_ mode: MapVisualizationMode) {
        visualizationMode = mode
        updateUI()
    }

    func focusOn(latitude: Double, longitude: Double) {
        focusCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        focusRequestID = UUID()
    }

    func updateNearMe(latitude: String, longitude: String, radiusKm: Double, enabled: Bool) {
        nearMeLatitude = latitude
        nearMeLongitude = longitude
        nearMeRadiusKm = radiusKm
        nearMeEnabled = enabled
        updateUI()
    }

    func toggleNearbySheet() {
        updateNearbyItems()
        showNearbySheet.toggle()
    }

    func saveCurrentRegion(_ region: SavedMapRegion) {
        interactor.saveMapRegion(region)
        savedRegion = region
    }

    private func updateNearbyItems() {
        let centerLat = Double(nearMeLatitude) ?? focusCoordinate?.latitude ?? savedRegion?.centerLatitude ?? 0
        let centerLon = Double(nearMeLongitude) ?? focusCoordinate?.longitude ?? savedRegion?.centerLongitude ?? 0
        guard centerLat != 0 || centerLon != 0 else {
            nearbyItems = []
            return
        }
        nearbyItems = interactor.getNearbyMemories(
            from: memories,
            centerLat: centerLat,
            centerLon: centerLon
        )
    }

    func updateUI() {
        trips = interactor.loadTrips()
        var criteria = MemoryFilterCriteria()
        criteria.mood = selectedMoodFilter
        criteria.tripId = selectedTripId
        if let selectedTag { criteria.tags = [selectedTag] }
        criteria.nearMeEnabled = nearMeEnabled
        criteria.nearMeLatitude = Double(nearMeLatitude)
        criteria.nearMeLongitude = Double(nearMeLongitude)
        criteria.nearMeRadiusKm = nearMeRadiusKm

        memories = interactor.getMemories(criteria: criteria)

        let routeCoords = interactor.getRouteCoordinates(for: selectedTripId)
        let heatmap = interactor.getHeatmapData(from: memories)
        overlayData = MapOverlayData(routeCoordinates: routeCoords, heatmapCenters: heatmap)
        updateNearbyItems()
    }
}
