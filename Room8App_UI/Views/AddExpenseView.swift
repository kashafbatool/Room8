import SwiftUI

struct AddExpenseView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var amount = ""
    @State private var category: ExpenseCategory = .groceries
    @State private var paidByUserID: UUID
    @State private var selectedUserIDs: Set<UUID>
    @State private var date = Date()
    @State private var notes = ""

    init(viewModel: ExpenseViewModel) {
        self.viewModel = viewModel
        _paidByUserID = State(initialValue: viewModel.currentUser.id)
        _selectedUserIDs = State(initialValue: Set(viewModel.users.map { $0.id }))
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Expense Details")) {
                    TextField("Title", text: $title)

                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)

                    Picker("Category", selection: $category) {
                        ForEach(ExpenseCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }

                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section(header: Text("Paid By")) {
                    Picker("Who paid?", selection: $paidByUserID) {
                        ForEach(viewModel.users) { user in
                            Text(user.id == viewModel.currentUser.id ? "You" : user.name)
                                .tag(user.id)
                        }
                    }
                }

                Section(header: Text("Split Between")) {
                    ForEach(viewModel.users) { user in
                        Toggle(isOn: Binding(
                            get: { selectedUserIDs.contains(user.id) },
                            set: { isSelected in
                                if isSelected {
                                    selectedUserIDs.insert(user.id)
                                } else {
                                    selectedUserIDs.remove(user.id)
                                }
                            }
                        )) {
                            Text(user.id == viewModel.currentUser.id ? "You" : user.name)
                        }
                    }
                }

                Section(header: Text("Notes (Optional)")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }

                if !selectedUserIDs.isEmpty, let amountValue = Decimal(string: amount) {
                    Section {
                        HStack {
                            Text("Amount per person:")
                            Spacer()
                            Text(formatCurrency(amountValue / Decimal(selectedUserIDs.count)))
                                .fontWeight(.bold)
                        }
                    }
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveExpense()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }

    private var isFormValid: Bool {
        !title.isEmpty &&
        !amount.isEmpty &&
        Decimal(string: amount) != nil &&
        !selectedUserIDs.isEmpty
    }

    private func saveExpense() {
        guard let amountValue = Decimal(string: amount) else { return }

        let expense = Expense(
            title: title,
            amount: amountValue,
            category: category,
            paidByUserID: paidByUserID,
            splitBetweenUserIDs: Array(selectedUserIDs),
            date: date,
            notes: notes.isEmpty ? nil : notes,
            householdID: viewModel.currentUser.householdID ?? MockData.shared.household.id
        )

        Task {
            await viewModel.addExpense(expense)
            dismiss()
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
    AddExpenseView(viewModel: ExpenseViewModel())
}
