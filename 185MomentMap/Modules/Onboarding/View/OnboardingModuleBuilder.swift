import SwiftUI

enum OnboardingModuleBuilder {
    static func shouldShowOnboarding() -> Bool {
        OnboardingInteractor().shouldShowOnboarding()
    }

    @MainActor
    static func build(onFinish: @escaping () -> Void) -> OnboardingView {
        let router = OnboardingRouter()
        let interactor = OnboardingInteractor()
        let presenter = OnboardingPresenter(interactor: interactor, router: router)
        router.onFinish = onFinish
        return OnboardingView(presenter: presenter)
    }
}
