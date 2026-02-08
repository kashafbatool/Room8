import Foundation

class ExpenseService {
    private let client = APIClient.shared

    func getExpenses(householdID: UUID) async throws -> [Expense] {
        let response: ExpensesResponse = try await client.request(
            endpoint: "/households/\(householdID)/expenses"
        )
        return response.expenses
    }

    func createExpense(expense: Expense) async throws -> Expense {
        return try await client.request(
            endpoint: "/households/\(expense.householdID)/expenses",
            method: "POST",
            body: expense
        )
    }

    func updateExpense(expense: Expense) async throws -> Expense {
        return try await client.request(
            endpoint: "/expenses/\(expense.id)",
            method: "PUT",
            body: expense
        )
    }

    func deleteExpense(id: UUID) async throws {
        let _: EmptyResponse = try await client.request(
            endpoint: "/expenses/\(id)",
            method: "DELETE"
        )
    }

    func getBalance(householdID: UUID) async throws -> [BalanceInfo] {
        let response: BalanceResponse = try await client.request(
            endpoint: "/households/\(householdID)/expenses/balance"
        )
        return response.balances
    }
}

// Response models
struct ExpensesResponse: Codable {
    let expenses: [Expense]
    let total: Decimal
}

struct BalanceResponse: Codable {
    let balances: [BalanceInfo]
}

struct BalanceInfo: Codable {
    let userID: UUID
    let userName: String
    let owes: Decimal
    let owed: Decimal
    let netBalance: Decimal
}

struct EmptyResponse: Codable {}
