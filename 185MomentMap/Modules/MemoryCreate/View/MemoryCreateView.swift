import SwiftUI
import UIKit
import PhotosUI

enum MemoryCreateModuleBuilder {
    @MainActor
    static func build(editingId: UUID?, homePresenter: HomePresenter) -> MemoryCreateView {
        let router = MemoryCreateRouter()
        let interactor = MemoryCreateInteractor()
        let presenter = MemoryCreatePresenter(interactor: interactor, router: router, editingId: editingId)

        router.onDismissToMap = { lat, lon in
            if !homePresenter.navigationPath.isEmpty { homePresenter.navigationPath.removeLast() }
            homePresenter.didSaveMemory(latitude: lat, longitude: lon)
        }
        router.onDismiss = {
            if !homePresenter.navigationPath.isEmpty { homePresenter.navigationPath.removeLast() }
        }
        router.onShowError = { presenter.errorMessage = $0 }

        return MemoryCreateView(presenter: presenter)
    }
}

struct MemoryCreateView: View {
    @ObservedObject var presenter: MemoryCreatePresenter
    @StateObject private var audioRecorder = AudioRecorderService()
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedTemplate: PlaceTemplate?

    private let moodColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 5)
    private let templateColumns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                FormSectionCard(title: "Quick Templates", icon: "wand.and.stars") {
                    LazyVGrid(columns: templateColumns, spacing: 10) {
                        ForEach(PlaceTemplate.allCases) { template in
                            PlaceTemplateCell(
                                template: template,
                                isSelected: selectedTemplate == template
                            ) {
                                selectedTemplate = template
                                presenter.didSelectTemplate(template)
                            }
                        }
                    }
                }

                FormSectionCard(title: "Details", icon: "textformat") {
                    VStack(spacing: 12) {
                        AppTextField(placeholder: "Title *", text: $presenter.form.title)
                        AppTextField(placeholder: "Address", text: $presenter.form.address)
                        HStack(spacing: 10) {
                            AppTextField(placeholder: "Latitude", text: $presenter.form.latitude, keyboardType: .decimalPad)
                            AppTextField(placeholder: "Longitude", text: $presenter.form.longitude, keyboardType: .decimalPad)
                        }
                    }
                }

                FormSectionCard(title: "Trip & Tags", icon: "tag") {
                    VStack(alignment: .leading, spacing: 14) {
                        Picker("Trip", selection: Binding(
                            get: { presenter.form.tripId },
                            set: { presenter.form.tripId = $0 }
                        )) {
                            Text("None").tag(UUID?.none)
                            ForEach(presenter.trips) { trip in
                                Text(trip.name).tag(Optional(trip.id))
                            }
                        }
                        .tint(AppColors.accent)

                        FlowLayout(spacing: 8) {
                            ForEach(MemoryTag.allCases) { tag in
                                TagChipView(tag: tag, isSelected: presenter.form.tags.contains(tag)) {
                                    presenter.didToggleTag(tag)
                                }
                            }
                        }
                    }
                }

                FormSectionCard(title: "Mood *", icon: "face.smiling") {
                    LazyVGrid(columns: moodColumns, spacing: 8) {
                        ForEach(Mood.allCases) { mood in
                            MoodGridItemView(mood: mood, isSelected: presenter.form.mood == mood) {
                                presenter.didSelectMood(mood)
                            }
                        }
                    }
                }

                FormSectionCard(title: "Note", icon: "note.text") {
                    AppTextEditor(text: $presenter.form.note)
                }

                FormSectionCard(title: "Media", icon: "photo.on.rectangle") {
                    VStack(alignment: .leading, spacing: 12) {
                        PhotosPicker(selection: $selectedPhotos, maxSelectionCount: 10, matching: .images) {
                            Label("Add Photos", systemImage: "plus.circle.fill")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(AppColors.accent)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: AppTheme.innerRadius)
                                        .fill(AppColors.accent.opacity(0.08))
                                )
                        }
                        .onChange(of: selectedPhotos) { _, items in
                            Task {
                                for item in items {
                                    guard let data = try? await item.loadTransferable(type: Data.self),
                                          let uiImage = UIImage(data: data),
                                          let jpeg = uiImage.jpegData(compressionQuality: AppConstants.imageCompressionQuality) else { continue }
                                    presenter.addImageData(jpeg)
                                }
                                selectedPhotos = []
                            }
                        }

                        if !presenter.form.imagesData.isEmpty {
                            PhotoGalleryView(imagesData: presenter.form.imagesData, height: 80)
                        }

                        Divider()

                        HStack {
                            if audioRecorder.isRecording {
                                Label("Recording...", systemImage: "mic.fill")
                                    .foregroundStyle(.red)
                                Spacer()
                                Button("Stop") {
                                    if let data = audioRecorder.stopRecording() {
                                        presenter.setAudioData(data)
                                    }
                                }
                                .buttonStyle(PrimaryButtonStyle())
                                .frame(width: 100)
                            } else {
                                Button {
                                    Task { try? await audioRecorder.startRecording() }
                                } label: {
                                    Label("Record Voice", systemImage: "mic.circle.fill")
                                }
                                .buttonStyle(SecondaryButtonStyle())

                                if presenter.form.audioData != nil {
                                    Spacer()
                                    Label("Saved", systemImage: "checkmark.circle.fill")
                                        .foregroundStyle(AppColors.accent)
                                    Button("Remove") { presenter.setAudioData(nil) }
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                }
                            }
                        }
                    }
                }

                FormSectionCard(title: "Options", icon: "slider.horizontal.3") {
                    VStack(spacing: 12) {
                        DatePicker("Date", selection: $presenter.form.date, displayedComponents: .date)
                            .tint(AppColors.accent)
                        Toggle("Add to Favorites", isOn: $presenter.form.isFavorite).tint(AppColors.accent)
                        Toggle("Pin to Top", isOn: $presenter.form.isPinned).tint(AppColors.accent)
                    }
                }

                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Button("Cancel") { presenter.didTapCancel() }
                            .buttonStyle(SecondaryButtonStyle())
                        Button("Save") { presenter.didTapSave() }
                            .buttonStyle(PrimaryButtonStyle(isDisabled: !presenter.canSave || presenter.isSaving))
                            .disabled(!presenter.canSave || presenter.isSaving)
                    }
                    Button("Save as Draft") { presenter.didTapSaveDraft() }
                        .buttonStyle(SecondaryButtonStyle())
                        .disabled(presenter.form.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || presenter.isSaving)
                }
                .padding(.top, 4)
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .appScreenBackground()
        .navigationTitle(presenter.isEditing ? "Edit Memory" : "New Memory")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { presenter.viewDidLoad() }
        .alert("Error", isPresented: Binding(
            get: { presenter.errorMessage != nil },
            set: { if !$0 { presenter.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { presenter.errorMessage = nil }
        } message: {
            Text(presenter.errorMessage ?? "")
        }
    }
}
