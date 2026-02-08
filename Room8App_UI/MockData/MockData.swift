import Foundation

class MockData {
    static let shared = MockData()

    private init() {}

    // MARK: - Mock Users
    let currentUser = User(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        name: "You",
        email: "you@room8.com",
        phoneNumber: "+1234567890",
        householdID: UUID(uuidString: "00000000-0000-0000-0000-000000000100")!
    )

    let sarah = User(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        name: "Sarah",
        email: "sarah@room8.com",
        phoneNumber: "+1234567891",
        householdID: UUID(uuidString: "00000000-0000-0000-0000-000000000100")!
    )

    let mike = User(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
        name: "Mike",
        email: "mike@room8.com",
        phoneNumber: "+1234567892",
        householdID: UUID(uuidString: "00000000-0000-0000-0000-000000000100")!
    )

    let emma = User(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
        name: "Emma",
        email: "emma@room8.com",
        phoneNumber: "+1234567893",
        householdID: UUID(uuidString: "00000000-0000-0000-0000-000000000100")!
    )

    lazy var allUsers: [User] = [currentUser, sarah, mike, emma]

    // MARK: - Mock Household
    lazy var household = Household(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000100")!,
        name: "Apartment 4B",
        address: "123 Main Street, Apt 4B",
        memberIDs: allUsers.map { $0.id },
        createdAt: Calendar.current.date(byAdding: .month, value: -3, to: Date())!
    )

    // MARK: - Mock Expenses
    lazy var expenses: [Expense] = [
        Expense(
            id: UUID(),
            title: "Costco Run",
            amount: 156.43,
            category: .groceries,
            paidByUserID: currentUser.id,
            splitBetweenUserIDs: allUsers.map { $0.id },
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            notes: "Weekly groceries - milk, eggs, bread, etc.",
            householdID: household.id
        ),
        Expense(
            id: UUID(),
            title: "Electric Bill",
            amount: 180.00,
            category: .utilities,
            paidByUserID: sarah.id,
            splitBetweenUserIDs: allUsers.map { $0.id },
            date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            notes: "February electric bill",
            householdID: household.id
        ),
        Expense(
            id: UUID(),
            title: "Internet Bill",
            amount: 89.99,
            category: .internet,
            paidByUserID: mike.id,
            splitBetweenUserIDs: allUsers.map { $0.id },
            date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
            householdID: household.id
        ),
        Expense(
            id: UUID(),
            title: "Cleaning Supplies",
            amount: 45.20,
            category: .cleaning,
            paidByUserID: emma.id,
            splitBetweenUserIDs: allUsers.map { $0.id },
            date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
            notes: "Paper towels, dish soap, sponges",
            householdID: household.id
        ),
        Expense(
            id: UUID(),
            title: "Toilet Paper & Tissues",
            amount: 32.50,
            category: .household,
            paidByUserID: currentUser.id,
            splitBetweenUserIDs: allUsers.map { $0.id },
            date: Calendar.current.date(byAdding: .day, value: -12, to: Date())!,
            householdID: household.id
        ),
        Expense(
            id: UUID(),
            title: "Pizza Night",
            amount: 58.75,
            category: .other,
            paidByUserID: sarah.id,
            splitBetweenUserIDs: [sarah.id, mike.id, emma.id],
            date: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
            notes: "Friday night dinner",
            householdID: household.id
        ),
        Expense(
            id: UUID(),
            title: "Rent - March",
            amount: 2400.00,
            category: .rent,
            paidByUserID: mike.id,
            splitBetweenUserIDs: allUsers.map { $0.id },
            date: Calendar.current.date(byAdding: .month, value: 0, to: Date())!,
            notes: "March rent payment",
            householdID: household.id
        ),
        Expense(
            id: UUID(),
            title: "Trader Joe's",
            amount: 67.89,
            category: .groceries,
            paidByUserID: emma.id,
            splitBetweenUserIDs: allUsers.map { $0.id },
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            householdID: household.id
        )
    ]

    // MARK: - Mock Chores
    lazy var chores: [Chore] = [
        Chore(
            id: UUID(),
            title: "Take out trash",
            description: "Trash pickup is Thursday morning",
            assignedToUserID: currentUser.id,
            dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date())!,
            recurrence: .weekly,
            householdID: household.id
        ),
        Chore(
            id: UUID(),
            title: "Clean bathroom",
            description: "Deep clean, including shower and toilet",
            assignedToUserID: sarah.id,
            dueDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
            recurrence: .weekly,
            householdID: household.id
        ),
        Chore(
            id: UUID(),
            title: "Vacuum living room",
            assignedToUserID: mike.id,
            dueDate: Date(),
            isCompleted: false,
            recurrence: .weekly,
            householdID: household.id
        ),
        Chore(
            id: UUID(),
            title: "Mop kitchen floor",
            assignedToUserID: emma.id,
            dueDate: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            recurrence: .weekly,
            householdID: household.id
        ),
        Chore(
            id: UUID(),
            title: "Change AC filter",
            description: "Monthly AC maintenance",
            assignedToUserID: mike.id,
            dueDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!,
            recurrence: .monthly,
            householdID: household.id
        )
    ]

    // Helper to get user by ID
    func user(withID id: UUID) -> User? {
        return allUsers.first { $0.id == id }
    }
}
