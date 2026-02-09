# Room8 - Roommate Management App

A comprehensive iOS app designed to help roommates manage shared living spaces, expenses, chores, and communication.

## Features

### 🏠 Home Dashboard
- Quick overview of upcoming activities and chores
- Calendar integration for easy scheduling
- Activity feed showing recent household updates

### 💰 Money Management
- **Expense Tracking**: Split bills and track shared expenses
- **Balance View**: See who owes what at a glance
- **Shopping List**: Collaborative grocery and household shopping lists
- Contributors: Fatma, Lorraine, Efrata

### 📅 Calendar & Activities
- Visual calendar view for all household activities
- Create and manage recurring activities
- Set priority levels (Urgent, High, Medium, Low)
- Assign activities to specific roommates
- Frequency options: Daily, Weekly, Bi-weekly, Monthly, As Needed

### ✅ Chores Management
- Task assignment and tracking
- Completion history
- Priority-based organization
- Estimated time tracking
- Local notifications for upcoming chores

### 👥 Roommates
- Manage household members
- Track individual contributions
- Assign tasks and responsibilities

### 📝 Fridge Board
- Digital sticky notes for quick messages
- Photo sharing
- Birthday reminders
- Drawing canvas (coming soon)

### 🎨 Whiteboard
- Shared note-taking space
- Collaborative messaging
- Date-stamped entries

### 🔔 Notifications
- Priority-based notification scheduling:
  - **Urgent**: 1 day before, 1 hour before, at time
  - **High**: 1 day before, at time
  - **Medium/Low**: at time only
- Local notifications for all chore reminders

### 🔐 Authentication
- Email/password sign up
- Social sign-in integration (Facebook, Google, Apple)
- Secure user sessions

## Tech Stack

- **Framework**: SwiftUI
- **iOS Version**: iOS 15.0+
- **Architecture**: MVVM (Model-View-ViewModel)
- **Data Persistence**: UserDefaults + JSON file storage
- **Notifications**: UserNotifications framework

## Project Structure

\`\`\`
Room8/
├── Room8App/
│   ├── Models/           # Data models (Chore, Expense, Roommate, etc.)
│   ├── ViewModels/       # Business logic and state management
│   ├── Views/            # SwiftUI views
│   ├── Services/         # Storage, notifications, calendar services
│   ├── Utilities/        # Helper functions and extensions
│   └── Room8App.swift    # App entry point
\`\`\`

## Key Components

### Models
- \`Chore\`: Task management with frequency, priority, and assignments
- \`Expense\`: Shared expense tracking with split calculations
- \`Roommate\`: User profiles and information
- \`ChoreCompletion\`: History tracking for completed tasks
- \`FridgeNote\`: Sticky note data model

### Services
- \`StorageService\`: Persistent data management
- \`NotificationManager\`: Local notification scheduling
- \`GoogleCalendarService\`: Calendar event synchronization
- \`GoogleAuthManager\`: OAuth authentication

### ViewModels
- \`ChoreScheduleViewModel\`: Chore and roommate management
- \`ExpenseViewModel\`: Expense tracking and calculations
- \`AuthViewModel\`: User authentication state
- \`WhiteboardViewModel\`: Note management
- \`FridgeViewModel\`: Fridge board content

## Design System

### Color Theme
- **Navy**: Primary text and headers
- **Sage**: Primary actions and accents
- **Sand**: Background highlights
- **Terracotta**: Secondary accents
- **White**: Content backgrounds

### Typography
- System fonts with semantic sizing
- Weight variations for hierarchy
- Consistent spacing and padding

## Setup Instructions

1. Clone the repository
2. Open \`room8.xcodeproj\` in Xcode
3. Select your development team in project settings
4. Build and run on simulator or device

## Google Calendar Integration (Optional)

The app includes infrastructure for Google Calendar integration. To enable:

1. Add Swift Package Dependencies in Xcode
2. Configure Info.plist with calendar permissions
3. Implement OAuth flow in \`GoogleAuthManager\`
4. See \`GOOGLE_CALENDAR_SETUP.md\` for detailed instructions

**Note**: Google Calendar features are currently disabled for demo purposes.

## Data Storage

The app uses a local file-based storage system:
- Chores: \`chores.json\`
- Roommates: \`roommates.json\`
- Completions: \`completions.json\`
- Expenses: \`expenses.json\`

All data is stored in the app's Documents directory and persists between sessions.

## Notification Permissions

The app requests notification permissions to send reminders for:
- Upcoming chores based on priority
- Scheduled activities
- Important household events

## Future Enhancements

- [ ] Drawing canvas implementation for Fridge Board
- [ ] Google Calendar full integration
- [ ] Real-time sync between devices
- [ ] Cloud backup and restore
- [ ] Receipt scanning for expenses
- [ ] Advanced analytics and insights
- [ ] In-app messaging

## Contributing

This is a student project for roommate management. Current development team:
- Kashaf Batool
- Additional contributors welcome!

## License

© 2026 Room8 Development Team. All rights reserved.

## Support

For issues or questions, please create an issue in the repository.

---

**Version**: 1.0.0  
**Last Updated**: February 2026  
**Platform**: iOS 15.0+
