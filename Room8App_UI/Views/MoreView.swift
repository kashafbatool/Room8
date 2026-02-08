//
//  MoreView.swift
//  Room8App_UI
//
//  Created by ktnguyenx on 2/8/26.
//

import SwiftUI

enum AppAppearance: Hashable {
    case light, dark, system
}

struct MoreView: View {
    @State private var appearance: AppAppearance = .light

    @State private var pushNotifications = true
    @State private var choreReminders = true
    @State private var expenseAlerts = true

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    header

                    profileCard

                    appearanceCard

                    notificationsCard

                    privacyCard

                    Spacer(minLength: 90)
                }
                .padding(.horizontal, Theme.pad)
                .padding(.top, 16)
            }
        }
    }

    private var header: some View {
        HStack {
            Text("More")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(Theme.navy)
            Spacer()
        }
    }

    // MARK: Profile
    private var profileCard: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Theme.navy.opacity(0.75))
                .frame(width: 64, height: 64)
                .overlay(
                    Text("Y")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 6) {
                Text("You")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)

                Text("you@brynmawr.edu")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black.opacity(0.65))
            }

            Spacer()

            Button("Edit") {
                // TODO: route to profile edit
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(Theme.navy.opacity(0.85))
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(Theme.white)
        .cornerRadius(Theme.cornerXL)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
    }

    // MARK: Appearance
    private var appearanceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Appearance")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)

            HStack(spacing: 14) {
                AppearanceTile(
                    title: "Light",
                    systemName: "sun.max",
                    isSelected: appearance == .light,
                    selectedTint: Theme.terracotta.opacity(0.85)
                ) { appearance = .light }

                AppearanceTile(
                    title: "Dark",
                    systemName: "moon",
                    isSelected: appearance == .dark,
                    selectedTint: Theme.terracotta.opacity(0.85)
                ) { appearance = .dark }

                AppearanceTile(
                    title: "System",
                    systemName: "desktopcomputer",
                    isSelected: appearance == .system,
                    selectedTint: Theme.terracotta.opacity(0.85)
                ) { appearance = .system }
            }
        }
        .padding(18)
        .background(Theme.white)
        .cornerRadius(Theme.cornerXL)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
    }

    // MARK: Notifications
    private var notificationsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Notifications")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)

            ToggleRow(
                title: "Push Notifications",
                subtitle: "Get notified about updates",
                isOn: $pushNotifications
            )

            ToggleRow(
                title: "Chore Reminders",
                subtitle: "Daily reminders for tasks",
                isOn: $choreReminders
            )

            ToggleRow(
                title: "Expense Alerts",
                subtitle: "When expenses are added",
                isOn: $expenseAlerts
            )
        }
        .padding(18)
        .background(Theme.white)
        .cornerRadius(Theme.cornerXL)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
    }

    // MARK: Privacy
    private var privacyCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Privacy & Legal")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.black)

            Button {
                // TODO: route to privacy policy
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "shield")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Theme.navy.opacity(0.75))

                    Text("Privacy Policy")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Theme.navy.opacity(0.85))

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black.opacity(0.35))
                }
                .padding(.vertical, 10)
            }
            .buttonStyle(.plain)
        }
        .padding(18)
        .background(Theme.white)
        .cornerRadius(Theme.cornerXL)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Components

private struct AppearanceTile: View {
    let title: String
    let systemName: String
    let isSelected: Bool
    let selectedTint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: systemName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Theme.navy.opacity(0.75))

                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Theme.navy.opacity(0.85))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 92)
            .background(Theme.white)
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? selectedTint : Color.black.opacity(0.08), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct ToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.navy.opacity(0.85))

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Theme.navy.opacity(0.55))
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Theme.terracotta.opacity(0.85))
        }
        .padding(.vertical, 6)
    }
}
