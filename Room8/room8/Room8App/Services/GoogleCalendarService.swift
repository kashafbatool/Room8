import Foundation

/// Service for syncing chores with Google Calendar
///
/// This service handles:
/// - Creating calendar events for chores
/// - Updating existing events
/// - Deleting events when chores are deleted
/// - Setting up reminders for chore notifications
class GoogleCalendarService {
    static let shared = GoogleCalendarService()

    private let calendarID = "primary" // User's primary calendar
    private let baseURL = "https://www.googleapis.com/calendar/v3"

    private init() {}

    // MARK: - Public Methods

    /// Sync a chore to Google Calendar
    func syncChore(_ chore: Chore) async throws -> String? {
        guard let accessToken = GoogleAuthManager.shared.accessToken else {
            print("⚠️ No access token available")
            return nil
        }

        // Create calendar event from chore
        let event = createCalendarEvent(from: chore)

        // Check if chore already has a calendar event ID
        if let eventID = chore.calendarEventID {
            // Update existing event
            return try await updateEvent(eventID, event: event, accessToken: accessToken)
        } else {
            // Create new event
            return try await createEvent(event, accessToken: accessToken)
        }
    }

    /// Delete a chore's calendar event
    func deleteChoreEvent(_ eventID: String) async throws {
        guard let accessToken = GoogleAuthManager.shared.accessToken else {
            print("⚠️ No access token available")
            return
        }

        let urlString = "\(baseURL)/calendars/\(calendarID)/events/\(eventID)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw CalendarSyncError.deleteFailed
        }
    }

    // MARK: - Private Methods

    private func createCalendarEvent(from chore: Chore) -> [String: Any] {
        var event: [String: Any] = [
            "summary": chore.name,
            "description": chore.description,
            "start": [
                "dateTime": ISO8601DateFormatter().string(from: chore.scheduledDate),
                "timeZone": TimeZone.current.identifier
            ],
            "end": [
                "dateTime": ISO8601DateFormatter().string(from: chore.scheduledDate.addingTimeInterval(TimeInterval(chore.estimatedMinutes * 60))),
                "timeZone": TimeZone.current.identifier
            ],
            "reminders": [
                "useDefault": false,
                "overrides": [
                    ["method": "popup", "minutes": 30],  // 30 min before
                    ["method": "popup", "minutes": 1440] // 1 day before
                ]
            ]
        ]

        // Add recurrence if chore is recurring
        if let frequencyDays = chore.frequency.days {
            var recurrenceRule = "RRULE:FREQ="
            switch chore.frequency {
            case .daily:
                recurrenceRule += "DAILY"
            case .weekly:
                recurrenceRule += "WEEKLY"
            case .biweekly:
                recurrenceRule += "WEEKLY;INTERVAL=2"
            case .monthly:
                recurrenceRule += "MONTHLY"
            case .asNeeded:
                break // No recurrence for as-needed chores
            }

            if chore.frequency != .asNeeded {
                event["recurrence"] = [recurrenceRule]
            }
        }

        return event
    }

    private func createEvent(_ event: [String: Any], accessToken: String) async throws -> String {
        let urlString = "\(baseURL)/calendars/\(calendarID)/events"
        guard let url = URL(string: urlString) else {
            throw CalendarSyncError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: event)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw CalendarSyncError.createFailed
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let eventID = json?["id"] as? String else {
            throw CalendarSyncError.missingEventID
        }

        return eventID
    }

    private func updateEvent(_ eventID: String, event: [String: Any], accessToken: String) async throws -> String {
        let urlString = "\(baseURL)/calendars/\(calendarID)/events/\(eventID)"
        guard let url = URL(string: urlString) else {
            throw CalendarSyncError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: event)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw CalendarSyncError.updateFailed
        }

        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let updatedID = json?["id"] as? String else {
            throw CalendarSyncError.missingEventID
        }

        return updatedID
    }
}

// MARK: - Errors

enum CalendarSyncError: Error, LocalizedError {
    case invalidURL
    case createFailed
    case updateFailed
    case deleteFailed
    case missingEventID

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid calendar API URL"
        case .createFailed:
            return "Failed to create calendar event"
        case .updateFailed:
            return "Failed to update calendar event"
        case .deleteFailed:
            return "Failed to delete calendar event"
        case .missingEventID:
            return "Calendar event ID not found in response"
        }
    }
}

