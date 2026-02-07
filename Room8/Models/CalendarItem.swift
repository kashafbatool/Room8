import Foundation

// MARK: - Calendar Item Model
struct CalendarItem: Identifiable, Codable {
    enum ItemType: String, Codable, CaseIterable {
        case chore = "Chore"
        case event = "Event"
        case expense = "Expense Due"
    }

    let id: UUID
    var title: String
    var type: ItemType
    var date: Date
    var notes: String?
    var amount: Double?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        type: ItemType,
        date: Date,
        notes: String? = nil,
        amount: Double? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.date = date
        self.notes = notes
        self.amount = amount
        self.createdAt = createdAt
    }
}
