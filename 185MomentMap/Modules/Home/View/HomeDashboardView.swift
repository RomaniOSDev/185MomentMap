import SwiftUI

struct HomeDashboardView: View {
    @ObservedObject var presenter: HomePresenter

    private let statColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    var body: some View {
        ScrollView {
            if let data = presenter.dashboard {
                VStack(spacing: 16) {
                    HomeHeroBanner(
                        greeting: presenter.greeting,
                        totalMemories: data.totalMemories,
                        activeDays: data.activeDays
                    )

                    LazyVGrid(columns: statColumns, spacing: 12) {
                        HomeStatWidget(
                            title: "Memories",
                            value: "\(data.totalMemories)",
                            icon: "photo.stack.fill",
                            accent: AppColors.accent,
                            backgroundImage: "WidgetMemoriesTexture"
                        )
                        HomeStatWidget(
                            title: "Favorites",
                            value: "\(data.favoritesCount)",
                            icon: "heart.fill",
                            accent: .pink
                        )
                        HomeStatWidget(
                            title: "Trips",
                            value: "\(data.tripsCount)",
                            icon: "suitcase.fill",
                            accent: AppColors.secondaryAccent,
                            backgroundImage: "WidgetMapTexture"
                        )
                        HomeStatWidget(
                            title: "Active Days",
                            value: "\(data.activeDays)",
                            icon: "calendar",
                            accent: .orange
                        )
                    }

                    HomeQuickActionsWidget { presenter.didTapQuickAction($0) }

                    HomeMapPreviewWidget(memoryCount: data.totalMemories) {
                        presenter.didSelectTab(.map)
                    }

                    if !data.onThisDay.isEmpty {
                        HomeMemorySpotlightWidget(
                            title: "On This Day",
                            subtitle: "Memories from this date in past years",
                            memories: data.onThisDay,
                            textureImage: "WidgetMemoriesTexture",
                            onSelect: { presenter.didSelectMemory($0) }
                        )
                    }

                    HomeMemorySpotlightWidget(
                        title: "Recently Viewed",
                        subtitle: "Pick up where you left off",
                        memories: data.recentMemories,
                        textureImage: "WidgetMemoriesTexture",
                        onSelect: { presenter.didSelectMemory($0) }
                    )

                    HomeMemorySpotlightWidget(
                        title: "Latest Memories",
                        subtitle: "Your most recent adventures",
                        memories: data.latestMemories,
                        textureImage: nil,
                        onSelect: { presenter.didSelectMemory($0) }
                    )

                    HomeMoodWidget(mood: data.topMood, totalMemories: data.totalMemories)

                    HomeTripsWidget(trips: data.trips, onSeeAll: { presenter.didTapTrips() })
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 110)
            } else {
                ProgressView()
                    .padding(.top, 80)
            }
        }
        .scrollContentBackground(.hidden)
        .appScreenBackground()
        .refreshable { presenter.refreshDashboard() }
    }
}
