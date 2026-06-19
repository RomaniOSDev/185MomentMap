import Foundation

protocol OnboardingRouterInput: AnyObject {
    func finish()
}

final class OnboardingRouter: OnboardingRouterInput {
    var onFinish: (() -> Void)?

    func finish() {
        onFinish?()
    }
}
