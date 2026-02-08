import Foundation

// MARK: - Chore Schedule Manager ViewModel
@MainActor
class ChoreScheduleViewModel: ObservableObject {
    @Published var chores: [Chore] = []
    @Published var roommates: [Roommate] = []
    @Published var completions: [ChoreCompletion] = []
    @Published var selectedChore: Chore?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isCalendarSynced = false
    @Published var calendarsyncInProgress = false
    
    private let storageService = StorageService.shared
    private let calendarService: GoogleCalendarServiceProtocol = GoogleCalendarService.shared
    
    init() {
        loadData()
    }
    
    // MARK: - Chore Management

    func addChore(_ chore: Chore) {
        chores.append(chore)
        saveChoresToStorage()

        // Sync to calendar and schedule notification
        Task {
            await syncChoreToCalendarAndNotifications(chore)
        }
    }

    func updateChore(_ chore: Chore) {
        if let index = chores.firstIndex(where: { $0.id == chore.id }) {
            chores[index] = chore
            saveChoresToStorage()

            // Re-sync to calendar and update notifications
            Task {
                await syncChoreToCalendarAndNotifications(chore)
            }
        }
    }

    func deleteChore(_ choreId: UUID) {
        // Find the chore before deleting to cancel notifications and calendar event
        if let chore = chores.first(where: { $0.id == choreId }) {
            Task {
                // Cancel notifications
                await NotificationManager.shared.cancelChoreNotification(for: choreId.uuidString)

                // Delete from Google Calendar if event ID exists
                if let eventID = chore.calendarEventID {
                    try? await GoogleCalendarService.shared.deleteChoreEvent(eventID)
                }
            }
        }

        chores.removeAll { $0.id == choreId }
        saveChoresToStorage()
    }

    // MARK: - Private Helpers

    private func syncChoreToCalendarAndNotifications(_ chore: Chore) async {
        // Schedule local notification
        do {
            try await NotificationManager.shared.scheduleChoreNotification(for: chore)
        } catch {
            print("⚠️ Failed to schedule notification: \(error)")
        }

        // Sync to Google Calendar if signed in
        if GoogleAuthManager.shared.isSignedIn {
            do {
                if let eventID = try await GoogleCalendarService.shared.syncChore(chore) {
                    // Update chore with calendar event ID
                    if let index = chores.firstIndex(where: { $0.id == chore.id }) {
                        chores[index].calendarEventID = eventID
                        saveChoresToStorage()
                    }
                }
            } catch {
                print("⚠️ Failed to sync to Google Calendar: \(error)")
            }
        }
    }

    func toggleChoreCompletion(_ chore: Chore) {
        if let index = chores.firstIndex(where: { $0.id == chore.id }) {
            chores[index].isCompleted.toggle()
            if chores[index].isCompleted {
                chores[index].lastCompletedDate = Date()
            }
            saveChoresToStorage()
        }
    }

    // MARK: - Roommate Management
    
    func addRoommate(_ roommate: Roommate) {
        roommates.append(roommate)
        saveRoommatesToStorage()
    }
    
    func updateRoommate(_ roommate: Roommate) {
        if let index = roommates.firstIndex(where: { $0.id == roommate.id }) {
            roommates[index] = roommate
            saveRoommatesToStorage()
        }
    }
    
    func deleteRoommate(_ roommateId: UUID) {
        roommates.removeAll { $0.id == roommateId }
        // Unassign any chores from this roommate
        chores = chores.map { chore in
            var updatedChore = chore
            if updatedChore.assignedTo == roommateId {
                updatedChore.assignedTo = nil
            }
            return updatedChore
        }
        saveRoommatesToStorage()
        saveChoresToStorage()
    }
    
    // MARK: - Chore Assignment
    
    func assignChore(_ choreId: UUID, to roommateId: UUID) {
        if let index = chores.firstIndex(where: { $0.id == choreId }) {
            chores[index].assignedTo = roommateId
            saveChoresToStorage()
        }
    }
    
    func unassignChore(_ choreId: UUID) {
        if let index = chores.firstIndex(where: { $0.id == choreId }) {
            chores[index].assignedTo = nil
            saveChoresToStorage()
        }
    }
    
    // MARK: - Chore Completion
    
    func completeChore(_ choreId: UUID, by roommateId: UUID, notes: String? = nil) {
        let completion = ChoreCompletion(choreId: choreId, completedBy: roommateId, notes: notes)
        completions.append(completion)
        
        // Update lastCompletedDate
        if let index = chores.firstIndex(where: { $0.id == choreId }) {
            chores[index].lastCompletedDate = Date()
        }
        
        save()
    }
    
    // MARK: - Chore Status & Filtering
    
    func getChoresAssignedTo(_ roommateId: UUID) -> [Chore] {
        chores.filter { $0.assignedTo == roommateId }
    }
    
    func getOverdueChores() -> [Chore] {
        chores.filter { isChoreOverdue($0) }
    }
    
    func getChoresDueToday() -> [Chore] {
        chores.filter { isChoresDueToday($0) }
    }
    
    private func isChoreOverdue(_ chore: Chore) -> Bool {
        guard let lastCompleted = chore.lastCompletedDate, let days = chore.frequency.days else {
            // New chore or "as needed" frequency
            return chore.createdDate.addingTimeInterval(86400) < Date()
        }
        
        let intervalSinceCompletion = Date().timeIntervalSince(lastCompleted)
        let secondsInDay = Double(days) * 86400
        
        return intervalSinceCompletion > secondsInDay
    }
    
    private func isChoresDueToday(_ chore: Chore) -> Bool {
        guard let days = chore.frequency.days else { return false }
        
        let lastDate = chore.lastCompletedDate ?? chore.createdDate
        let nextDueDate = lastDate.addingTimeInterval(Double(days) * 86400)
        
        let calendar = Calendar.current
        return calendar.isDateInToday(nextDueDate)
    }
    
    func getRoommateForChore(_ chore: Chore) -> Roommate? {
        guard let roommateId = chore.assignedTo else { return nil }
        return roommates.first { $0.id == roommateId }
    }
    
    // MARK: - Google Calendar Sync
    
    func authorizeGoogleCalendar(completion: @escaping (Bool) -> Void) {
        calendarsyncInProgress = true
        calendarService.authorize { [weak self] success, error in
            DispatchQueue.main.async {
                self?.calendarsyncInProgress = false
                if success {
                    self?.errorMessage = nil
                    completion(true)
                } else {
                    self?.errorMessage = error?.localizedDescription ?? "Failed to authorize Google Calendar"
                    completion(false)
                }
            }
        }
    }
    
    func isGoogleCalendarAuthorized() -> Bool {
        return calendarService.isAuthorized()
    }
    
    func syncChoresToCalendar(completion: @escaping (Bool) -> Void) {
        guard isGoogleCalendarAuthorized() else {
            errorMessage = "Not authorized with Google Calendar. Please authorize first."
            completion(false)
            return
        }
        
        calendarsyncInProgress = true
        let calendarEvents = CalendarConverter.choresToCalendarEvents(
            chores: chores,
            roommates: roommates
        )
        
        var syncedCount = 0
        let totalCount = calendarEvents.count
        
        guard totalCount > 0 else {
            calendarsyncInProgress = false
            isCalendarSynced = true
            completion(true)
            return
        }
        
        for event in calendarEvents {
            calendarService.createEvent(event) { [weak self] success, eventId, error in
                DispatchQueue.main.async {
                    if success, let _ = eventId {
                        syncedCount += 1
                        // Optionally: Store the calendar event ID with the chore
                    } else if let error = error {
                        self?.errorMessage = "Failed to sync chore: \(error.localizedDescription)"
                    }
                    
                    if syncedCount == totalCount {
                        self?.calendarsyncInProgress = false
                        self?.isCalendarSynced = true
                        completion(true)
                    }
                }
            }
        }
    }
    
    func updateChoreInCalendar(_ chore: Chore, completion: @escaping (Bool) -> Void) {
        let roommate = getRoommateForChore(chore)
        let calendarEvent = CalendarConverter.choreToCalendarEvent(chore: chore, roommate: roommate)
        
        // In a real implementation, you would store the Google Calendar event ID
        // For now, we'll attempt to update using the chore ID as a reference
        let eventId = "room8_\(chore.id.uuidString)"
        
        calendarService.updateEvent(eventId, calendarEvent) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.errorMessage = nil
                } else {
                    self?.errorMessage = error?.localizedDescription ?? "Failed to update calendar event"
                }
                completion(success)
            }
        }
    }
    
    func removeChoreFromCalendar(_ choreId: UUID, completion: @escaping (Bool) -> Void) {
        let eventId = "room8_\(choreId.uuidString)"
        
        calendarService.deleteEvent(eventId) { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.errorMessage = nil
                } else {
                    self?.errorMessage = error?.localizedDescription ?? "Failed to remove calendar event"
                }
                completion(success)
            }
        }
    }
    
    func markChoreCompleteAndUpdateCalendar(_ choreId: UUID, by roommateId: UUID, notes: String? = nil) {
        completeChore(choreId, by: roommateId, notes: notes)
        
        // Update the calendar event to mark as complete
        if let chore = chores.first(where: { $0.id == choreId }) {
            updateChoreInCalendar(chore) { _ in
                // Calendar update completed
            }
        }
    }
    
    // MARK: - Storage
    
    private func loadData() {
        isLoading = true
        chores = storageService.loadChores()
        roommates = storageService.loadRoommates()
        completions = storageService.loadCompletions()
        isLoading = false
    }
    
    private func save() {
        saveChoresToStorage()
        saveCompletionsToStorage()
    }
    
    private func saveChoresToStorage() {
        storageService.saveChores(chores)
    }
    
    private func saveRoommatesToStorage() {
        storageService.saveRoommates(roommates)
    }
    
    private func saveCompletionsToStorage() {
        storageService.saveCompletions(completions)
    }
}
