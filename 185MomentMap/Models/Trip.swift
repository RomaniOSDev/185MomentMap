import Foundation

struct Trip: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var note: String?
    var startDate: Date?
    var endDate: Date?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        note: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.note = note
        self.startDate = startDate
        self.endDate = endDate
        self.createdAt = createdAt
    }
}
