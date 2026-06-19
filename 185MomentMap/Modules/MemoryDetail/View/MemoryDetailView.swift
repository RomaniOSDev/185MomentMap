import SwiftUI
import UIKit

enum MemoryDetailModuleBuilder {
    @MainActor
    static func build(memoryId: UUID, homePresenter: HomePresenter) -> MemoryDetailView {
        let router = MemoryDetailRouter()
        let interactor = MemoryDetailInteractor()
        let presenter = MemoryDetailPresenter(memoryId: memoryId, interactor: interactor, router: router)

        router.onNavigateToEdit = { id in
            homePresenter.navigationPath.append(.memoryCreate(editingId: id))
        }
        router.onDismiss = {
            if !homePresenter.navigationPath.isEmpty {
                homePresenter.navigationPath.removeLast()
            }
        }

        return MemoryDetailView(presenter: presenter)
    }
}

struct MemoryDetailView: View {
    @ObservedObject var presenter: MemoryDetailPresenter

    var body: some View {
        Group {
            if let memory = presenter.memory {
                ScrollView {
                    VStack(spacing: 16) {
                        heroSection(memory: memory)
                        quickActions(memory: memory)
                        infoCards(memory: memory)
                        deleteButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
                .appScreenBackground()
            } else {
                EmptyStateView(message: "Memory not found", icon: "exclamationmark.triangle", actionTitle: nil, action: nil)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Memory?", isPresented: $presenter.showDeleteConfirmation) {
            Button("Delete", role: .destructive) { presenter.confirmDelete() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
        .alert("Copied", isPresented: $presenter.copiedCoordinates) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Coordinates copied to clipboard.")
        }
        .alert("Duplicated", isPresented: $presenter.duplicatedMessage) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("A copy of this memory was created.")
        }
        .onAppear { presenter.viewDidLoad() }
    }

    private func heroSection(memory: Memory) -> some View {
        VStack(spacing: 0) {
            PhotoHeroGalleryView(imagesData: memory.allImagesData)
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(memory.title)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(AppColors.secondaryAccent)
                        Label(memory.date.formatted(pattern: "dd MMM yyyy"), systemImage: "calendar")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                    Spacer()
                    moodBadge(memory: memory)
                }

                if let address = memory.address, !address.isEmpty {
                    Label(address, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.secondaryText)
                }

                if let tripName = presenter.tripName {
                    Label(tripName, systemImage: "suitcase.fill")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppColors.accent)
                }

                if !memory.tags.isEmpty {
                    TagsFlowView(tags: memory.tags)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .depthListCard(accent: memory.mood.swiftUIColor)
            .offset(y: -20)
            .padding(.bottom, -20)
        }
    }

    private func moodBadge(memory: Memory) -> some View {
        VStack(spacing: 4) {
            Text(memory.mood.rawValue).font(.largeTitle)
            Text(memory.mood.displayName)
                .font(.caption.weight(.bold))
                .foregroundStyle(memory.mood.swiftUIColor)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(memory.mood.swiftUIColor.opacity(0.12))
        )
    }

    private func quickActions(memory: Memory) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
            ActionTile(title: "Maps", icon: "map.fill", color: AppColors.accent) {
                presenter.didTapOpenInMaps()
            }
            ActionTile(title: presenter.memory?.isPinned == true ? "Unpin" : "Pin", icon: "pin.fill", color: AppColors.secondaryAccent) {
                presenter.didTapPin()
            }
            ActionTile(title: "Copy", icon: "doc.on.doc", color: AppColors.secondaryAccent) {
                presenter.copyCoordinates()
            }
            ActionTile(title: "Duplicate", icon: "plus.square.on.square", color: AppColors.accent) {
                presenter.didTapDuplicate()
            }
        }
    }

    private func infoCards(memory: Memory) -> some View {
        VStack(spacing: 12) {
            if let note = memory.note, !note.isEmpty {
                DetailInfoCard(title: "Note", icon: "text.alignleft") {
                    Text(note)
                        .font(.body)
                        .foregroundStyle(AppColors.primaryText)
                }
            }

            if let audioData = memory.audioData {
                DetailInfoCard(title: "Audio", icon: "waveform") {
                    AudioNotePlayerView(audioData: audioData)
                }
            }

            DetailInfoCard(title: "Location", icon: "location.fill") {
                Text(String(format: "%.5f, %.5f", memory.latitude, memory.longitude))
                    .font(.body.monospaced())
                    .foregroundStyle(AppColors.primaryText)
            }

            HStack(spacing: 12) {
                Button("Edit") { presenter.didTapEdit() }
                    .buttonStyle(SecondaryButtonStyle())

                if let imageData = memory.primaryImageData, let uiImage = UIImage(data: imageData) {
                    ShareLink(item: presenter.shareText, preview: SharePreview(memory.title, image: Image(uiImage: uiImage))) {
                        Text("Share")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: AppTheme.innerRadius).fill(AppColors.accent))
                    }
                } else {
                    ShareLink(item: presenter.shareText) {
                        Text("Share")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(RoundedRectangle(cornerRadius: AppTheme.innerRadius).fill(AppColors.accent))
                    }
                }
            }
        }
    }

    private var deleteButton: some View {
        Button("Delete Memory") { presenter.didTapDelete() }
            .buttonStyle(SecondaryButtonStyle())
            .foregroundStyle(.red)
            .padding(.top, 8)
    }
}
