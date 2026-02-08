import Foundation

class AuthService {
    private let client = APIClient.shared

    func register(name: String, email: String, password: String, phoneNumber: String?) async throws -> AuthResponse {
        let request = RegisterRequest(
            name: name,
            email: email,
            password: password,
            phoneNumber: phoneNumber
        )

        let response: AuthResponse = try await client.request(
            endpoint: "/auth/register",
            method: "POST",
            body: request
        )

        client.setAuthToken(response.token)
        return response
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        let request = LoginRequest(email: email, password: password)

        let response: AuthResponse = try await client.request(
            endpoint: "/auth/login",
            method: "POST",
            body: request
        )

        client.setAuthToken(response.token)
        return response
    }

    func logout() {
        client.clearAuthToken()
    }

    func getCurrentUser() async throws -> User {
        return try await client.request(endpoint: "/users/me")
    }

    func updateProfile(name: String?, phoneNumber: String?) async throws -> User {
        let request = UpdateProfileRequest(name: name, phoneNumber: phoneNumber)
        return try await client.request(
            endpoint: "/users/me",
            method: "PUT",
            body: request
        )
    }
}

// Request models
struct RegisterRequest: Codable {
    let name: String
    let email: String
    let password: String
    let phoneNumber: String?
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct UpdateProfileRequest: Codable {
    let name: String?
    let phoneNumber: String?
}

struct AuthResponse: Codable {
    let user: User
    let token: String
}
