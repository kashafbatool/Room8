//
//  HomeView.swift
//  Room8App_UI
//
//  Created by ktnguyenx on 2/8/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @Binding var selectedTab: AppTab
    init(selectedTab: Binding<AppTab>) {
        self._selectedTab = selectedTab
    }

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 18) {
                    header

                    dashboardCard

                    tilesGrid

                    activityCard

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, Theme.pad)
                .padding(.top, 16)
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack(alignment: .center) {
            Text("Hi, \(vm.greetingName)!")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(Theme.navy)

            Spacer()

            Circle()
                .fill(Theme.sand)
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(Theme.terracotta)
                )
        }
    }

    // MARK: - Dashboard card
    private var dashboardCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Dashboard")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.black)

                Spacer()

                HStack(spacing: 10) {
                    avatarDot
                    avatarDot
                    avatarDot
                }
            }

            HStack(spacing: 12) {
                ForEach(vm.notes.indices, id: \.self) { idx in
                    StickyNote(text: vm.notes[idx])
                }
            }

            HStack {
                Text(vm.billLine)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.black.opacity(0.75))

                Spacer()

                Button {
                    // TODO: navigate to House Status / bills details
                } label: {
                    HStack(spacing: 8) {
                        Text("View Details")
                            .font(.system(size: 13, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(Theme.black.opacity(0.85))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Theme.sand.opacity(0.85))
                    .cornerRadius(14)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Theme.white)
        .cornerRadius(Theme.cornerXL)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
    }

    private var avatarDot: some View {
        Circle()
            .fill(Color.gray.opacity(0.25))
            .frame(width: 30, height: 30)
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.gray.opacity(0.55))
            )
    }

    // MARK: - Tiles (2x2)
    private var tilesGrid: some View {
        VStack(spacing: 14) {
            HStack(spacing: 14) {
                StatTile(
                    icon: "list.bullet",
                    iconBg: Theme.sage.opacity(0.35),
                    title: "Chores",
                    subtitle: "\(vm.choresDue) due"
                ) {
                    selectedTab = .calendar
                }

                StatTile(
                    icon: "dollarsign",
                    iconBg: Theme.terracotta.opacity(0.30),
                    title: "Money",
                    subtitle: "Owe $\(vm.moneyOwed)"
                ) {
                    selectedTab = .money
                }
            }

            HStack(spacing: 14) {
                StatTile(
                    icon: "cart",
                    iconBg: Theme.sand.opacity(0.55),
                    title: "To Buy",
                    subtitle: "\(vm.toBuyCount) items"
                ) {
                    selectedTab = .money
                }

                StatTile(
                    icon: "bell",
                    iconBg: Theme.navy.opacity(0.15),
                    title: "Updates",
                    subtitle: "\(vm.updatesCount) new"
                ) {
                    selectedTab = .more
                }
            }
        }
    }

    // MARK: - Activity card
    private var activityCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recent Activity")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)

            VStack(spacing: 14) {
                ForEach(vm.activity.indices, id: \.self) { idx in
                    ActivityRow(text: vm.activity[idx])
                }
            }
        }
        .padding(16)
        .background(Theme.white)
        .cornerRadius(Theme.cornerXL)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Components

private struct StickyNote: View {
    let text: String

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Theme.sand.opacity(0.8))
                .frame(width: 92, height: 62)

            // “fold” corner
            Path { p in
                p.move(to: CGPoint(x: 72, y: 0))
                p.addLine(to: CGPoint(x: 92, y: 0))
                p.addLine(to: CGPoint(x: 92, y: 20))
                p.closeSubpath()
            }
            .fill(Color.white.opacity(0.55))

            Text(text)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.black.opacity(0.75))
                .multilineTextAlignment(.center)
                .frame(width: 92, height: 62)
                .padding(.top, 4)
        }
    }
}

private struct StatTile: View {
    let icon: String
    let iconBg: Color
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Circle()
                    .fill(iconBg)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black.opacity(0.7))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.black.opacity(0.6))
                }

                Spacer()
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(Theme.white)
            .cornerRadius(Theme.cornerL)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }
}

private struct ActivityRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.25))
                .frame(width: 34, height: 34)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.gray.opacity(0.55))
                )

            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.black.opacity(0.75))

            Spacer()
        }
    }
}
