import SwiftUI

struct MainTabView: View {
    @StateObject private var expenseViewModel = ExpenseViewModel()
    @StateObject private var choreViewModel = ChoreScheduleViewModel()
    @State private var showingAddChore = false
    @State private var showingRoommates = false

    var body: some View {
        TabView {
            // Expenses Tab
            ExpenseListView()
                .tabItem {
                    Label("Expenses", systemImage: "dollarsign.circle.fill")
                }

            // Chores Tab
            ChoresView(viewModel: choreViewModel, showingAddChore: $showingAddChore)
                .tabItem {
                    Label("Chores", systemImage: "checkmark.circle.fill")
                }

            // Roommates Tab
            RoommatesView(viewModel: choreViewModel, showingRoommates: $showingRoommates)
                .tabItem {
                    Label("Roommates", systemImage: "person.3.fill")
                }

            // Fridge Board Tab
            FridgeBoardView()
                .tabItem {
                    Label("Fridge", systemImage: "square.grid.2x2")
                }
        }
    }
}

#Preview {
    MainTabView()
}
