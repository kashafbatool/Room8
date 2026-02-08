# Google Calendar Integration Setup

This guide will help you complete the Google Calendar integration for the Room8 app.

## ✅ What's Already Done

1. ✅ Google Calendar API credentials configured
2. ✅ Authentication manager created
3. ✅ Calendar sync service implemented
4. ✅ Local notification manager for reminders
5. ✅ UI integration in Settings
6. ✅ Auto-sync when creating/updating chores

## 🔧 Required Setup Steps

### 1. Add Swift Package Dependencies

**In Xcode:**

1. Open your project in Xcode
2. Go to **File → Add Package Dependencies...**
3. Add these packages:

#### Google Sign-In SDK
```
https://github.com/google/GoogleSignIn-iOS
```
- Version: 7.0.0 or later
- Select: **GoogleSignIn** and **GoogleSignInSwift**

#### Google API Client (for Calendar API)
```
https://github.com/google/google-api-objectivec-client-for-rest
```
- Version: 3.0.0 or later
- Select: **GoogleAPIClientForREST_Calendar**

### 2. Configure Info.plist

Add these entries to your Info.plist:

**Method 1: Using Xcode UI**
1. Select your project in Xcode
2. Select the "room8" target
3. Go to the **Info** tab
4. Click **+** to add new entries:

| Key | Type | Value |
|-----|------|-------|
| `NSCalendarsUsageDescription` | String | "Room8 needs access to your calendar to sync chores and send reminders" |
| `NSUserNotificationsUsageDescription` | String | "Room8 sends notifications to remind you about upcoming chores" |
| `GIDClientID` | String | `768737784469-1av6ignqfrlbtl13t9i2uqogml48b67g.apps.googleusercontent.com` |
| `CFBundleURLTypes` | Array | (see below) |

**For CFBundleURLTypes**, add:
- Item 0 (Dictionary)
  - `CFBundleURLSchemes` (Array)
    - Item 0: `com.googleusercontent.apps.768737784469-1av6ignqfrlbtl13t9i2uqogml48b67g`

**Method 2: Direct XML (if editing Info.plist as source code)**

```xml
<key>NSCalendarsUsageDescription</key>
<string>Room8 needs access to your calendar to sync chores and send reminders</string>

<key>NSUserNotificationsUsageDescription</key>
<string>Room8 sends notifications to remind you about upcoming chores</string>

<key>GIDClientID</key>
<string>768737784469-1av6ignqfrlbtl13t9i2uqogml48b67g.apps.googleusercontent.com</string>

<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.768737784469-1av6ignqfrlbtl13t9i2uqogml48b67g</string>
        </array>
    </dict>
</array>
```

### 3. Update GoogleAuthManager Implementation

Once GoogleSignIn SDK is added, update `GoogleAuthManager.swift`:

```swift
import GoogleSignIn

// In the signIn() method, replace the TODO with:
func signIn() async throws {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootViewController = windowScene.windows.first?.rootViewController else {
        throw AuthError.noViewController
    }

    guard let clientID = GoogleCalendarConfig.clientID else {
        throw AuthError.missingClientID
    }

    let config = GIDConfiguration(clientID: clientID)
    GIDSignIn.sharedInstance.configuration = config

    // Sign in with Calendar scope
    let result = try await GIDSignIn.sharedInstance.signIn(
        withPresenting: rootViewController,
        hint: nil,
        additionalScopes: ["https://www.googleapis.com/auth/calendar"]
    )

    guard let accessToken = result.user.accessToken.tokenString else {
        throw AuthError.noAccessToken
    }

    let email = result.user.profile?.email ?? ""
    let refreshToken = result.user.refreshToken.tokenString

    saveAuthState(
        accessToken: accessToken,
        refreshToken: refreshToken,
        email: email
    )
}

enum AuthError: Error {
    case noViewController
    case missingClientID
    case noAccessToken
}
```

### 4. Request Notification Permissions

Add this to your app startup (in `Room8App.swift` or a view that appears first):

```swift
Task {
    let granted = try? await NotificationManager.shared.requestAuthorization()
    if granted == true {
        print("✅ Notifications enabled")
    }
}
```

### 5. Verify Calendar Event Files Are Added

Make sure these files are in **Copy Bundle Resources**:
- ✅ `GoogleCalendar.plist`
- ✅ `google-calendar-credentials.json`

**To check:**
1. Select project → "room8" target → **Build Phases**
2. Expand **Copy Bundle Resources**
3. Both files should be listed

## 🎯 How It Works

### Automatic Sync

When you create or update a chore:
1. **Local Notification** is scheduled based on priority
   - Urgent: 1 day before, 1 hour before, at time
   - High: 1 day before, at time
   - Medium/Low: at time only

2. **Google Calendar Event** is created (if signed in)
   - Event includes chore name, description, and time
   - Recurring chores create recurring calendar events
   - Calendar reminders set to 30 min and 1 day before

### Using the Feature

1. Go to **More → Google Calendar**
2. Tap **"Sign in with Google"**
3. Grant calendar permissions
4. Your chores will automatically sync!

## 📱 Testing

1. **Create a test chore**:
   - Go to Calendar tab
   - Tap **+** button
   - Create a chore for tomorrow
   - Set priority to "Urgent"

2. **Verify notifications**:
   - Check Settings → Notifications → Room8
   - Should see scheduled notifications

3. **Check Google Calendar**:
   - Sign in to Google Calendar integration
   - Open your Google Calendar
   - Should see the chore as an event

## 🐛 Troubleshooting

### "GoogleSignIn SDK not found"
- Make sure you've added the Swift Package dependencies
- Clean build folder: Xcode → Product → Clean Build Folder
- Restart Xcode

### Notifications not appearing
- Check Settings → Notifications → Room8 (on your device)
- Make sure notifications are enabled
- Try deleting and recreating a chore

### Calendar sync not working
- Verify you're signed in (More → Google Calendar)
- Check that API credentials are in Copy Bundle Resources
- Look for errors in Xcode console

## 📝 Files Created

- `GoogleAuthManager.swift` - Handles Google Sign-In
- `GoogleCalendarService.swift` - Syncs chores to calendar
- `GoogleCalendarConfig.swift` - Loads API credentials
- `NotificationManager.swift` - Schedules local notifications
- `GoogleCalendarSettingsView.swift` - Settings UI
- Updated `ChoreScheduleViewModel.swift` - Auto-sync integration
- Updated `Chore.swift` - Added `calendarEventID` field

## 🎉 Ready to Test!

Once you've completed steps 1-4 above, build and run your app. The integration will be fully functional!
