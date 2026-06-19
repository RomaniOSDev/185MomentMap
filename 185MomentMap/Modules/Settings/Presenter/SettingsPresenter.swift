import Foundation
import Combine

protocol SettingsPresenterInput: AnyObject {
    func viewDidLoad()
    func didTapSave()
    func didTapRateApp()
    func didTapPrivacyPolicy()
    func didTapTermsOfUse()
}

@MainActor
final class SettingsPresenter: ObservableObject, SettingsPresenterInput {
    @Published var form = SettingsFormData()
    @Published var savedMessage = false

    private let interactor: SettingsInteractorInput
    private let router: SettingsRouterInput

    init(interactor: SettingsInteractorInput, router: SettingsRouterInput) {
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() {
        form = interactor.loadFormData()
    }

    func didTapSave() {
        var settings = interactor.loadSettings()
        settings.homeName = form.homeName.isEmpty ? nil : form.homeName
        settings.homeLatitude = Double(form.homeLatitude)
        settings.homeLongitude = Double(form.homeLongitude)
        settings.defaultNearMeRadiusKm = form.defaultNearMeRadiusKm
        interactor.saveSettings(settings)
        savedMessage = true
    }

    func didTapRateApp() {
        router.rateApp()
    }

    func didTapPrivacyPolicy() {
        router.openLink(.privacyPolicy)
    }

    func didTapTermsOfUse() {
        router.openLink(.termsOfUse)
    }
}
