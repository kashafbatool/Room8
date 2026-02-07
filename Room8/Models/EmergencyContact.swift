import Foundation

// MARK: - Emergency Contact Model
struct EmergencyContact: Identifiable, Codable {
    let id: UUID
    var name: String
    var relationship: String
    var phoneNumber: String
    var notes: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        relationship: String,
        phoneNumber: String,
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.relationship = relationship
        self.phoneNumber = phoneNumber
        self.notes = notes
        self.createdAt = createdAt
    }
}
