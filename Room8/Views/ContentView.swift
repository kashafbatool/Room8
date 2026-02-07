import SwiftUI

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var viewModel = ChoreScheduleViewModel()
    @State private var showingAddChore = false
    @State private var showingRoommates = false
    
    var body: some View {
        TabView {
            // Chores Tab
            ChoresView(viewModel: viewModel, showingAddChore: $showingAddChore)
                .tabItem {
                    Label("Chores", systemImage: "checklist")
                }
            
            // Roommates Tab
            RoommatesView(viewModel: viewModel, showingRoommates: $showingRoommates)
                .tabItem {
                    Label("Roommates", systemImage: "person.2")
                }

            // Whiteboard Tab
            WhiteboardView()
                .tabItem {
                    Label("Whiteboard", systemImage: "pencil.and.outline")
                }
        }
    }
}
