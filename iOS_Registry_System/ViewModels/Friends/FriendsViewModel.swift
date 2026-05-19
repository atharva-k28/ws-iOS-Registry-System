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
    var eventProgresses: [UUID: Double] = [:]
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
            let events = try await EventService.shared.fetchFriendEvents()
            let invites = try await EventService.shared.fetchPendingInvites()
            
            // Calculate progress for each event in parallel
            var progresses: [UUID: Double] = [:]
            await withTaskGroup(of: (UUID, Double).self) { group in
                for event in events {
                    group.addTask {
                        do {
                            let items = try await EventService.shared.fetchRegistryItems(eventID: event.id)
                            var totalTarget = 0.0
                            var totalRaised = 0.0
                            for item in items {
                                totalTarget += item.price * Double(item.quantityNeeded ?? 1)
                                if let funded = item.fundedAmount, funded > 0 {
                                    totalRaised += funded
                                } else {
                                    totalRaised += item.price * Double(item.quantityPurchased ?? 0)
                                }
                            }
                            let progress = totalTarget > 0 ? min(totalRaised / totalTarget, 1.0) : 0.0
                            return (event.id, progress)
                        } catch {
                            print("⚠️ Failed to load progress for event \(event.id): \(error)")
                            return (event.id, 0.0)
                        }
                    }
                }
                
                for await (eventId, progress) in group {
                    progresses[eventId] = progress
                }
            }
            
            self.friendEvents = events
            self.pendingInvites = invites
            self.eventProgresses = progresses
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
            
            // Calculate progress for this new active event
            let items = try await EventService.shared.fetchRegistryItems(eventID: event.id)
            var totalTarget = 0.0
            var totalRaised = 0.0
            for item in items {
                totalTarget += item.price * Double(item.quantityNeeded ?? 1)
                if let funded = item.fundedAmount, funded > 0 {
                    totalRaised += funded
                } else {
                    totalRaised += item.price * Double(item.quantityPurchased ?? 0)
                }
            }
            let progress = totalTarget > 0 ? min(totalRaised / totalTarget, 1.0) : 0.0
            eventProgresses[event.id] = progress
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
