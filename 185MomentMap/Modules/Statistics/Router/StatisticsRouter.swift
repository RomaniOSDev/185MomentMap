import Foundation

protocol StatisticsRouterInput: AnyObject {
    func dismiss()
}

final class StatisticsRouter: StatisticsRouterInput {
    var onDismiss: (() -> Void)?

    func dismiss() {
        onDismiss?()
    }
}
