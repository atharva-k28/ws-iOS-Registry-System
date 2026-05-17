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
    var pendingInvites: [Event] = []
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
            pendingInvites = try await EventService.shared.fetchPendingInvites()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func acceptInvite(event: Event) async {
        do {
            try await EventService.shared.acceptInvite(eventId: event.id)
            // Move from pending to accepted
            pendingInvites.removeAll { $0.id == event.id }
            friendEvents.append(event)
        } catch {
            print("Failed to accept invite: \(error)")
        }
    }

    func declineInvite(event: Event) async {
        do {
            try await EventService.shared.declineInvite(eventId: event.id)
            pendingInvites.removeAll { $0.id == event.id }
        } catch {
            print("Failed to decline invite: \(error)")
        }
    }
}
