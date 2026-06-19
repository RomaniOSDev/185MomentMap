import Foundation
import Combine

protocol FeedPresenterInput: AnyObject {
    func viewDidLoad()
    func didTapMemory(memory: Memory)
    func didTapDelete(memory: Memory)
    func didTapFavorite(memory: Memory)
    func didTapPin(memory: Memory)
    func search(query: String)
    func filter(by mood: Mood?)
    func filter(by tag: MemoryTag?)
    func filter(by trip: UUID?)
    func filter(favoritesOnly: Bool)
    func filter(dateRange: DateRangeFilter)
    func sort(by option: FeedSortOption)
}

@MainActor
final class FeedPresenter: ObservableObject, FeedPresenterInput {
    @Published var sections: [FeedSection] = []
    @Published var searchQuery: String = ""
    @Published var selectedMoodFilter: Mood?
    @Published var selectedTag: MemoryTag?
    @Published var selectedTripId: UUID?
    @Published var favoritesOnly = false
    @Published var dateRange: DateRangeFilter = .all
    @Published var sortOption: FeedSortOption = .dateNewest
    @Published var memoryToDelete: Memory?
    @Published var trips: [Trip] = []

    var onMemorySelected: ((Memory) -> Void)?

    private let interactor: FeedInteractorInput
    private let router: FeedRouterInput
    private var cancellables = Set<AnyCancellable>()

    init(interactor: FeedInteractorInput, router: FeedRouterInput) {
        self.interactor = interactor
        self.router = router

        NotificationCenter.default.publisher(for: .memoriesDidChange)
            .merge(with: NotificationCenter.default.publisher(for: .tripsDidChange))
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.updateUI() }
            .store(in: &cancellables)
    }

    func viewDidLoad() { updateUI() }

    func didTapMemory(memory: Memory) {
        router.navigateToMemoryDetail(memory: memory)
    }

    func didTapDelete(memory: Memory) { memoryToDelete = memory }

    func confirmDelete() {
        guard let memory = memoryToDelete else { return }
        interactor.deleteMemory(id: memory.id)
        memoryToDelete = nil
        updateUI()
    }

    func didTapFavorite(memory: Memory) {
        _ = interactor.toggleFavorite(memory: memory)
        updateUI()
    }

    func didTapPin(memory: Memory) {
        _ = interactor.togglePinned(memory: memory)
        updateUI()
    }

    func search(query: String) { searchQuery = query; updateUI() }
    func filter(by mood: Mood?) { selectedMoodFilter = mood; updateUI() }
    func filter(by tag: MemoryTag?) { selectedTag = tag; updateUI() }
    func filter(by trip: UUID?) { selectedTripId = trip; updateUI() }
    func filter(favoritesOnly: Bool) { self.favoritesOnly = favoritesOnly; updateUI() }
    func filter(dateRange: DateRangeFilter) { self.dateRange = dateRange; updateUI() }
    func sort(by option: FeedSortOption) { sortOption = option; updateUI() }

    var hasActiveFilters: Bool {
        selectedMoodFilter != nil || selectedTag != nil || selectedTripId != nil
            || favoritesOnly || dateRange != .all || !searchQuery.isEmpty
    }

    func updateUI() {
        trips = interactor.loadTrips()
        var criteria = MemoryFilterCriteria()
        criteria.mood = selectedMoodFilter
        if let selectedTag { criteria.tags = [selectedTag] }
        criteria.tripId = selectedTripId
        criteria.favoritesOnly = favoritesOnly
        criteria.dateRange = dateRange
        criteria.searchQuery = searchQuery

        let main = interactor.applyFilters(criteria: criteria, sort: sortOption)
        let onThisDay = interactor.loadOnThisDayMemories()
        let recent = interactor.loadRecentlyViewed()
        let drafts = interactor.loadDrafts()

        var built: [FeedSection] = []
        if !drafts.isEmpty {
            built.append(FeedSection(id: "drafts", title: "Drafts", memories: drafts))
        }
        if !onThisDay.isEmpty {
            built.append(FeedSection(id: "onThisDay", title: "On This Day", memories: onThisDay))
        }
        if !recent.isEmpty, searchQuery.isEmpty, !hasActiveFilters {
            built.append(FeedSection(id: "recent", title: "Recently Viewed", memories: recent))
        }
        if !main.isEmpty {
            built.append(FeedSection(id: "all", title: "All Memories", memories: main))
        }
        sections = built
    }
}
