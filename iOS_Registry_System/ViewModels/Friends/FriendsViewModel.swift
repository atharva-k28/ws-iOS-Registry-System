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

    var friendEvents: [Event] = []
    var isLoading = false
    var errorMessage: String?
    var searchText = ""

    // MARK: Computed

    var filteredFriendEvents: [Event] {
        guard !searchText.isEmpty else { return friendEvents }
        return friendEvents.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
        }
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
