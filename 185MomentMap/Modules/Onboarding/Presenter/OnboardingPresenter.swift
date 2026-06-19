import Foundation
import Combine
import SwiftUI

protocol OnboardingPresenterInput: AnyObject {
    func didTapNext()
    func didTapSkip()
}

@MainActor
final class OnboardingPresenter: ObservableObject, OnboardingPresenterInput {
    @Published var currentPage = 0

    let pages: [OnboardingPage]

    private let interactor: OnboardingInteractorInput
    private let router: OnboardingRouterInput

    init(interactor: OnboardingInteractorInput, router: OnboardingRouterInput) {
        self.interactor = interactor
        self.router = router
        self.pages = interactor.pages()
    }

    var isLastPage: Bool {
        currentPage == pages.count - 1
    }

    func didTapNext() {
        if isLastPage {
            completeOnboarding()
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage += 1
            }
        }
    }

    func didTapSkip() {
        completeOnboarding()
    }

    private func completeOnboarding() {
        interactor.markCompleted()
        router.finish()
    }
}
