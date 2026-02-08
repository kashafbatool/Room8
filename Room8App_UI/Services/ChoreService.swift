import Foundation

class ChoreService {
    private let client = APIClient.shared

    func getChores(householdID: UUID) async throws -> [Chore] {
        let response: ChoresResponse = try await client.request(
            endpoint: "/households/\(householdID)/chores"
        )
        return response.chores
    }

    func createChore(chore: Chore) async throws -> Chore {
        return try await client.request(
            endpoint: "/households/\(chore.householdID)/chores",
            method: "POST",
            body: chore
        )
    }

    func updateChore(chore: Chore) async throws -> Chore {
        return try await client.request(
            endpoint: "/chores/\(chore.id)",
            method: "PUT",
            body: chore
        )
    }

    func completeChore(id: UUID) async throws -> Chore {
        return try await client.request(
            endpoint: "/chores/\(id)/complete",
            method: "POST"
        )
    }

    func deleteChore(id: UUID) async throws {
        let _: EmptyResponse = try await client.request(
            endpoint: "/chores/\(id)",
            method: "DELETE"
        )
    }
}

struct ChoresResponse: Codable {
    let chores: [Chore]
}
