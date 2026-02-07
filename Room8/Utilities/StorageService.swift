import Foundation

// MARK: - Storage Service for Local Persistence
class StorageService {
    static let shared = StorageService()
    
    private let choreKey = "room8_chores"
    private let roommateKey = "room8_roommates"
    private let completionKey = "room8_completions"
    private let whiteboardNotesKey = "room8_whiteboard_notes"
    private let whiteboardDrawingKey = "room8_whiteboard_drawing"
    private let emergencyContactsKey = "room8_emergency_contacts"
    private let campusSafetyKey = "room8_campus_safety_number"
    private let notificationsEnabledKey = "room8_notifications_enabled"
    private let calendarItemsKey = "room8_calendar_items"
    private let quietHoursKey = "room8_quiet_hours"
    private let defaults = UserDefaults.standard
    
    // MARK: - Chore Storage
    
    func saveChores(_ chores: [Chore]) {
        if let encoded = try? JSONEncoder().encode(chores) {
            defaults.set(encoded, forKey: choreKey)
        }
    }
    
    func loadChores() -> [Chore] {
        guard let data = defaults.data(forKey: choreKey),
              let chores = try? JSONDecoder().decode([Chore].self, from: data) else {
            return []
        }
        return chores
    }
    
    // MARK: - Roommate Storage
    
    func saveRoommates(_ roommates: [Roommate]) {
        if let encoded = try? JSONEncoder().encode(roommates) {
            defaults.set(encoded, forKey: roommateKey)
        }
    }
    
    func loadRoommates() -> [Roommate] {
        guard let data = defaults.data(forKey: roommateKey),
              let roommates = try? JSONDecoder().decode([Roommate].self, from: data) else {
            return []
        }
        return roommates
    }
    
    // MARK: - Completion Storage
    
    func saveCompletions(_ completions: [ChoreCompletion]) {
        if let encoded = try? JSONEncoder().encode(completions) {
            defaults.set(encoded, forKey: completionKey)
        }
    }
    
    func loadCompletions() -> [ChoreCompletion] {
        guard let data = defaults.data(forKey: completionKey),
              let completions = try? JSONDecoder().decode([ChoreCompletion].self, from: data) else {
            return []
        }
        return completions
    }

    // MARK: - Whiteboard Storage

    func saveWhiteboardNotes(_ notes: [WhiteboardNote]) {
        if let encoded = try? JSONEncoder().encode(notes) {
            defaults.set(encoded, forKey: whiteboardNotesKey)
        }
    }

    func loadWhiteboardNotes() -> [WhiteboardNote] {
        guard let data = defaults.data(forKey: whiteboardNotesKey),
              let notes = try? JSONDecoder().decode([WhiteboardNote].self, from: data) else {
            return []
        }
        return notes
    }

    func saveWhiteboardDrawingData(_ data: Data) {
        defaults.set(data, forKey: whiteboardDrawingKey)
    }

    func loadWhiteboardDrawingData() -> Data {
        defaults.data(forKey: whiteboardDrawingKey) ?? Data()
    }

    // MARK: - Emergency Contacts Storage

    func saveEmergencyContacts(_ contacts: [EmergencyContact]) {
        if let encoded = try? JSONEncoder().encode(contacts) {
            defaults.set(encoded, forKey: emergencyContactsKey)
        }
    }

    func loadEmergencyContacts() -> [EmergencyContact] {
        guard let data = defaults.data(forKey: emergencyContactsKey),
              let contacts = try? JSONDecoder().decode([EmergencyContact].self, from: data) else {
            return []
        }
        return contacts
    }

    func saveCampusSafetyNumber(_ number: String) {
        defaults.set(number, forKey: campusSafetyKey)
    }

    func loadCampusSafetyNumber() -> String {
        defaults.string(forKey: campusSafetyKey) ?? ""
    }

    func saveNotificationsEnabled(_ enabled: Bool) {
        defaults.set(enabled, forKey: notificationsEnabledKey)
    }

    func loadNotificationsEnabled() -> Bool {
        if defaults.object(forKey: notificationsEnabledKey) == nil {
            return true
        }
        return defaults.bool(forKey: notificationsEnabledKey)
    }

    // MARK: - Calendar Items Storage

    func saveCalendarItems(_ items: [CalendarItem]) {
        if let encoded = try? JSONEncoder().encode(items) {
            defaults.set(encoded, forKey: calendarItemsKey)
        }
    }

    func loadCalendarItems() -> [CalendarItem] {
        guard let data = defaults.data(forKey: calendarItemsKey),
              let items = try? JSONDecoder().decode([CalendarItem].self, from: data) else {
            return []
        }
        return items
    }

    // MARK: - Quiet Hours Storage

    func saveQuietHours(_ schedules: [QuietHoursSchedule]) {
        if let encoded = try? JSONEncoder().encode(schedules) {
            defaults.set(encoded, forKey: quietHoursKey)
        }
    }

    func loadQuietHours() -> [QuietHoursSchedule] {
        guard let data = defaults.data(forKey: quietHoursKey),
              let schedules = try? JSONDecoder().decode([QuietHoursSchedule].self, from: data) else {
            return []
        }
        return schedules
    }
    
    // MARK: - Clear All Data
    
    func clearAllData() {
        defaults.removeObject(forKey: choreKey)
        defaults.removeObject(forKey: roommateKey)
        defaults.removeObject(forKey: completionKey)
        defaults.removeObject(forKey: whiteboardNotesKey)
        defaults.removeObject(forKey: whiteboardDrawingKey)
        defaults.removeObject(forKey: emergencyContactsKey)
        defaults.removeObject(forKey: campusSafetyKey)
        defaults.removeObject(forKey: notificationsEnabledKey)
        defaults.removeObject(forKey: calendarItemsKey)
        defaults.removeObject(forKey: quietHoursKey)
    }
}
