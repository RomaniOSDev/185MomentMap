import Foundation

protocol SettingsRepositoryProtocol {
    func load() -> AppSettings
    func save(_ settings: AppSettings)
    func saveMapRegion(_ region: SavedMapRegion)
}

final class SettingsRepository: SettingsRepositoryProtocol {
    static let shared = SettingsRepository()

    private let storage: StorageServiceProtocol
    private let storageKey = StorageKeys.appSettings
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(storage: StorageServiceProtocol = UserDefaultsStorageService()) {
        self.storage = storage
    }

    func load() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let settings = try? decoder.decode(AppSettings.self, from: data) else {
            return .default
        }
        return settings
    }

    func save(_ settings: AppSettings) {
        guard let data = try? encoder.encode(settings) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
        NotificationCenter.default.post(name: .settingsDidChange, object: nil)
    }

    func saveMapRegion(_ region: SavedMapRegion) {
        var settings = load()
        settings.lastMapCenterLatitude = region.centerLatitude
        settings.lastMapCenterLongitude = region.centerLongitude
        settings.lastMapSpanLatitude = region.spanLatitude
        settings.lastMapSpanLongitude = region.spanLongitude
        save(settings)
    }
}
