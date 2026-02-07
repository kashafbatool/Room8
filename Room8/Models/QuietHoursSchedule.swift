import Foundation

// MARK: - Quiet Hours / Sleep Schedule Model
struct QuietHoursSchedule: Identifiable, Codable {
    enum ScheduleType: String, Codable, CaseIterable {
        case quiet = "Quiet Hours"
        case sleep = "Sleep Schedule"
    }

    let id: UUID
    var type: ScheduleType
    var startTime: Date
    var endTime: Date
    var daysOfWeek: [Int]
    var notes: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        type: ScheduleType,
        startTime: Date,
        endTime: Date,
        daysOfWeek: [Int],
        notes: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.startTime = startTime
        self.endTime = endTime
        self.daysOfWeek = daysOfWeek.sorted()
        self.notes = notes
        self.createdAt = createdAt
    }
}
