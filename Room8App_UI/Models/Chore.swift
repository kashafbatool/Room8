import Foundation

struct Chore: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String?
    var assignedToUserID: UUID?
    var dueDate: Date?
    var isCompleted: Bool
    var completedAt: Date?
    var recurrence: ChoreRecurrence?
    var householdID: UUID

    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        assignedToUserID: UUID? = nil,
        dueDate: Date? = nil,
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        recurrence: ChoreRecurrence? = nil,
        householdID: UUID
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.assignedToUserID = assignedToUserID
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.recurrence = recurrence
        self.householdID = householdID
    }
}

enum ChoreRecurrence: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Bi-weekly"
    case monthly = "Monthly"
    case none = "One-time"
}
