import Foundation
import Combine
import Combine

protocol TripsPresenterInput: AnyObject {
    func viewDidLoad()
    func didTapSaveTrip()
    func didTapDelete(trip: Trip)
    func confirmDelete()
}

@MainActor
final class TripsPresenter: ObservableObject, TripsPresenterInput {
    @Published var trips: [(trip: Trip, count: Int)] = []
    @Published var form = TripFormData()
    @Published var tripToDelete: Trip?
    @Published var showCreateForm = false

    private let interactor: TripsInteractorInput
    private var cancellables = Set<AnyCancellable>()

    init(interactor: TripsInteractorInput) {
        self.interactor = interactor
        NotificationCenter.default.publisher(for: .tripsDidChange)
            .merge(with: NotificationCenter.default.publisher(for: .memoriesDidChange))
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateUI() }
            .store(in: &cancellables)
    }

    func viewDidLoad() { updateUI() }

    func didTapSaveTrip() {
        let name = form.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        let trip = Trip(
            name: name,
            note: form.note.isEmpty ? nil : form.note,
            startDate: form.hasDates ? form.startDate : nil,
            endDate: form.hasDates ? form.endDate : nil
        )
        interactor.saveTrip(trip)
        form = TripFormData()
        showCreateForm = false
        updateUI()
    }

    func didTapDelete(trip: Trip) { tripToDelete = trip }

    func confirmDelete() {
        guard let trip = tripToDelete else { return }
        interactor.deleteTrip(id: trip.id)
        tripToDelete = nil
        updateUI()
    }

    private func updateUI() {
        trips = interactor.loadTrips().map { ($0, interactor.memoryCount(for: $0.id)) }
    }
}
