import Foundation

struct Household: Identifiable, Codable {
    let id: UUID
    var name: String
    var address: String?
    var memberIDs: [UUID]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        address: String? = nil,
        memberIDs: [UUID] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.memberIDs = memberIDs
        self.createdAt = createdAt
    }
}
