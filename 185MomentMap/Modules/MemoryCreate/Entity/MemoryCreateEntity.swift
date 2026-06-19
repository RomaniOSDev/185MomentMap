import Foundation

struct MemoryFormData {
    var title: String = ""
    var address: String = ""
    var latitude: String = ""
    var longitude: String = ""
    var mood: Mood?
    var note: String = ""
    var imagesData: [Data] = []
    var audioData: Data?
    var tags: Set<MemoryTag> = []
    var tripId: UUID?
    var date: Date = Date()
    var isFavorite: Bool = false
    var isPinned: Bool = false
    var editingId: UUID?

    init(editingMemory: Memory? = nil) {
        guard let memory = editingMemory else { return }
        title = memory.title
        address = memory.address ?? ""
        latitude = String(memory.latitude)
        longitude = String(memory.longitude)
        mood = memory.mood
        note = memory.note ?? ""
        imagesData = memory.allImagesData
        audioData = memory.audioData
        tags = Set(memory.tags)
        tripId = memory.tripId
        date = memory.date
        isFavorite = memory.isFavorite
        isPinned = memory.isPinned
        editingId = memory.id
    }

    mutating func apply(template: PlaceTemplate) {
        if title.isEmpty { title = template.defaultTitle }
        mood = template.suggestedMood
        tags = Set(template.suggestedTags)
    }
}

enum ValidationResult {
    case valid
    case invalid(message: String)
}
