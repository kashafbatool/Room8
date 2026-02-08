import Foundation

/// Configuration for Google Calendar API integration
///
/// The credential files are stored locally and excluded from git via .gitignore
/// Files location:
/// - GoogleCalendar.plist (iOS client configuration)
/// - google-calendar-credentials.json (OAuth credentials)
struct GoogleCalendarConfig {

    // MARK: - Client Configuration (from GoogleCalendar.plist)
    static var clientID: String? {
        guard let path = Bundle.main.path(forResource: "GoogleCalendar", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientID = plist["CLIENT_ID"] as? String else {
            print("⚠️ GoogleCalendar.plist not found or CLIENT_ID missing")
            return nil
        }
        return clientID
    }

    static var reversedClientID: String? {
        guard let path = Bundle.main.path(forResource: "GoogleCalendar", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let reversedClientID = plist["REVERSED_CLIENT_ID"] as? String else {
            print("⚠️ GoogleCalendar.plist not found or REVERSED_CLIENT_ID missing")
            return nil
        }
        return reversedClientID
    }

    // MARK: - OAuth Credentials (from google-calendar-credentials.json)
    struct OAuthCredentials: Codable {
        let web: WebCredentials

        struct WebCredentials: Codable {
            let clientId: String
            let projectId: String
            let authUri: String
            let tokenUri: String
            let authProviderX509CertUrl: String
            let clientSecret: String
            let redirectUris: [String]

            enum CodingKeys: String, CodingKey {
                case clientId = "client_id"
                case projectId = "project_id"
                case authUri = "auth_uri"
                case tokenUri = "token_uri"
                case authProviderX509CertUrl = "auth_provider_x509_cert_url"
                case clientSecret = "client_secret"
                case redirectUris = "redirect_uris"
            }
        }
    }

    static var oauthCredentials: OAuthCredentials? {
        guard let path = Bundle.main.path(forResource: "google-calendar-credentials", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let credentials = try? JSONDecoder().decode(OAuthCredentials.self, from: data) else {
            print("⚠️ google-calendar-credentials.json not found or invalid")
            return nil
        }
        return credentials
    }
}
