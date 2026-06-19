import Foundation
import Combine

protocol StatisticsPresenterInput: AnyObject {
    func viewDidLoad()
    func didTapExport()
    func didTapReset()
    func confirmReset()
}

@MainActor
final class StatisticsPresenter: ObservableObject, StatisticsPresenterInput {
    @Published var displayData: StatisticsDisplayData?
    @Published var showResetConfirmation = false
    @Published var exportURL: URL?

    private let interactor: StatisticsInteractorInput
    private let router: StatisticsRouterInput
    private var cancellables = Set<AnyCancellable>()

    init(interactor: StatisticsInteractorInput, router: StatisticsRouterInput) {
        self.interactor = interactor
        self.router = router

        NotificationCenter.default.publisher(for: .memoriesDidChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.loadStats()
            }
            .store(in: &cancellables)
    }

    func viewDidLoad() {
        loadStats()
    }

    func didTapExport() {
        let json = interactor.exportData()
        let fileName = "memories_export_\(Int(Date().timeIntervalSince1970)).json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try? json.write(to: url, atomically: true, encoding: .utf8)
        exportURL = url
    }

    func didTapReset() {
        showResetConfirmation = true
    }

    func confirmReset() {
        interactor.resetStats()
        loadStats()
    }

    private func loadStats() {
        displayData = interactor.calculateStats()
    }
}
