import Foundation
import UserNotifications

/// Manages local notifications for chore reminders
///
/// This manager handles:
/// - Requesting notification permissions
/// - Scheduling notifications for chores
/// - Canceling notifications when chores are completed or deleted
class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    // MARK: - Permission

    /// Request notification permission from the user
    func requestAuthorization() async throws -> Bool {
        let center = UNUserNotificationCenter.current()

        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        let granted = try await center.requestAuthorization(options: options)

        if granted {
            print("✅ Notification permission granted")
        } else {
            print("⚠️ Notification permission denied")
        }

        return granted
    }

    /// Check if notifications are authorized
    func checkAuthorizationStatus() async -> UNAuthorizationStatus {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Schedule Notifications

    /// Schedule a notification for a chore
    func scheduleChoreNotification(for chore: Chore) async throws {
        let center = UNUserNotificationCenter.current()

        // Cancel any existing notification for this chore
        await cancelChoreNotification(for: chore.id.uuidString)

        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Chore Due: \(chore.name)"
        content.body = chore.description.isEmpty ?
            "Time to complete your chore!" :
            chore.description
        content.sound = .default
        content.badge = 1

        // Add chore details to user info
        content.userInfo = [
            "choreID": chore.id.uuidString,
            "choreName": chore.name
        ]

        // Schedule notifications based on priority
        let notificationTimes = getNotificationTimes(for: chore)

        for (index, time) in notificationTimes.enumerated() {
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: time),
                repeats: false
            )

            let identifier = "\(chore.id.uuidString)-\(index)"
            let request = UNNotificationRequest(
                identifier: identifier,
                content: content,
                trigger: trigger
            )

            try await center.add(request)
        }

        print("✅ Scheduled \(notificationTimes.count) notification(s) for chore: \(chore.name)")
    }

    /// Cancel notification for a specific chore
    func cancelChoreNotification(for choreID: String) async {
        let center = UNUserNotificationCenter.current()

        // Get all pending notifications
        let requests = await center.pendingNotificationRequests()

        // Find identifiers that start with the chore ID
        let identifiersToCancel = requests
            .filter { $0.identifier.starts(with: choreID) }
            .map { $0.identifier }

        // Cancel them
        center.removePendingNotificationRequests(withIdentifiers: identifiersToCancel)

        if !identifiersToCancel.isEmpty {
            print("✅ Canceled \(identifiersToCancel.count) notification(s) for chore ID: \(choreID)")
        }
    }

    /// Cancel all chore notifications
    func cancelAllNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        print("✅ Canceled all notifications")
    }

    // MARK: - Private Helpers

    private func getNotificationTimes(for chore: Chore) -> [Date] {
        var times: [Date] = []
        let scheduledDate = chore.scheduledDate

        switch chore.priority {
        case .urgent:
            // Urgent: 1 day before, 1 hour before, at time
            if let oneDayBefore = Calendar.current.date(byAdding: .day, value: -1, to: scheduledDate) {
                times.append(oneDayBefore)
            }
            if let oneHourBefore = Calendar.current.date(byAdding: .hour, value: -1, to: scheduledDate) {
                times.append(oneHourBefore)
            }
            times.append(scheduledDate)

        case .high:
            // High: 1 day before, at time
            if let oneDayBefore = Calendar.current.date(byAdding: .day, value: -1, to: scheduledDate) {
                times.append(oneDayBefore)
            }
            times.append(scheduledDate)

        case .medium:
            // Medium: at time only
            times.append(scheduledDate)

        case .low:
            // Low: at time only
            times.append(scheduledDate)
        }

        // Filter out past times
        return times.filter { $0 > Date() }
    }
}
