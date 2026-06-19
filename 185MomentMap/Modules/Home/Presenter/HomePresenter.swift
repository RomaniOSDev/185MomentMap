import Foundation
import Combine

protocol HomePresenterInput: AnyObject {
    func viewDidLoad()
    func refreshDashboard()
    func didTapCreate()
    func didTapStatistics()
    func didTapSettings()
    func didTapTrips()
    func didSelectMemory(_ memory: Memory)
    func didSaveMemory(latitude: Double, longitude: Double)
    func didTapQuickAction(_ action: HomeQuickActionType)
    func didSelectTab(_ tab: HomeTab)
}

@MainActor
final class HomePresenter: ObservableObject, HomePresenterInput {
    @Published var selectedTab: HomeTab = .home
    @Published var navigationPath: [HomeDestination] = []
    @Published var mapFocusRequest: MapFocusRequest?
    @Published var dashboard: HomeDashboardData?

    private let interactor: HomeInteractorInput
    let router: HomeRouterInput
    private var cancellables = Set<AnyCancellable>()

    init(interactor: HomeInteractorInput, router: HomeRouterInput) {
        self.interactor = interactor
        self.router = router

        NotificationCenter.default.publisher(for: .memoriesDidChange)
            .merge(with: NotificationCenter.default.publisher(for: .tripsDidChange))
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.refreshDashboard() }
            .store(in: &cancellables)
    }

    func viewDidLoad() {
        selectedTab = interactor.loadSelectedTab()
        refreshDashboard()
    }

    func refreshDashboard() {
        dashboard = interactor.loadDashboard()
    }

    func didTapCreate() { router.navigateToMemoryCreate(editingId: nil) }
    func didTapStatistics() { router.navigateToStatistics() }
    func didTapSettings() { router.navigateToSettings() }
    func didTapTrips() { router.navigateToTrips() }

    func didSelectMemory(_ memory: Memory) {
        router.navigateToMemoryDetail(memoryId: memory.id)
    }

    func didSaveMemory(latitude: Double, longitude: Double) {
        router.switchToMapTab()
        router.focusMapOn(latitude: latitude, longitude: longitude)
    }

    func didTapQuickAction(_ action: HomeQuickActionType) {
        switch action {
        case .addMemory: didTapCreate()
        case .openMap: selectedTab = .map
        case .openFeed: selectedTab = .feed
        case .statistics: didTapStatistics()
        case .trips: didTapTrips()
        }
    }

    func didSelectTab(_ tab: HomeTab) {
        selectedTab = tab
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }

    func showMemoryCreate(editingId: UUID?) { navigationPath.append(.memoryCreate(editingId: editingId)) }
    func showStatistics() { navigationPath.append(.statistics) }
    func showSettings() { navigationPath.append(.settings) }
    func showTrips() { navigationPath.append(.trips) }
    func showMemoryDetail(memoryId: UUID) { navigationPath.append(.memoryDetail(memoryId)) }
    func focusMap(latitude: Double, longitude: Double) {
        mapFocusRequest = MapFocusRequest(latitude: latitude, longitude: longitude)
    }
    func selectMapTab() { selectedTab = .map }
}
