import Foundation

class HouseholdService {
    private let client = APIClient.shared

    func createHousehold(name: String, address: String?) async throws -> Household {
        let request = CreateHouseholdRequest(name: name, address: address)
        return try await client.request(
            endpoint: "/households",
            method: "POST",
            body: request
        )
    }

    func getHousehold(id: UUID) async throws -> HouseholdDetail {
        return try await client.request(
            endpoint: "/households/\(id)"
        )
    }

    func joinHousehold(id: UUID, inviteCode: String) async throws -> Household {
        let request = JoinHouseholdRequest(inviteCode: inviteCode)
        return try await client.request(
            endpoint: "/households/\(id)/join",
            method: "POST",
            body: request
        )
    }

    func leaveHousehold(id: UUID) async throws {
        let _: EmptyResponse = try await client.request(
            endpoint: "/households/\(id)/leave",
            method: "POST"
        )
    }
}

struct CreateHouseholdRequest: Codable {
    let name: String
    let address: String?
}

struct JoinHouseholdRequest: Codable {
    let inviteCode: String
}

struct HouseholdDetail: Codable {
    let id: UUID
    let name: String
    let address: String?
    let memberIDs: [UUID]
    let members: [User]
    let createdAt: Date
}
