//
//  MoneyRootView.swift
//  Room8App_UI
//
//  Created by ktnguyenx on 2/8/26.
//

import SwiftUI

enum MoneyMode: Hashable {
    case expenses
    case shopping
}

struct MoneyRootView: View {
    @State private var mode: MoneyMode = .expenses

    // Expenses mock data
    @State private var balance: Double = 55.63
    @State private var owe: Double = 45.00
    @State private var owed: Double = 90.00

    @State private var expenses: [ExpenseItem] = [
        .init(title: "Popcorn", amount: 20.00, paidBy: "Fatma", split: "Split 4 ways", delta: +5.00),
        .init(title: "Utilities", amount: 120.00, paidBy: "You", split: "Split 4 ways", delta: -40.00),
        .init(title: "Cleaning Supplies", amount: 60.00, paidBy: "Efrata", split: "Split 4 ways", delta: +15.00)
    ]

    // Shopping mock data
    @State private var shoppingText: String = ""
    @State private var shoppingItems: [ShoppingItem] = [
        .init(title: "Milk", owner: "Fatma", isDone: false),
        .init(title: "Paper Towels", owner: "You", isDone: false),
        .init(title: "Dish Soap", owner: "Kashaf", isDone: false),
        .init(title: "Eggs", owner: "Efrata", isDone: false),
        .init(title: "Bread", owner: "You", isDone: false)
    ]

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                Color.clear.frame(height: 1) // forces scroll bounce even if content is short
                VStack(spacing: 18) {
                    header

                    MoneyModeToggle(mode: $mode)

                    Group {
                        switch mode {
                        case .expenses:
                            expensesScreen
                        case .shopping:
                            shoppingScreen
                        }
                    }

                    Spacer(minLength: 90)
                }
                .padding(.horizontal, Theme.pad)
                .padding(.top, 16)
            }
        }
    }

    // MARK: Header
    private var header: some View {
        HStack {
            Text("Money & Shopping")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(Theme.navy)
            Spacer()
        }
    }

    // MARK: Expenses
    private var expensesScreen: some View {
        VStack(spacing: 18) {
            PrimaryActionPill(
                systemName: "plus",
                title: "Add Expense"
            ) {
                // TODO: open add-expense flow/sheet
            }

            BalanceCard(balance: balance, owe: owe, owed: owed)

            VStack(alignment: .leading, spacing: 14) {
                Text("Recent Expenses")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)

                VStack(spacing: 14) {
                    ForEach(expenses) { item in
                        ExpenseCard(item: item)
                    }
                }
            }
            .padding(.top, 6)
        }
    }

    // MARK: Shopping
    private var shoppingScreen: some View {
        VStack(spacing: 18) {
            ShoppingAddBar(text: $shoppingText) {
                addShoppingItem()
            }

            HStack(spacing: 14) {
                StatMiniCard(
                    systemName: "cart",
                    title: "To Buy",
                    value: "\(shoppingItems.filter { !$0.isDone }.count)",
                    bg: Theme.sage.opacity(0.18),
                    fg: Theme.sage.opacity(0.95)
                )

                StatMiniCard(
                    systemName: "checkmark.circle",
                    title: "In Cart",
                    value: "\(shoppingItems.filter { $0.isDone }.count)",
                    bg: Theme.terracotta.opacity(0.12),
                    fg: Theme.terracotta.opacity(0.95)
                )
            }

            VStack(alignment: .leading, spacing: 14) {
                Text("To Buy")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)

                VStack(spacing: 14) {
                    ForEach($shoppingItems) { $item in
                        ShoppingRow(item: $item) {
                            deleteShoppingItem(id: item.id)
                        }
                    }
                }
            }
            .padding(.top, 6)
        }
    }

    private func addShoppingItem() {
        let trimmed = shoppingText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        shoppingItems.insert(.init(title: trimmed, owner: "You", isDone: false), at: 0)
        shoppingText = ""
    }

    private func deleteShoppingItem(id: UUID) {
        shoppingItems.removeAll { $0.id == id }
    }
}

// MARK: - Mode toggle (Expenses / Shopping)

struct MoneyModeToggle: View {
    @Binding var mode: MoneyMode

    var body: some View {
        HStack(spacing: 0) {
            button(title: "Expenses", systemName: "dollarsign", isSelected: mode == .expenses) { mode = .expenses }
            button(title: "Shopping", systemName: "cart", isSelected: mode == .shopping) { mode = .shopping }
        }
        .padding(6)
        .background(Theme.sand.opacity(0.55))
        .cornerRadius(Theme.cornerXL)
    }

    private func button(title: String, systemName: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemName)
                    .font(.system(size: 14, weight: .semibold))
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(isSelected ? Theme.navy : Theme.navy.opacity(0.75))
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(isSelected ? Theme.white : Color.clear)
            .cornerRadius(Theme.cornerL)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Expenses components

struct PrimaryActionPill: View {
    let systemName: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemName)
                    .font(.system(size: 16, weight: .bold))
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(Theme.terracotta.opacity(0.9))
            .cornerRadius(Theme.cornerXL)
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }
}

struct BalanceCard: View {
    let balance: Double
    let owe: Double
    let owed: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Balance")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.95))

            Text("$" + String(format: "%.2f", balance))
                .font(.system(size: 44, weight: .semibold))
                .foregroundColor(.white)

            HStack(spacing: 12) {
                miniPill(systemName: "arrow.down.right", text: "Owe: $" + String(format: "%.2f", owe))
                miniPill(systemName: "arrow.up.right", text: "Owed: $" + String(format: "%.2f", owed))
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.terracotta.opacity(0.9))
        .cornerRadius(Theme.cornerXL)
    }

    private func miniPill(systemName: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
            Text(text)
                .font(.system(size: 14, weight: .semibold))
        }
        .foregroundColor(.white.opacity(0.95))
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.18))
        .cornerRadius(999)
    }
}

struct ExpenseItem: Identifiable {
    let id = UUID()
    let title: String
    let amount: Double
    let paidBy: String
    let split: String
    let delta: Double   // + means user should receive, - means user owes
}

struct ExpenseCard: View {
    let item: ExpenseItem

    private var deltaText: String {
        let sign = item.delta >= 0 ? "+" : "-"
        return "\(sign) $" + String(format: "%.2f", abs(item.delta))
    }

    private var deltaColor: Color {
        item.delta >= 0 ? Theme.terracotta.opacity(0.85) : Theme.sage.opacity(0.95)
    }

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(Theme.white)
                .frame(width: 34, height: 34)
                .overlay(
                    Text("$")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Theme.terracotta.opacity(0.9))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)

                HStack(spacing: 6) {
                    Text("Paid by")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.black.opacity(0.70))
                    Text(item.paidBy)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.black)
                }

                Text(item.split)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.sage.opacity(0.85))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text("$" + String(format: "%.2f", item.amount))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black.opacity(0.90))

                Text(deltaText)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(deltaColor)
            }
        }
        .padding(16)
        .background(Theme.sand.opacity(0.65))
        .cornerRadius(Theme.cornerXL)
    }
}

// MARK: - Shopping components

struct ShoppingItem: Identifiable {
    let id = UUID()
    var title: String
    var owner: String
    var isDone: Bool
}

struct ShoppingAddBar: View {
    @Binding var text: String
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField("Add item to shopping list...", text: $text)
                .textInputAutocapitalization(.sentences)
                .padding(.horizontal, 16)
                .frame(height: 44)
                .background(Theme.white)
                .cornerRadius(999)

            Button(action: onAdd) {
                Circle()
                    .fill(Theme.white)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Theme.terracotta.opacity(0.9))
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(Theme.terracotta.opacity(0.75))
        .cornerRadius(Theme.cornerXL)
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
    }
}

struct StatMiniCard: View {
    let systemName: String
    let title: String
    let value: String
    let bg: Color
    let fg: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(fg)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(fg)
                Text(value)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.black.opacity(0.90))
            }

            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(bg)
        .cornerRadius(Theme.cornerXL)
    }
}

struct ShoppingRow: View {
    @Binding var item: ShoppingItem
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.18)) {
                    item.isDone.toggle()
                }
            } label: {
                Circle()
                    .strokeBorder(Color.black.opacity(0.25), lineWidth: 2)
                    .background(
                        Circle().fill(item.isDone ? Theme.sage.opacity(0.35) : Color.clear)
                    )
                    .frame(width: 22, height: 22)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black.opacity(0.90))
                    .strikethrough(item.isDone, color: .black.opacity(0.45))
                    .opacity(item.isDone ? 0.6 : 1)

                HStack(spacing: 6) {
                    Image(systemName: "person")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.black.opacity(0.65))
                    Text(item.owner)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black.opacity(0.75))
                }
            }

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Theme.terracotta.opacity(0.85))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Theme.sand.opacity(0.65))
        .cornerRadius(Theme.cornerXL)
    }
}
