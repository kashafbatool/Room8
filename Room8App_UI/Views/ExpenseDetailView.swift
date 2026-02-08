import SwiftUI

struct ExpenseDetailView: View {
    let expense: Expense
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false

    var body: some View {
        List {
            Section(header: Text("Details")) {
                HStack {
                    Text("Amount")
                    Spacer()
                    Text(formatCurrency(expense.amount))
                        .fontWeight(.bold)
                }

                HStack {
                    Text("Category")
                    Spacer()
                    Label(expense.category.rawValue, systemImage: categoryIcon(expense.category))
                        .foregroundColor(categoryColor(expense.category))
                }

                HStack {
                    Text("Date")
                    Spacer()
                    Text(formatDate(expense.date))
                }

                HStack {
                    Text("Paid by")
                    Spacer()
                    Text(viewModel.userName(for: expense.paidByUserID))
                        .foregroundColor(.secondary)
                }
            }

            Section(header: Text("Split Between")) {
                ForEach(expense.splitBetweenUserIDs, id: \.self) { userID in
                    if let user = viewModel.user(for: userID) {
                        HStack {
                            Text(user.id == viewModel.currentUser.id ? "You" : user.name)
                            Spacer()
                            Text(formatCurrency(expense.amountPerPerson))
                                .foregroundColor(.secondary)
                        }
                    }
                }

                HStack {
                    Text("Per person")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(formatCurrency(expense.amountPerPerson))
                        .fontWeight(.semibold)
                }
            }

            if let notes = expense.notes, !notes.isEmpty {
                Section(header: Text("Notes")) {
                    Text(notes)
                        .foregroundColor(.secondary)
                }
            }

            Section {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Delete Expense")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle(expense.title)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Expense?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteExpense(expense)
                    dismiss()
                }
            }
        } message: {
            Text("This action cannot be undone.")
        }
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
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationView {
        ExpenseDetailView(
            expense: MockData.shared.expenses[0],
            viewModel: ExpenseViewModel()
        )
    }
}
