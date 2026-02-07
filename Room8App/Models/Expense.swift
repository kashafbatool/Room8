import Foundation

struct Expense: Identifiable, Codable {
    let id: UUID
    var title: String
    var amount: Decimal
    var category: ExpenseCategory
    var paidByUserID: UUID
    var splitBetweenUserIDs: [UUID]
    var date: Date
    var notes: String?
    var receiptImageURL: String?
    var householdID: UUID

    init(
        id: UUID = UUID(),
        title: String,
        amount: Decimal,
        category: ExpenseCategory,
        paidByUserID: UUID,
        splitBetweenUserIDs: [UUID],
        date: Date = Date(),
        notes: String? = nil,
        receiptImageURL: String? = nil,
        householdID: UUID
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.category = category
        self.paidByUserID = paidByUserID
        self.splitBetweenUserIDs = splitBetweenUserIDs
        self.date = date
        self.notes = notes
        self.receiptImageURL = receiptImageURL
        self.householdID = householdID
    }

    // Calculate how much each person owes
    var amountPerPerson: Decimal {
        guard !splitBetweenUserIDs.isEmpty else { return 0 }
        return amount / Decimal(splitBetweenUserIDs.count)
    }
}

enum ExpenseCategory: String, Codable, CaseIterable {
    case groceries = "Groceries"
    case utilities = "Utilities"
    case rent = "Rent"
    case internet = "Internet"
    case cleaning = "Cleaning Supplies"
    case household = "Household Items"
    case other = "Other"
}
