import Foundation

protocol MapRouterInput: AnyObject {
    func navigateToMemoryDetail(memory: Memory)
}

final class MapRouter: MapRouterInput {
    var onNavigateToDetail: ((Memory) -> Void)?

    func navigateToMemoryDetail(memory: Memory) {
        onNavigateToDetail?(memory)
    }
}
