import Foundation

protocol OnboardingInteractorInput: AnyObject {
    func pages() -> [OnboardingPage]
    func shouldShowOnboarding() -> Bool
    func markCompleted()
}

final class OnboardingInteractor: OnboardingInteractorInput {
    private let memoryRepository: MemoryRepositoryProtocol
    private let tripRepository: TripRepositoryProtocol
    private let defaults: UserDefaults

    init(
        memoryRepository: MemoryRepositoryProtocol = MemoryRepository.shared,
        tripRepository: TripRepositoryProtocol = TripRepository.shared,
        defaults: UserDefaults = .standard
    ) {
        self.memoryRepository = memoryRepository
        self.tripRepository = tripRepository
        self.defaults = defaults
    }

    func pages() -> [OnboardingPage] {
        OnboardingPages.all
    }

    func shouldShowOnboarding() -> Bool {
        if defaults.bool(forKey: StorageKeys.hasCompletedOnboarding) {
            return false
        }
        if !memoryRepository.fetchAll().isEmpty || !tripRepository.fetchAll().isEmpty {
            markCompleted()
            return false
        }
        return true
    }

    func markCompleted() {
        defaults.set(true, forKey: StorageKeys.hasCompletedOnboarding)
    }
}
