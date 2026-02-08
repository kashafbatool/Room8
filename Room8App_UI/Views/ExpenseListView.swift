import SwiftUI

struct ExpenseListView: View {
    @StateObject private var viewModel = ExpenseViewModel()
    @State private var showingAddExpense = false

    var body: some View {
        NavigationView {
            List {
                // Summary Section
                Section {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Total Expenses")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(formatCurrency(viewModel.totalExpenses))
                                .font(.title2)
                                .fontWeight(.bold)
                        }

                        Spacer()

                        NavigationLink(destination: BalanceView(viewModel: viewModel)) {
                            VStack(alignment: .trailing) {
                                Text("View Balances")
                                    .font(.subheadline)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }

                // Expenses List
                Section(header: Text("Recent Expenses")) {
                    ForEach(viewModel.sortedExpenses) { expense in
                        NavigationLink(destination: ExpenseDetailView(expense: expense, viewModel: viewModel)) {
                            ExpenseRowView(expense: expense, viewModel: viewModel)
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let expense = viewModel.sortedExpenses[index]
                            Task {
                                await viewModel.deleteExpense(expense)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Expenses")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddExpense = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView(viewModel: viewModel)
            }
        }
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}

struct ExpenseRowView: View {
    let expense: Expense
    let viewModel: ExpenseViewModel

    var body: some View {
        HStack {
            // Category Icon
            Image(systemName: categoryIcon(expense.category))
                .foregroundColor(categoryColor(expense.category))
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.headline)

                HStack {
                    Text(viewModel.userName(for: expense.paidByUserID))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(formatDate(expense.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(formatCurrency(expense.amount))
                    .font(.headline)

                Text(formatCurrency(expense.amountPerPerson) + " each")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func categoryIcon(_ category: ExpenseCategory) -> String {
        switch category {
        case .groceries: return "cart.fill"
        case .utilities: return "bolt.fill"
        case .rent: return "house.fill"
        case .internet: return "wifi"
        case .cleaning: return "sparkles"
        case .household: return "house"
        case .other: return "ellipsis.circle.fill"
        }
    }

    private func categoryColor(_ category: ExpenseCategory) -> Color {
        switch category {
        case .groceries: return .green
        case .utilities: return .orange
        case .rent: return .purple
        case .internet: return .blue
        case .cleaning: return .cyan
        case .household: return .indigo
        case .other: return .gray
        }
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    ExpenseListView()
}
