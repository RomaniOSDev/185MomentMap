import Foundation

protocol MemoryCreateRouterInput: AnyObject {
    func dismissToMap(latitude: Double, longitude: Double)
    func dismiss()
    func showError(message: String)
}

final class MemoryCreateRouter: MemoryCreateRouterInput {
    var onDismissToMap: ((Double, Double) -> Void)?
    var onDismiss: (() -> Void)?
    var onShowError: ((String) -> Void)?

    func dismissToMap(latitude: Double, longitude: Double) {
        onDismissToMap?(latitude, longitude)
    }

    func dismiss() {
        onDismiss?()
    }

    func showError(message: String) {
        onShowError?(message)
    }
}
