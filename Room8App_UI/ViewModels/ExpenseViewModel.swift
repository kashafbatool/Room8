import Foundation
import SwiftUI

@MainActor
class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var users: [User] = []
    @Published var currentUser: User
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let expenseService = ExpenseService()
    private let useMockData: Bool

    init(useMockData: Bool = true) {
        self.useMockData = useMockData

        if useMockData {
            self.currentUser = MockData.shared.currentUser
            self.users = MockData.shared.allUsers
            self.expenses = MockData.shared.expenses
        } else {
            // Will be populated from API
            self.currentUser = MockData.shared.currentUser // Temporary
            self.users = []
            self.expenses = []
        }
    }

    // MARK: - Computed Properties

    var sortedExpenses: [Expense] {
        expenses.sorted { $0.date > $1.date }
    }

    var totalExpenses: Decimal {
        expenses.reduce(0) { $0 + $1.amount }
    }

    var expensesByCategory: [(category: ExpenseCategory, total: Decimal)] {
        let grouped = Dictionary(grouping: expenses) { $0.category }
        return grouped.map { (category: $0.key, total: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.total > $1.total }
    }

    // MARK: - Balance Calculations

    func calculateBalances() -> [UserBalance] {
        var balances: [UUID: UserBalance] = [:]

        // Initialize balances for all users
        for user in users {
            balances[user.id] = UserBalance(user: user, totalPaid: 0, totalOwed: 0)
        }

        // Calculate for each expense
        for expense in expenses {
            let splitCount = Decimal(expense.splitBetweenUserIDs.count)
            guard splitCount > 0 else { continue }

            let amountPerPerson = expense.amount / splitCount

            // Add to person who paid
            if var balance = balances[expense.paidByUserID] {
                balance.totalPaid += expense.amount
                balances[expense.paidByUserID] = balance
            }

            // Subtract from everyone who owes
            for userID in expense.splitBetweenUserIDs {
                if var balance = balances[userID] {
                    balance.totalOwed += amountPerPerson
                    balances[userID] = balance
                }
            }
        }

        return Array(balances.values).sorted { $0.netBalance > $1.netBalance }
    }

    func amountOwedTo(user: User) -> Decimal {
        let balances = calculateBalances()
        guard let userBalance = balances.first(where: { $0.user.id == user.id }) else {
            return 0
        }
        return userBalance.netBalance
    }

    // MARK: - CRUD Operations

    func addExpense(_ expense: Expense) async {
        if useMockData {
            expenses.append(expense)
        } else {
            isLoading = true
            do {
                let created = try await expenseService.createExpense(expense: expense)
                expenses.append(created)
            } catch {
                errorMessage = "Failed to add expense: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }

    func updateExpense(_ expense: Expense) async {
        if useMockData {
            if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
                expenses[index] = expense
            }
        } else {
            isLoading = true
            do {
                let updated = try await expenseService.updateExpense(expense: expense)
                if let index = expenses.firstIndex(where: { $0.id == expense.id }) {
                    expenses[index] = updated
                }
            } catch {
                errorMessage = "Failed to update expense: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }

    func deleteExpense(_ expense: Expense) async {
        if useMockData {
            expenses.removeAll { $0.id == expense.id }
        } else {
            isLoading = true
            do {
                try await expenseService.deleteExpense(id: expense.id)
                expenses.removeAll { $0.id == expense.id }
            } catch {
                errorMessage = "Failed to delete expense: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }

    func loadExpenses(householdID: UUID) async {
        guard !useMockData else { return }

        isLoading = true
        do {
            expenses = try await expenseService.getExpenses(householdID: householdID)
        } catch {
            errorMessage = "Failed to load expenses: \(error.localizedDescription)"
        }
        isLoading = false
    }

    // MARK: - Helper Functions

    func userName(for userID: UUID) -> String {
        if let user = users.first(where: { $0.id == userID }) {
            return user.id == currentUser.id ? "You" : user.name
        }
        return "Unknown"
    }

    func user(for userID: UUID) -> User? {
        return users.first { $0.id == userID }
    }
}

// MARK: - Supporting Types

struct UserBalance: Identifiable {
    let user: User
    var totalPaid: Decimal
    var totalOwed: Decimal

    var id: UUID { user.id }

    var netBalance: Decimal {
        totalPaid - totalOwed
    }

    var owesOrOwed: String {
        if netBalance > 0 {
            return "is owed"
        } else if netBalance < 0 {
            return "owes"
        } else {
            return "settled up"
        }
    }
}
