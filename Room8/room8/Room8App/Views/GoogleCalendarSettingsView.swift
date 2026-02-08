import SwiftUI

/// Settings view for Google Calendar integration
struct GoogleCalendarSettingsView: View {
    @StateObject private var authManager = GoogleAuthManager.shared
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isSigningIn = false

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text("Google Calendar")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(Theme.navy)
                        Spacer()
                    }
                    .padding(.horizontal, Theme.pad)
                    .padding(.top, 16)

                    // Status Card
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: authManager.isSignedIn ? "checkmark.circle.fill" : "exclamationmark.circle")
                                .font(.system(size: 50))
                                .foregroundColor(authManager.isSignedIn ? Theme.sage : .gray)

                            Spacer()
                        }

                        Text(authManager.isSignedIn ? "Connected" : "Not Connected")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Theme.navy)

                        if let email = authManager.userEmail {
                            Text(email)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.black.opacity(0.6))
                        }

                        Text(authManager.isSignedIn ?
                            "Your chores are synced with Google Calendar" :
                            "Sign in to sync your chores with Google Calendar")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black.opacity(0.5))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.white)
                    .cornerRadius(Theme.cornerL)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, Theme.pad)

                    // Sign In/Out Button
                    if authManager.isSignedIn {
                        Button {
                            signOut()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.right.square")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Sign Out")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.red)
                            .cornerRadius(Theme.cornerM)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, Theme.pad)
                    } else {
                        Button {
                            signIn()
                        } label: {
                            HStack {
                                if isSigningIn {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "calendar.badge.plus")
                                        .font(.system(size: 18, weight: .semibold))
                                    Text("Sign in with Google")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Theme.sage)
                            .cornerRadius(Theme.cornerM)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, Theme.pad)
                        .disabled(isSigningIn)
                    }

                    // Info Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Features")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Theme.navy)

                        FeatureRow(icon: "calendar", text: "Automatic sync of all chores")
                        FeatureRow(icon: "bell", text: "Smart reminders based on priority")
                        FeatureRow(icon: "arrow.triangle.2.circlepath", text: "Recurring chores supported")
                        FeatureRow(icon: "checkmark.circle", text: "Completion tracking")
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.white)
                    .cornerRadius(Theme.cornerL)
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, Theme.pad)

                    Spacer(minLength: 24)
                }
            }
        }
        .navigationBarHidden(true)
        .alert("Notice", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    private func signIn() {
        isSigningIn = true
        Task {
            do {
                try await authManager.signIn()
                await MainActor.run {
                    isSigningIn = false
                }
            } catch {
                await MainActor.run {
                    isSigningIn = false
                    alertMessage = "Failed to sign in: \(error.localizedDescription)\n\nPlease make sure you've added the GoogleSignIn SDK."
                    showingAlert = true
                }
            }
        }
    }

    private func signOut() {
        authManager.signOut()
        alertMessage = "Successfully signed out of Google Calendar"
        showingAlert = true
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Theme.sage)
                .frame(width: 24)

            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black.opacity(0.7))
        }
    }
}

#Preview {
    NavigationView {
        GoogleCalendarSettingsView()
    }
}
