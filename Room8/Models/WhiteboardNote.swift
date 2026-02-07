import Foundation

// MARK: - Whiteboard Note Model
struct WhiteboardNote: Identifiable, Codable {
    let id: UUID
    var text: String
    var author: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        text: String,
        author: String = "Roommate",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.text = text
        self.author = author
        self.createdAt = createdAt
    }
}
