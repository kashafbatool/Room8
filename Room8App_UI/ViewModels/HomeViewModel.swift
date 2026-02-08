//
//  HomeViewModel.swift
//  Room8App_UI
//
//  Created by ktnguyenx on 2/8/26.
//

import SwiftUI
import Combine

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var greetingName: String = "Lorraine"
    @Published var choresDue = 2
    @Published var moneyOwed = 45
    @Published var toBuy = 3
    @Published var updates = 5

    @Published var billText = "Wi-Fi bill ($50) due in 3 days!"
    @Published var notes = ["Happy Birthday Fatma! <3", "Rmb to take out the trash!!", "Are we going to that party…"]

    @Published var activity = [
        "Fatma completed “Take out trash”",
        "Kashaf added expense “Popcorn”",
        "Efrata added “Paper towels” to list"
    ]

    // Later: inject Services and fetch real data here
}
