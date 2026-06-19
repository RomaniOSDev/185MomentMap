import Foundation

enum StorageKeys {
    static let memories = "memories"
    static let trips = "trips"
    static let appSettings = "app_settings"
    static let recentlyViewed = "recently_viewed"
    static let hasCompletedOnboarding = "has_completed_onboarding"
}

enum AppConstants {
    static let imageCompressionQuality: CGFloat = 0.7
    static let maxRecentlyViewed = 20
    static let defaultNearMeRadiusKm: Double = 10
}
