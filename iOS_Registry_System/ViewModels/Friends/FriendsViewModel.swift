//
//  FriendsViewModel.swift
//  iOS_Registry_System
//
//  Friends screen view model
//

import SwiftUI

// MARK: - Friends View Model

@MainActor
@Observable
final class FriendsViewModel {

    // MARK: State

    enum FriendCategory: String, CaseIterable, Identifiable {
        case all = "All"
        case wedding = "Wedding"
        case baby = "Baby"
        case housewarming = "Housewarming"

        var id: String { rawValue }
    }

    var friendEvents: [Event] = []
    var isLoading = false
    var errorMessage: String?
    var searchText = ""
    var selectedCategory: FriendCategory = .all

    // MARK: Computed

    var filteredFriendEvents: [Event] {
        var list = friendEvents

        switch selectedCategory {
        case .all:
            break
        case .wedding:
            list = list.filter { $0.eventType == "wedding" }
        case .baby:
            list = list.filter { $0.eventType == "baby_shower" }
        case .housewarming:
            list = list.filter { $0.eventType == "housewarming" }
        }

        if !searchText.isEmpty {
            list = list.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }

        return list
    }

    // MARK: - Actions

    func loadFriendEvents() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            friendEvents = try await EventService.shared.fetchFriendEvents()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
