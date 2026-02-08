import Foundation

// MARK: - Chore Model
struct Chore: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var frequency: ChoreFrequency
    var estimatedMinutes: Int
    var priority: ChorePriority
    var assignedTo: UUID?
    var createdDate: Date
    var lastCompletedDate: Date?
    var scheduledDate: Date
    var isCompleted: Bool
    var calendarEventID: String? // Google Calendar event ID for syncing

    init(
        id: UUID = UUID(),
        name: String,
        description: String = "",
        frequency: ChoreFrequency = .weekly,
        estimatedMinutes: Int = 30,
        priority: ChorePriority = .medium,
        assignedTo: UUID? = nil,
        createdDate: Date = Date(),
        lastCompletedDate: Date? = nil,
        scheduledDate: Date = Date(),
        isCompleted: Bool = false,
        calendarEventID: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.frequency = frequency
        self.estimatedMinutes = estimatedMinutes
        self.priority = priority
        self.assignedTo = assignedTo
        self.createdDate = createdDate
        self.lastCompletedDate = lastCompletedDate
        self.scheduledDate = scheduledDate
        self.isCompleted = isCompleted
        self.calendarEventID = calendarEventID
    }
}

// MARK: - Chore Frequency
enum ChoreFrequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Bi-weekly"
    case monthly = "Monthly"
    case asNeeded = "As Needed"
    
    var days: Int? {
        switch self {
        case .daily:
            return 1
        case .weekly:
            return 7
        case .biweekly:
            return 14
        case .monthly:
            return 30
        case .asNeeded:
            return nil
        }
    }
}

// MARK: - Chore Priority
enum ChorePriority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"
}
