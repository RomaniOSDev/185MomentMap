import Foundation

struct Memory: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var address: String?
    var latitude: Double
    var longitude: Double
    var mood: Mood
    var note: String?
    var imageData: Data?
    var imagesData: [Data]
    var audioData: Data?
    var tags: [MemoryTag]
    var tripId: UUID?
    var date: Date
    var createdAt: Date
    var isFavorite: Bool
    var isPinned: Bool
    var isDraft: Bool

    init(
        id: UUID = UUID(),
        title: String,
        address: String? = nil,
        latitude: Double,
        longitude: Double,
        mood: Mood,
        note: String? = nil,
        imageData: Data? = nil,
        imagesData: [Data] = [],
        audioData: Data? = nil,
        tags: [MemoryTag] = [],
        tripId: UUID? = nil,
        date: Date = Date(),
        createdAt: Date = Date(),
        isFavorite: Bool = false,
        isPinned: Bool = false,
        isDraft: Bool = false
    ) {
        self.id = id
        self.title = title
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.mood = mood
        self.note = note
        self.imageData = imageData
        self.imagesData = imagesData
        self.audioData = audioData
        self.tags = tags
        self.tripId = tripId
        self.date = date
        self.createdAt = createdAt
        self.isFavorite = isFavorite
        self.isPinned = isPinned
        self.isDraft = isDraft
    }

    var allImagesData: [Data] {
        if !imagesData.isEmpty { return imagesData }
        if let imageData { return [imageData] }
        return []
    }

    var primaryImageData: Data? {
        allImagesData.first
    }

    enum CodingKeys: String, CodingKey {
        case id, title, address, latitude, longitude, mood, note
        case imageData, imagesData, audioData, tags, tripId
        case date, createdAt, isFavorite, isPinned, isDraft
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        address = try c.decodeIfPresent(String.self, forKey: .address)
        latitude = try c.decode(Double.self, forKey: .latitude)
        longitude = try c.decode(Double.self, forKey: .longitude)
        mood = try c.decode(Mood.self, forKey: .mood)
        note = try c.decodeIfPresent(String.self, forKey: .note)
        imageData = try c.decodeIfPresent(Data.self, forKey: .imageData)
        imagesData = try c.decodeIfPresent([Data].self, forKey: .imagesData) ?? []
        audioData = try c.decodeIfPresent(Data.self, forKey: .audioData)
        tags = try c.decodeIfPresent([MemoryTag].self, forKey: .tags) ?? []
        tripId = try c.decodeIfPresent(UUID.self, forKey: .tripId)
        date = try c.decode(Date.self, forKey: .date)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        isFavorite = try c.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        isPinned = try c.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        isDraft = try c.decodeIfPresent(Bool.self, forKey: .isDraft) ?? false

        if imagesData.isEmpty, let legacy = imageData {
            imagesData = [legacy]
        }
    }
}
