import Foundation

struct AppSettings: Codable {
    var homeLatitude: Double?
    var homeLongitude: Double?
    var homeName: String?
    var lastMapCenterLatitude: Double?
    var lastMapCenterLongitude: Double?
    var lastMapSpanLatitude: Double?
    var lastMapSpanLongitude: Double?
    var defaultNearMeRadiusKm: Double

    static let `default` = AppSettings(defaultNearMeRadiusKm: 10)

    var hasHomeLocation: Bool {
        homeLatitude != nil && homeLongitude != nil
    }

    var lastMapRegion: SavedMapRegion? {
        guard let lat = lastMapCenterLatitude,
              let lon = lastMapCenterLongitude,
              let spanLat = lastMapSpanLatitude,
              let spanLon = lastMapSpanLongitude else { return nil }
        return SavedMapRegion(
            centerLatitude: lat,
            centerLongitude: lon,
            spanLatitude: spanLat,
            spanLongitude: spanLon
        )
    }
}

struct SavedMapRegion: Codable, Equatable {
    let centerLatitude: Double
    let centerLongitude: Double
    let spanLatitude: Double
    let spanLongitude: Double
}

struct RecentlyViewedEntry: Codable, Identifiable, Equatable {
    let id: UUID
    let memoryId: UUID
    let viewedAt: Date
}
