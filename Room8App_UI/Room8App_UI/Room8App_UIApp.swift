//
//  Room8App_UIApp.swift
//  Room8App_UI
//
//  Created by ktnguyenx on 2/8/26.
//

import SwiftUI

@main
struct Room8AppApp: App {
    @StateObject private var auth = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            if auth.isLoggedIn {
                MainTabView()
                    .environmentObject(auth)
            } else {
                LoginView()
                    .environmentObject(auth)
            }
        }
    }
}
