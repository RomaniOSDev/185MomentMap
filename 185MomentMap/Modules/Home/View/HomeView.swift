import SwiftUI

struct HomeView: View {
    @ObservedObject var presenter: HomePresenter

    @StateObject private var mapPresenter = MapModuleBuilder.buildPresenter()
    @StateObject private var feedPresenter = FeedModuleBuilder.buildPresenter()

    var body: some View {
        NavigationStack(path: $presenter.navigationPath) {
            ZStack(alignment: .bottomTrailing) {
                TabView(selection: $presenter.selectedTab) {
                    HomeDashboardView(presenter: presenter)
                        .tabItem {
                            Label(HomeTab.home.title, systemImage: HomeTab.home.icon)
                        }
                        .tag(HomeTab.home)

                    MapView(presenter: mapPresenter)
                        .tabItem {
                            Label(HomeTab.map.title, systemImage: HomeTab.map.icon)
                        }
                        .tag(HomeTab.map)

                    FeedView(presenter: feedPresenter)
                        .tabItem {
                            Label(HomeTab.feed.title, systemImage: HomeTab.feed.icon)
                        }
                        .tag(HomeTab.feed)
                }
                .tint(AppColors.accent)

                FABView(action: { presenter.didTapCreate() })
                    .padding(.trailing, 20)
                    .padding(.bottom, 90)
            }
            .appScreenBackground()
            .navigationTitle(presenter.navigationPath.isEmpty ? presenter.selectedTab.title : "")
            .navigationBarTitleDisplayMode(
                presenter.navigationPath.isEmpty && presenter.selectedTab == .home ? .large : .inline
            )
            .toolbarBackground(AppColors.background.opacity(0.95), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button { presenter.didTapTrips() } label: {
                            Label("Trips", systemImage: "suitcase.fill")
                        }
                        Button { presenter.didTapSettings() } label: {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title3)
                            .foregroundStyle(AppColors.secondaryAccent)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { presenter.didTapStatistics() }) {
                        Image(systemName: "chart.bar.xaxis")
                            .symbolRenderingMode(.hierarchical)
                            .font(.title3)
                            .foregroundStyle(AppColors.secondaryAccent)
                    }
                    .accessibilityLabel("Statistics")
                }
            }
            .navigationDestination(for: HomeDestination.self) { destination in
                switch destination {
                case .memoryDetail(let id):
                    MemoryDetailModuleBuilder.build(memoryId: id, homePresenter: presenter)
                case .memoryCreate(let editingId):
                    MemoryCreateModuleBuilder.build(editingId: editingId, homePresenter: presenter)
                case .statistics:
                    StatisticsModuleBuilder.build()
                case .settings:
                    SettingsModuleBuilder.build()
                case .trips:
                    TripsModuleBuilder.build()
                }
            }
        }
        .onAppear {
            presenter.viewDidLoad()
            mapPresenter.onMemorySelected = { presenter.didSelectMemory($0) }
            feedPresenter.onMemorySelected = { presenter.didSelectMemory($0) }
        }
        .onChange(of: presenter.mapFocusRequest) { _, request in
            guard let request else { return }
            mapPresenter.focusOn(latitude: request.latitude, longitude: request.longitude)
        }
        .preferredColorScheme(.light)
    }
}
