import Foundation

protocol MemoryDetailRouterInput: AnyObject {
    func navigateToEdit(memoryId: UUID)
    func dismiss()
}

final class MemoryDetailRouter: MemoryDetailRouterInput {
    var onNavigateToEdit: ((UUID) -> Void)?
    var onDismiss: (() -> Void)?

    func navigateToEdit(memoryId: UUID) {
        onNavigateToEdit?(memoryId)
    }

    func dismiss() {
        onDismiss?()
    }
}
