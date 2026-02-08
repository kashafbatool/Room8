import SwiftUI

struct BalanceView: View {
    @ObservedObject var viewModel: ExpenseViewModel

    var balances: [UserBalance] {
        viewModel.calculateBalances()
    }

    var body: some View {
        List {
            Section(header: Text("Who Owes Who")) {
                ForEach(balances) { balance in
                    BalanceRowView(balance: balance, isCurrentUser: balance.user.id == viewModel.currentUser.id)
                }
            }

            Section(header: Text("Summary")) {
                ForEach(viewModel.expensesByCategory, id: \.category) { item in
                    HStack {
                        Label {
                            Text(item.category.rawValue)
                        } icon: {
                            Image(systemName: categoryIcon(item.category))
                                .foregroundColor(categoryColor(item.category))
                        }

                        Spacer()

                        Text(formatCurrency(item.total))
                            .fontWeight(.semibold)
                    }
                }

                HStack {
                    Text("Total")
                        .fontWeight(.bold)
                    Spacer()
                    Text(formatCurrency(viewModel.totalExpenses))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
        }
        .navigationTitle("Balances")
        .navigationBarTitleDisplayMode(.inline)
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
}

struct BalanceRowView: View {
    let balance: UserBalance
    let isCurrentUser: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(isCurrentUser ? "You" : balance.user.name)
                    .font(.headline)

                Text(balance.owesOrOwed)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(formatCurrency(abs(balance.netBalance)))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(balanceColor)
        }
        .padding(.vertical, 4)
    }

    private var balanceColor: Color {
        if balance.netBalance > 0 {
            return .green
        } else if balance.netBalance < 0 {
            return .red
        } else {
            return .gray
        }
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}

#Preview {
    NavigationView {
        BalanceView(viewModel: ExpenseViewModel())
    }
}
