import Foundation
import SwiftUI

/// Manages Google Sign-In and authentication state
///
/// This manager handles:
/// - Google OAuth sign-in flow
/// - Storing and retrieving access tokens
/// - Checking authentication status
class GoogleAuthManager: ObservableObject {
    static let shared = GoogleAuthManager()

    @Published var isSignedIn: Bool = false
    @Published var userEmail: String?

    private let accessTokenKey = "googleAccessToken"
    private let refreshTokenKey = "googleRefreshToken"
    private let userEmailKey = "googleUserEmail"

    private init() {
        // Check if user is already signed in
        loadAuthState()
    }

    // MARK: - Public Methods

    /// Sign in with Google Calendar access
    func signIn() async throws {
        // TODO: Implement Google Sign-In flow
        // This will be implemented once GoogleSignIn SDK is added
        print("⚠️ Google Sign-In not yet implemented - add GoogleSignIn SDK")
    }

    /// Sign out and clear all stored credentials
    func signOut() {
        UserDefaults.standard.removeObject(forKey: accessTokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
        UserDefaults.standard.removeObject(forKey: userEmailKey)

        DispatchQueue.main.async {
            self.isSignedIn = false
            self.userEmail = nil
        }
    }

    /// Get the current access token
    var accessToken: String? {
        return UserDefaults.standard.string(forKey: accessTokenKey)
    }

    // MARK: - Private Methods

    private func loadAuthState() {
        if let email = UserDefaults.standard.string(forKey: userEmailKey),
           let _ = UserDefaults.standard.string(forKey: accessTokenKey) {
            DispatchQueue.main.async {
                self.isSignedIn = true
                self.userEmail = email
            }
        }
    }

    private func saveAuthState(accessToken: String, refreshToken: String?, email: String) {
        UserDefaults.standard.set(accessToken, forKey: accessTokenKey)
        if let refreshToken = refreshToken {
            UserDefaults.standard.set(refreshToken, forKey: refreshTokenKey)
        }
        UserDefaults.standard.set(email, forKey: userEmailKey)

        DispatchQueue.main.async {
            self.isSignedIn = true
            self.userEmail = email
        }
    }
}
