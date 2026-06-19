import SwiftUI

enum FeedModuleBuilder {
    @MainActor
    static func buildPresenter() -> FeedPresenter {
        let router = FeedRouter()
        let interactor = FeedInteractor()
        let presenter = FeedPresenter(interactor: interactor, router: router)
        router.onNavigateToDetail = { memory in
            presenter.onMemorySelected?(memory)
        }
        return presenter
    }
}

struct FeedView: View {
    @ObservedObject var presenter: FeedPresenter

    var body: some View {
        VStack(spacing: 0) {
            filterChipBar

            Group {
                if presenter.sections.isEmpty {
                    EmptyStateView(
                        message: presenter.hasActiveFilters
                            ? "No memories match your filters."
                            : "No memories yet.\nTap + to add your first one.",
                        icon: "photo.on.rectangle.angled",
                        actionTitle: nil,
                        action: nil
                    )
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 20) {
                            ForEach(presenter.sections) { section in
                                sectionView(section)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .appScreenBackground()
        .searchable(text: Binding(
            get: { presenter.searchQuery },
            set: { presenter.search(query: $0) }
        ), prompt: "Search title, address, note, mood, tags")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Menu {
                    Menu("Mood") {
                        Button("All Moods") { presenter.filter(by: nil as Mood?) }
                        ForEach(Mood.allCases) { mood in
                            Button("\(mood.rawValue) \(mood.displayName)") { presenter.filter(by: mood) }
                        }
                    }
                    Menu("Tag") {
                        Button("All Tags") { presenter.filter(by: nil as MemoryTag?) }
                        ForEach(MemoryTag.allCases) { tag in
                            Button(tag.displayName) { presenter.filter(by: tag) }
                        }
                    }
                    Menu("Trip") {
                        Button("All Trips") { presenter.filter(by: nil as UUID?) }
                        ForEach(presenter.trips) { trip in
                            Button(trip.name) { presenter.filter(by: trip.id) }
                        }
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundStyle(AppColors.secondaryAccent)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(FeedSortOption.allCases) { option in
                        Button(option.title) { presenter.sort(by: option) }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(AppColors.secondaryAccent)
                }
            }
        }
        .alert("Delete Memory?", isPresented: Binding(
            get: { presenter.memoryToDelete != nil },
            set: { if !$0 { presenter.memoryToDelete = nil } }
        )) {
            Button("Delete", role: .destructive) { presenter.confirmDelete() }
            Button("Cancel", role: .cancel) { presenter.memoryToDelete = nil }
        } message: {
            Text("This action cannot be undone.")
        }
        .onAppear { presenter.viewDidLoad() }
    }

    private var filterChipBar: some View {
        FilterChipBar(chips: [
            FilterChip(id: "fav", title: "Favorites", icon: "heart.fill", isActive: presenter.favoritesOnly) {
                presenter.filter(favoritesOnly: !presenter.favoritesOnly)
            },
            FilterChip(id: "week", title: "Week", icon: "calendar", isActive: presenter.dateRange == .week) {
                presenter.filter(dateRange: presenter.dateRange == .week ? .all : .week)
            },
            FilterChip(id: "month", title: "Month", icon: nil, isActive: presenter.dateRange == .month) {
                presenter.filter(dateRange: presenter.dateRange == .month ? .all : .month)
            },
            FilterChip(id: "year", title: "Year", icon: nil, isActive: presenter.dateRange == .year) {
                presenter.filter(dateRange: presenter.dateRange == .year ? .all : .year)
            },
            FilterChip(id: "mood", title: presenter.selectedMoodFilter?.displayName ?? "Mood", icon: "face.smiling", isActive: presenter.selectedMoodFilter != nil) {
                presenter.filter(by: nil as Mood?)
            },
            FilterChip(id: "tag", title: presenter.selectedTag?.displayName ?? "Tag", icon: "tag", isActive: presenter.selectedTag != nil) {
                presenter.filter(by: nil as MemoryTag?)
            }
        ])
    }

    @ViewBuilder
    private func sectionView(_ section: FeedSection) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(
                title: section.title,
                icon: iconForSection(section.id),
                subtitle: subtitleForSection(section),
                style: styleForSection(section.id)
            )

            if section.id == "recent" {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(section.memories) { memory in
                            MemoryCardView(
                                memory: memory,
                                style: .compact,
                                onTap: { presenter.didTapMemory(memory: memory) },
                                onFavorite: { presenter.didTapFavorite(memory: memory) },
                                onShare: {}
                            )
                            .frame(width: 220)
                        }
                    }
                }
            } else {
                ForEach(section.memories) { memory in
                    MemoryCardView(
                        memory: memory,
                        style: section.id == "onThisDay" ? .featured : .standard,
                        onTap: { presenter.didTapMemory(memory: memory) },
                        onFavorite: { presenter.didTapFavorite(memory: memory) },
                        onPin: { presenter.didTapPin(memory: memory) },
                        onShare: {}
                    )
                    .contextMenu {
                        Button(memory.isPinned ? "Unpin" : "Pin") {
                            presenter.didTapPin(memory: memory)
                        }
                        Button(role: .destructive) {
                            presenter.didTapDelete(memory: memory)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }

    private func iconForSection(_ id: String) -> String? {
        switch id {
        case "drafts": return "doc.text"
        case "onThisDay": return "sparkles"
        case "recent": return "clock.arrow.circlepath"
        default: return "photo.stack"
        }
    }

    private func styleForSection(_ id: String) -> SectionHeaderView.Style {
        switch id {
        case "drafts": return .draft
        case "onThisDay": return .featured
        default: return .standard
        }
    }

    private func subtitleForSection(_ section: FeedSection) -> String? {
        switch section.id {
        case "onThisDay": return "Memories from this day in past years"
        case "recent": return "\(section.memories.count) recently opened"
        case "drafts": return "\(section.memories.count) unsaved"
        default: return "\(section.memories.count) items"
        }
    }
}
