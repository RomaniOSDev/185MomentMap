import SwiftUI

struct OnboardingPage: Identifiable, Equatable {
    let id: Int
    let icon: String
    let title: String
    let subtitle: String
    let accent: Color
}

enum OnboardingPages {
    static let all: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            icon: "mappin.and.ellipse",
            title: "Pin Your Memories",
            subtitle: "Mark special places on the map and capture photos, moods, and voice notes.",
            accent: AppColors.accent
        ),
        OnboardingPage(
            id: 1,
            icon: "suitcase.fill",
            title: "Organize Adventures",
            subtitle: "Group memories into trips, add tags, and filter by mood or date.",
            accent: AppColors.secondaryAccent
        ),
        OnboardingPage(
            id: 2,
            icon: "sparkles",
            title: "Relive Every Moment",
            subtitle: "Browse your feed, explore the map, and rediscover memories from years past.",
            accent: .purple
        )
    ]
}
