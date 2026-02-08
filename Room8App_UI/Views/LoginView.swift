//
//  LoginView.swift
//  Room8App_UI
//
//  Created by ktnguyenx on 2/8/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthViewModel

    @State private var email = ""
    @State private var password = ""

    enum Field { case email, password }
    @FocusState private var focused: Field?

    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.90, blue: 0.78).ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer()

                Text("room8")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(Color(red: 0.55, green: 0.35, blue: 0.30))

                VStack(spacing: 12) {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .submitLabel(.next)
                        .focused($focused, equals: .email)
                        .onSubmit { focused = .password }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(18)

                    SecureField("Password", text: $password)
                        .submitLabel(.go)
                        .focused($focused, equals: .password)
                        .onSubmit { Task { await auth.login(email: email, password: password) } }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(18)
                }
                .padding(.horizontal, 28)

                // Optional: hidden-ish button for accessibility
                Button("Log In") {
                    Task { await auth.login(email: email, password: password) }
                }
                .opacity(0.0)
                .frame(height: 1)

                Spacer()
            }
        }
        .onAppear { focused = .email }
    }
}
