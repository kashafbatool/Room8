//
//  MainTabView.swift
//  Room8App_UI
//
//  Created by ktnguyenx on 2/8/26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }

            CalendarRootView()
                .tabItem { Label("Calendar", systemImage: "calendar") }

            MoneyRootView()
                .tabItem { Label("Money", systemImage: "dollarsign") }

            MoreView()
                .tabItem { Label("More", systemImage: "ellipsis") }
        }
    }
}
