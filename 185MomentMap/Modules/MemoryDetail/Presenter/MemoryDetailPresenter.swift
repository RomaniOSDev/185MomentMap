import Foundation
import Combine
import UIKit

protocol MemoryDetailPresenterInput: AnyObject {
    func viewDidLoad()
    func didTapEdit()
    func didTapDelete()
    func didTapDuplicate()
    func didTapPin()
    func didTapOpenInMaps()
    func confirmDelete()
}

@MainActor
final class MemoryDetailPresenter: ObservableObject, MemoryDetailPresenterInput {
    @Published var memory: Memory?
    @Published var tripName: String?
    @Published var showDeleteConfirmation = false
    @Published var copiedCoordinates = false
    @Published var duplicatedMessage = false

    private let memoryId: UUID
    private let interactor: MemoryDetailInteractorInput
    private let router: MemoryDetailRouterInput
    private let mapService: MapService
    private var cancellables = Set<AnyCancellable>()

    init(
        memoryId: UUID,
        interactor: MemoryDetailInteractorInput,
        router: MemoryDetailRouterInput,
        mapService: MapService = MapService()
    ) {
        self.memoryId = memoryId
        self.interactor = interactor
        self.router = router
        self.mapService = mapService

        NotificationCenter.default.publisher(for: .memoriesDidChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.loadMemory() }
            .store(in: &cancellables)
    }

    func viewDidLoad() {
        interactor.recordRecentlyViewed(memoryId: memoryId)
        loadMemory()
    }

    func didTapEdit() { router.navigateToEdit(memoryId: memoryId) }
    func didTapDelete() { showDeleteConfirmation = true }

    func confirmDelete() {
        interactor.deleteMemory(id: memoryId)
        router.dismiss()
    }

    func didTapDuplicate() {
        guard let memory else { return }
        _ = interactor.duplicateMemory(memory)
        duplicatedMessage = true
    }

    func didTapPin() {
        guard let memory else { return }
        self.memory = interactor.togglePin(memory)
    }

    func didTapOpenInMaps() {
        guard let memory else { return }
        mapService.openInMaps(latitude: memory.latitude, longitude: memory.longitude, name: memory.title)
    }

    func copyCoordinates() {
        guard let memory else { return }
        UIPasteboard.general.string = "\(memory.latitude), \(memory.longitude)"
        copiedCoordinates = true
    }

    var shareText: String {
        guard let memory else { return "" }
        return interactor.shareMemory(memory: memory)
    }

    private func loadMemory() {
        memory = interactor.getMemory(id: memoryId)
        tripName = interactor.tripName(for: memory?.tripId)
    }
}
