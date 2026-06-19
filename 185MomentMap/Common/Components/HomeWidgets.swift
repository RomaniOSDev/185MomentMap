import SwiftUI
import UIKit

// MARK: - Hero Banner

struct HomeHeroBanner: View {
    let greeting: String
    let totalMemories: Int
    let activeDays: Int

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("HomeHeroBanner")
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()

            LinearGradient(
                colors: [.clear, .black.opacity(0.55)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(greeting)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.9))
                Text("Your journey continues")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                HStack(spacing: 16) {
                    heroStat(value: "\(totalMemories)", label: "Places")
                    heroStat(value: "\(activeDays)", label: "Days")
                }
            }
            .padding(20)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: .black.opacity(AppElevation.elevated.opacity), radius: AppElevation.elevated.radius, y: AppElevation.elevated.y)
    }

    private func heroStat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(.title3.weight(.bold)).foregroundStyle(.white)
            Text(label).font(.caption).foregroundStyle(.white.opacity(0.8))
        }
    }
}

// MARK: - Stat Widget

struct HomeStatWidget: View {
    let title: String
    let value: String
    let icon: String
    let accent: Color
    var backgroundImage: String? = nil

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let backgroundImage {
                Image(backgroundImage)
                    .resizable()
                    .scaledToFill()
                    .opacity(0.35)
            }

            LinearGradient(
                colors: [accent.opacity(0.08), accent.opacity(0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    Circle().fill(accent.opacity(0.15)).frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(accent)
                }
                Text(value)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(AppColors.secondaryText)
            }
            .padding(14)
        }
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
        .background(AppSurfaceShape(radius: AppTheme.cardRadius, accent: accent, gradient: AppGradients.accent(accent)))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: .black.opacity(AppElevation.card.opacity), radius: AppElevation.card.radius, y: AppElevation.card.y)
    }
}

// MARK: - Quick Actions

struct HomeQuickActionsWidget: View {
    let onAction: (HomeQuickActionType) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline.weight(.bold))
                .foregroundStyle(AppColors.secondaryAccent)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(HomeQuickActionType.allCases) { action in
                    Button { onAction(action) } label: {
                        VStack(spacing: 8) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(AppGradients.iconBadge(actionColor(action)))
                                    .frame(width: 48, height: 48)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(actionColor(action).opacity(0.2), lineWidth: 1)
                                    )
                                Image(systemName: action.icon)
                                    .font(.title3)
                                    .foregroundStyle(actionColor(action))
                            }
                            Text(action.title)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(AppColors.primaryText)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .appCard()
    }

    private func actionColor(_ action: HomeQuickActionType) -> Color {
        switch action {
        case .addMemory: return AppColors.accent
        case .openMap: return AppColors.secondaryAccent
        case .openFeed: return .purple
        case .statistics: return .orange
        case .trips: return .teal
        }
    }
}

// MARK: - Memory Spotlight Widget

struct HomeMemorySpotlightWidget: View {
    let title: String
    let subtitle: String
    let memories: [Memory]
    let textureImage: String?
    let onSelect: (Memory) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(AppColors.secondaryAccent)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(AppColors.secondaryText)
                }
                Spacer()
            }

            if memories.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.title)
                            .foregroundStyle(AppColors.accent.opacity(0.5))
                        Text("No memories here yet")
                            .font(.caption)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                    .padding(.vertical, 20)
                    Spacer()
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(memories) { memory in
                            HomeMemoryTile(memory: memory, textureImage: textureImage) {
                                onSelect(memory)
                            }
                        }
                    }
                }
            }
        }
        .appCard()
    }
}

struct HomeMemoryTile: View {
    let memory: Memory
    let textureImage: String?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    if let data = memory.primaryImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else if let textureImage {
                        Image(textureImage)
                            .resizable()
                            .scaledToFill()
                            .overlay {
                                Text(memory.mood.rawValue)
                                    .font(.system(size: 36))
                            }
                    } else {
                        memory.mood.swiftUIColor.opacity(0.2)
                        Text(memory.mood.rawValue).font(.largeTitle)
                    }
                }
                .frame(width: 140, height: 100)
                .clipped()

                VStack(alignment: .leading, spacing: 4) {
                    Text(memory.title)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(1)
                    Text(memory.date.formatted(pattern: "dd MMM"))
                        .font(.caption2)
                        .foregroundStyle(AppColors.secondaryText)
                }
                .padding(10)
                .frame(width: 140, alignment: .leading)
                .background(AppColors.background)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(memory.mood.swiftUIColor.opacity(0.25), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Mood Widget

struct HomeMoodWidget: View {
    let mood: Mood?
    let totalMemories: Int

    var body: some View {
        HStack(spacing: 16) {
            if let mood {
                ZStack {
                    Circle()
                        .fill(mood.swiftUIColor.opacity(0.15))
                        .frame(width: 64, height: 64)
                    Text(mood.rawValue).font(.largeTitle)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text("Top Mood")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(AppColors.secondaryText)
                    Text(mood.displayName)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(mood.swiftUIColor)
                    Text("Across \(totalMemories) memories")
                        .font(.caption)
                        .foregroundStyle(AppColors.secondaryText)
                }
            } else {
                Image(systemName: "face.smiling")
                    .font(.largeTitle)
                    .foregroundStyle(AppColors.accent.opacity(0.4))
                Text("Add memories to see your top mood")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
            }
            Spacer()
        }
        .appCard(accent: mood?.swiftUIColor ?? AppColors.accent)
    }
}

// MARK: - Trips Widget

struct HomeTripsWidget: View {
    let trips: [Trip]
    let onSeeAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Your Trips", systemImage: "suitcase.fill")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppColors.secondaryAccent)
                Spacer()
                Button("See All", action: onSeeAll)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppColors.accent)
            }

            if trips.isEmpty {
                Text("Create a trip to group your adventures")
                    .font(.caption)
                    .foregroundStyle(AppColors.secondaryText)
            } else {
                ForEach(trips) { trip in
                    HStack(spacing: 12) {
                        Image("WidgetMapTexture")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(trip.name)
                                .font(.subheadline.weight(.semibold))
                            if let start = trip.startDate {
                                Text(start.formatted(pattern: "MMM yyyy"))
                                    .font(.caption2)
                                    .foregroundStyle(AppColors.secondaryText)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                }
            }
        }
        .appCard()
    }
}

// MARK: - Map Preview Widget

struct HomeMapPreviewWidget: View {
    let memoryCount: Int
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            ZStack(alignment: .bottomLeading) {
                Image("WidgetMapTexture")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipped()

                LinearGradient(
                    colors: [.clear, AppColors.secondaryAccent.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Explore Map")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.white)
                        Text("\(memoryCount) pins waiting")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
                .padding(16)
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
            .shadow(color: .black.opacity(AppElevation.card.opacity), radius: AppElevation.card.radius, y: AppElevation.card.y)
        }
        .buttonStyle(.plain)
    }
}
