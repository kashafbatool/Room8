import Foundation

// MARK: - Calendar View Model
@MainActor
class CalendarViewModel: ObservableObject {
    @Published var items: [CalendarItem] = []
    @Published var quietHours: [QuietHoursSchedule] = []

    private let storageService = StorageService.shared

    init() {
        load()
    }

    var sortedItems: [CalendarItem] {
        items.sorted { $0.date < $1.date }
    }

    func addItem(
        title: String,
        type: CalendarItem.ItemType,
        date: Date,
        notes: String?,
        amount: Double?
    ) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let trimmedNotes = notes?.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedAmount = (type == .expense) ? amount : nil

        let item = CalendarItem(
            title: trimmedTitle,
            type: type,
            date: date,
            notes: trimmedNotes?.isEmpty == true ? nil : trimmedNotes,
            amount: cleanedAmount
        )

        items.append(item)
        saveItems()
    }

    func deleteItems(at offsets: IndexSet) {
        let sorted = sortedItems
        for index in offsets {
            let id = sorted[index].id
            items.removeAll { $0.id == id }
        }
        saveItems()
    }

    func addQuietHours(
        type: QuietHoursSchedule.ScheduleType,
        startTime: Date,
        endTime: Date,
        daysOfWeek: [Int],
        notes: String?
    ) {
        let trimmedNotes = notes?.trimmingCharacters(in: .whitespacesAndNewlines)
        let schedule = QuietHoursSchedule(
            type: type,
            startTime: startTime,
            endTime: endTime,
            daysOfWeek: daysOfWeek,
            notes: trimmedNotes?.isEmpty == true ? nil : trimmedNotes
        )
        quietHours.append(schedule)
        saveQuietHours()
    }

    func deleteQuietHours(at offsets: IndexSet) {
        quietHours.remove(atOffsets: offsets)
        saveQuietHours()
    }

    private func load() {
        items = storageService.loadCalendarItems()
        quietHours = storageService.loadQuietHours()
    }

    private func saveItems() {
        storageService.saveCalendarItems(items)
    }

    private func saveQuietHours() {
        storageService.saveQuietHours(quietHours)
    }
}
