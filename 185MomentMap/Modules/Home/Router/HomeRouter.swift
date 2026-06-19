import Foundation

protocol HomeRouterInput: AnyObject {
    func navigateToMemoryCreate(editingId: UUID?)
    func navigateToStatistics()
    func navigateToSettings()
    func navigateToTrips()
    func navigateToMemoryDetail(memoryId: UUID)
    func focusMapOn(latitude: Double, longitude: Double)
    func switchToMapTab()
}

final class HomeRouter: HomeRouterInput {
    weak var presenter: HomePresenter?

    func navigateToMemoryCreate(editingId: UUID?) {
        presenter?.showMemoryCreate(editingId: editingId)
    }

    func navigateToStatistics() {
        presenter?.showStatistics()
    }

    func navigateToSettings() {
        presenter?.showSettings()
    }

    func navigateToTrips() {
        presenter?.showTrips()
    }

    func navigateToMemoryDetail(memoryId: UUID) {
        presenter?.showMemoryDetail(memoryId: memoryId)
    }

    func focusMapOn(latitude: Double, longitude: Double) {
        presenter?.focusMap(latitude: latitude, longitude: longitude)
    }

    func switchToMapTab() {
        presenter?.selectMapTab()
    }
}
