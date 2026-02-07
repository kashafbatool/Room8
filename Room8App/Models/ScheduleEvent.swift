import Foundation

struct ScheduleEvent: Identifiable, Codable {
    let id: UUID
    var title: String
    var description: String?
    var startDate: Date
    var endDate: Date
    var createdByUserID: UUID
    var attendeeUserIDs: [UUID]
    var location: String?
    var householdID: UUID

    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        startDate: Date,
        endDate: Date,
        createdByUserID: UUID,
        attendeeUserIDs: [UUID] = [],
        location: String? = nil,
        householdID: UUID
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.createdByUserID = createdByUserID
        self.attendeeUserIDs = attendeeUserIDs
        self.location = location
        self.householdID = householdID
    }
}
