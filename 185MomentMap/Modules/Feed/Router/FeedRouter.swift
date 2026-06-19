import Foundation

protocol FeedRouterInput: AnyObject {
    func navigateToMemoryDetail(memory: Memory)
}

final class FeedRouter: FeedRouterInput {
    var onNavigateToDetail: ((Memory) -> Void)?

    func navigateToMemoryDetail(memory: Memory) {
        onNavigateToDetail?(memory)
    }
}
