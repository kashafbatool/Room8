//
//  MoreView.swift
//  Room8App
//

import SwiftUI

struct MoreView: View {
    @EnvironmentObject var auth: AuthViewModel
    @StateObject private var choreViewModel = ChoreScheduleViewModel()
    @State private var showingAddChore = false
    @State private var showingRoommates = false

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Text("More")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(Theme.navy)
                        Spacer()
                    }
                    .padding(.horizontal, Theme.pad)
                    .padding(.top, 16)

                    // Features Section
                    VStack(spacing: 16) {
                        NavigationLink {
                            EnhancedFridgeView()
                        } label: {
                            MoreItemRow(
                                icon: "square.grid.2x2",
                                iconBg: Theme.sand.opacity(0.55),
                                title: "Fridge Board",
                                subtitle: "Sticky notes & photos"
                            )
                        }

                        NavigationLink {
                            ChoresView(viewModel: choreViewModel, showingAddChore: $showingAddChore)
                        } label: {
                            MoreItemRow(
                                icon: "checkmark.circle.fill",
                                iconBg: Theme.sage.opacity(0.35),
                                title: "Chores",
                                subtitle: "Task management"
                            )
                        }

                        NavigationLink {
                            RoommatesView(viewModel: choreViewModel, showingRoommates: $showingRoommates)
                        } label: {
                            MoreItemRow(
                                icon: "person.3.fill",
                                iconBg: Theme.terracotta.opacity(0.30),
                                title: "Roommates",
                                subtitle: "Manage household"
                            )
                        }
                    }
                    .padding(.horizontal, Theme.pad)

                    // Settings Section
                    VStack(spacing: 16) {
                        Text("Settings")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Theme.navy)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, Theme.pad)
                            .padding(.top, 12)

                        Button {
                            // TODO: Profile settings
                        } label: {
                            MoreItemRow(
                                icon: "person.circle",
                                iconBg: Theme.navy.opacity(0.15),
                                title: "Profile",
                                subtitle: "Account settings"
                            )
                        }

                        Button {
                            // TODO: Notifications settings
                        } label: {
                            MoreItemRow(
                                icon: "bell",
                                iconBg: Theme.sage.opacity(0.25),
                                title: "Notifications",
                                subtitle: "Manage alerts"
                            )
                        }

                        NavigationLink {
                            GoogleCalendarSettingsView()
                        } label: {
                            MoreItemRow(
                                icon: "calendar.badge.clock",
                                iconBg: Color.blue.opacity(0.15),
                                title: "Google Calendar",
                                subtitle: "Sync chores & get reminders"
                            )
                        }

                        Button {
                            auth.logout()
                        } label: {
                            MoreItemRow(
                                icon: "rectangle.portrait.and.arrow.right",
                                iconBg: Color.red.opacity(0.15),
                                title: "Log Out",
                                subtitle: "Sign out of Room8"
                            )
                        }
                    }
                    .padding(.horizontal, Theme.pad)

                    Spacer(minLength: 24)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Components
private struct MoreItemRow: View {
    let icon: String
    let iconBg: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Circle()
                .fill(iconBg)
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black.opacity(0.7))
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.black.opacity(0.55))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black.opacity(0.3))
        }
        .padding(16)
        .background(Theme.white)
        .cornerRadius(Theme.cornerL)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}
