import SwiftUI

enum StatisticsModuleBuilder {
    @MainActor
    static func build() -> StatisticsView {
        let presenter = StatisticsPresenter(interactor: StatisticsInteractor(), router: StatisticsRouter())
        return StatisticsView(presenter: presenter)
    }
}

struct StatisticsView: View {
    @ObservedObject var presenter: StatisticsPresenter
    @State private var showShareSheet = false

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let metricColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    var body: some View {
        ScrollView {
            if let data = presenter.displayData {
                VStack(alignment: .leading, spacing: 20) {
                    metricsGrid(data)
                    farthestCard(data)
                    moodsCard(data)
                    monthlyMoodCard(data)
                    topCitiesCard(data)
                    activityCard(data)
                    actionButtons
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .scrollContentBackground(.hidden)
        .appScreenBackground()
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(AppColors.background.opacity(0.95), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear { presenter.viewDidLoad() }
        .alert("Reset All Data?", isPresented: $presenter.showResetConfirmation) {
            Button("Reset", role: .destructive) { presenter.confirmReset() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("All memories will be permanently deleted.")
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = presenter.exportURL {
                ShareSheet(items: [url])
            }
        }
        .onChange(of: presenter.exportURL) { _, url in
            showShareSheet = url != nil
        }
    }

    private func metricsGrid(_ data: StatisticsDisplayData) -> some View {
        LazyVGrid(columns: metricColumns, spacing: 12) {
            StatMetricCard(title: "Total Places", value: "\(data.statistics.totalMemories)", icon: "mappin.and.ellipse", accent: AppColors.accent)
            StatMetricCard(title: "Active Days", value: "\(data.statistics.uniqueDays)", icon: "calendar", accent: AppColors.secondaryAccent)
            StatMetricCard(title: "Favorites", value: "\(data.statistics.favoriteCount)", icon: "heart.fill", accent: .pink)
            StatMetricCard(title: "Best Month", value: data.statistics.bestMonth ?? "—", icon: "star.fill", accent: .orange)
        }
    }

    private func farthestCard(_ data: StatisticsDisplayData) -> some View {
        DetailInfoCard(title: "Farthest from Home", icon: "airplane") {
            if let title = data.statistics.farthestMemoryTitle,
               let distance = data.statistics.farthestDistanceKm {
                StatListRow(rank: nil, title: title, trailing: String(format: "%.0f km", distance))
            } else {
                Text("Set home location in Settings to see your farthest memory.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
    }

    private func moodsCard(_ data: StatisticsDisplayData) -> some View {
        DetailInfoCard(title: "Mood Breakdown", icon: "chart.bar.fill") {
            if let favorite = data.statistics.favoriteMood {
                HStack(spacing: 8) {
                    Text("Top mood:")
                        .foregroundStyle(AppColors.secondaryText)
                    Text(favorite.rawValue)
                    Text(favorite.displayName)
                        .fontWeight(.semibold)
                        .foregroundStyle(favorite.swiftUIColor)
                }
                .font(.subheadline)
                .padding(.bottom, 8)
            }
            StatsBarChartView(items: data.moodChartItems)
        }
    }

    private func monthlyMoodCard(_ data: StatisticsDisplayData) -> some View {
        DetailInfoCard(title: "Mood by Month", icon: "calendar.badge.clock") {
            if data.monthlyMoodSummaries.isEmpty {
                Text("No monthly data yet").foregroundStyle(AppColors.secondaryText)
            } else {
                ForEach(Array(data.monthlyMoodSummaries.enumerated()), id: \.element.id) { index, item in
                    StatListRow(
                        rank: index + 1,
                        title: item.month,
                        trailing: "\(item.count)",
                        emoji: item.dominantMood.rawValue
                    )
                    if index < data.monthlyMoodSummaries.count - 1 {
                        Divider()
                    }
                }
            }
        }
    }

    private func topCitiesCard(_ data: StatisticsDisplayData) -> some View {
        DetailInfoCard(title: "Top Cities", icon: "building.2.fill") {
            if data.topCities.isEmpty {
                Text("No city data yet").foregroundStyle(AppColors.secondaryText)
            } else {
                ForEach(Array(data.topCities.enumerated()), id: \.offset) { index, item in
                    StatListRow(rank: index + 1, title: item.city, trailing: "\(item.count)")
                    if index < data.topCities.count - 1 { Divider() }
                }
            }
        }
    }

    private func activityCard(_ data: StatisticsDisplayData) -> some View {
        DetailInfoCard(title: "Activity", icon: "square.grid.3x3.fill") {
            let days = recentActivityDays(from: data.activityDays)
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(days) { day in
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(day.count > 0 ? AppColors.accent.opacity(0.35) : Color.gray.opacity(0.08))
                        .frame(height: 30)
                        .overlay {
                            if day.count > 0 {
                                Text("\(day.count)")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(AppColors.primaryText)
                            }
                        }
                }
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button("Export Data") { presenter.didTapExport() }
                .buttonStyle(PrimaryButtonStyle())
            Button("Reset All Data") { presenter.didTapReset() }
                .buttonStyle(SecondaryButtonStyle())
                .foregroundStyle(.red)
        }
    }

    private func recentActivityDays(from days: [ActivityDay]) -> [ActivityDay] {
        let today = Date().startOfDay(calendar: calendar)
        return (0..<35).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -34 + offset, to: today) else { return nil }
            let dayStart = date.startOfDay(calendar: calendar)
            let count = days.first(where: { calendar.isDate($0.date, inSameDayAs: dayStart) })?.count ?? 0
            return ActivityDay(id: "day-\(offset)", date: dayStart, count: count)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
