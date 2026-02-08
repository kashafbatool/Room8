//
//  AuthViewModel.swift
//  Room8App_UI
//
//  Created by ktnguyenx on 2/8/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User? = nil

    // Later: store token securely
    // @Published var token: String? = nil

    func login(email: String, password: String) async {
        // TEMP: mock login until backend is ready
        // Later: call AuthService.login(...)
        self.currentUser = nil
        self.isLoggedIn = true
    }

    func logout() {
        isLoggedIn = false
        currentUser = nil
    }
}
