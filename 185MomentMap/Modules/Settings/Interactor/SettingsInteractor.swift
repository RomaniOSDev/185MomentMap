import Foundation

protocol SettingsInteractorInput: AnyObject {
    func loadSettings() -> AppSettings
    func saveSettings(_ settings: AppSettings)
    func loadFormData() -> SettingsFormData
}

final class SettingsInteractor: SettingsInteractorInput {
    private let repository: SettingsRepositoryProtocol

    init(repository: SettingsRepositoryProtocol = SettingsRepository.shared) {
        self.repository = repository
    }

    func loadSettings() -> AppSettings {
        repository.load()
    }

    func saveSettings(_ settings: AppSettings) {
        repository.save(settings)
    }

    func loadFormData() -> SettingsFormData {
        let settings = repository.load()
        var form = SettingsFormData(defaultNearMeRadiusKm: settings.defaultNearMeRadiusKm)
        form.homeName = settings.homeName ?? ""
        if let lat = settings.homeLatitude { form.homeLatitude = String(lat) }
        if let lon = settings.homeLongitude { form.homeLongitude = String(lon) }
        return form
    }
}
