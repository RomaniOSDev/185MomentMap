import Foundation
import UIKit
import Combine

protocol MemoryCreatePresenterInput: AnyObject {
    func viewDidLoad()
    func didTapSave()
    func didTapSaveDraft()
    func didTapCancel()
    func didSelectMood(_ mood: Mood)
    func didSelectTemplate(_ template: PlaceTemplate)
    func didToggleTag(_ tag: MemoryTag)
}

@MainActor
final class MemoryCreatePresenter: ObservableObject, MemoryCreatePresenterInput {
    @Published var form = MemoryFormData()
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var isEditing: Bool = false
    @Published var trips: [Trip] = []

    var canSave: Bool {
        !form.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && form.mood != nil
    }

    private let interactor: MemoryCreateInteractorInput
    private let router: MemoryCreateRouterInput

    init(interactor: MemoryCreateInteractorInput, router: MemoryCreateRouterInput, editingId: UUID?) {
        self.interactor = interactor
        self.router = router
        if let editingId, let memory = interactor.fetchMemory(id: editingId) {
            form = MemoryFormData(editingMemory: memory)
            isEditing = true
        }
    }

    func viewDidLoad() {
        trips = interactor.loadTrips()
    }

    func didTapSave() { Task { await save(isDraft: false) } }
    func didTapSaveDraft() { Task { await save(isDraft: true) } }
    func didTapCancel() { router.dismiss() }
    func didSelectMood(_ mood: Mood) { form.mood = mood }

    func didSelectTemplate(_ template: PlaceTemplate) {
        form.apply(template: template)
    }

    func didToggleTag(_ tag: MemoryTag) {
        if form.tags.contains(tag) { form.tags.remove(tag) }
        else { form.tags.insert(tag) }
    }

    func addImageData(_ data: Data) {
        form.imagesData.append(data)
    }

    func removeImage(at index: Int) {
        guard form.imagesData.indices.contains(index) else { return }
        form.imagesData.remove(at: index)
    }

    func setAudioData(_ data: Data?) {
        form.audioData = data
    }

    private func save(isDraft: Bool) async {
        let hasCoordinates = parsedCoordinates() != nil
        switch interactor.validateForm(form, hasCoordinates: hasCoordinates, isDraft: isDraft) {
        case .invalid(let message):
            router.showError(message: message)
            return
        case .valid:
            break
        }

        isSaving = true
        defer { isSaving = false }

        let mood = form.mood ?? .happy
        var latitude = 0.0
        var longitude = 0.0
        let trimmedAddress = form.address.trimmingCharacters(in: .whitespacesAndNewlines)

        if !isDraft {
            if !trimmedAddress.isEmpty {
                guard let coords = await interactor.geocodeAddress(trimmedAddress) else {
                    router.showError(message: "Could not find coordinates for this address.")
                    return
                }
                latitude = coords.lat
                longitude = coords.lon
            } else if let coords = parsedCoordinates() {
                latitude = coords.lat
                longitude = coords.lon
            } else {
                router.showError(message: "Please enter an address or coordinates.")
                return
            }
        } else if let coords = parsedCoordinates() {
            latitude = coords.lat
            longitude = coords.lon
        } else if !trimmedAddress.isEmpty, let coords = await interactor.geocodeAddress(trimmedAddress) {
            latitude = coords.lat
            longitude = coords.lon
        }

        let trimmedNote = form.note.trimmingCharacters(in: .whitespacesAndNewlines)
        let title = form.title.trimmingCharacters(in: .whitespacesAndNewlines)

        if let editingId = form.editingId, var existing = interactor.fetchMemory(id: editingId) {
            existing.title = title
            existing.address = trimmedAddress.isEmpty ? nil : trimmedAddress
            existing.latitude = latitude
            existing.longitude = longitude
            existing.mood = mood
            existing.note = trimmedNote.isEmpty ? nil : trimmedNote
            existing.imagesData = form.imagesData
            existing.audioData = form.audioData
            existing.tags = Array(form.tags)
            existing.tripId = form.tripId
            existing.date = form.date
            existing.isFavorite = form.isFavorite
            existing.isPinned = form.isPinned
            existing.isDraft = isDraft
            interactor.updateMemory(existing)
            if isDraft { router.dismiss(); return }
        } else {
            let memory = Memory(
                title: title,
                address: trimmedAddress.isEmpty ? nil : trimmedAddress,
                latitude: latitude,
                longitude: longitude,
                mood: mood,
                note: trimmedNote.isEmpty ? nil : trimmedNote,
                imagesData: form.imagesData,
                audioData: form.audioData,
                tags: Array(form.tags),
                tripId: form.tripId,
                date: form.date,
                isFavorite: form.isFavorite,
                isPinned: form.isPinned,
                isDraft: isDraft
            )
            interactor.saveMemory(memory)
            if isDraft { router.dismiss(); return }
        }

        router.dismissToMap(latitude: latitude, longitude: longitude)
    }

    private func parsedCoordinates() -> (lat: Double, lon: Double)? {
        let latString = form.latitude.trimmingCharacters(in: .whitespacesAndNewlines)
        let lonString = form.longitude.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !latString.isEmpty, !lonString.isEmpty,
              let lat = Double(latString), let lon = Double(lonString) else { return nil }
        return (lat, lon)
    }
}
