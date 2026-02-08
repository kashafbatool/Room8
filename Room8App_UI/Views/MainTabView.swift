//
//  MainTabView.swift
//  Room8App_UI
//
//  Created by ktnguyenx on 2/8/26.
//

import SwiftUI

struct MainTabView: View {

    @State private var selectedTab: AppTab = .home
    var body: some View {
        TabView(selection: $selectedTab) {
            // HOME
            NavigationStack {
                HomeView(selectedTab: $selectedTab)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(AppTab.home)

            // CALENDAR
            NavigationStack {
                CalendarRootView()
            }
            .tabItem {
                Label("Calendar", systemImage: "calendar")
            }
            .tag(AppTab.calendar)

            // MONEY
            NavigationStack {
                MoneyRootView()
            }
            .tabItem {
                Label("Money", systemImage: "dollarsign")
            }
            .tag(AppTab.money)

            // MORE
            NavigationStack {
                MoreView()
            }
            .tabItem {
                Label("More", systemImage: "ellipsis")
            }
            .tag(AppTab.more)
        }
    }
}
