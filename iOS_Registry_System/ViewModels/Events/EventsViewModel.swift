//
//  EventsViewModel.swift
//  iOS_Registry_System
//
//  My Events screen view model
//

import SwiftUI

// MARK: - Events View Model

@MainActor
@Observable
final class EventsViewModel {

    // MARK: State

    var myEvents: [Event] = []
    var pendingCollaboratorInvites: [Event] = []
    var isLoading = false
    var errorMessage: String?
    var selectedEventType: EventType?
    
    struct EventDashboardStats {
        var completePercentage: Int = 0
        var raisedAmount: Double = 0.0
        var guestsCount: Int = 0
        var recentActivity: [Contributor] = []
    }
    
    var eventStats: [UUID: EventDashboardStats] = [:]

    // MARK: Computed

    var filteredEvents: [Event] {
        guard let filter = selectedEventType else { return myEvents }
        return myEvents.filter { $0.eventType == filter.rawValue }
    }

    // MARK: - Actions

    func loadEvents() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            myEvents = try await EventService.shared.fetchMyEvents()
            pendingCollaboratorInvites = try await EventService.shared.fetchPendingCollaboratorInvites()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func acceptCollaboratorInvite(_ event: Event) async {
        do {
            try await EventService.shared.acceptInvite(eventId: event.id)
            pendingCollaboratorInvites.removeAll { $0.id == event.id }
            myEvents = try await EventService.shared.fetchMyEvents()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func declineCollaboratorInvite(_ event: Event) async {
        do {
            try await EventService.shared.declineInvite(eventId: event.id)
            pendingCollaboratorInvites.removeAll { $0.id == event.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteEvent(_ event: Event) async {
        do {
            try await EventService.shared.deleteEvent(id: event.id)
            myEvents.removeAll { $0.id == event.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func selectFilter(_ type: EventType?) {
        selectedEventType = type
    }
    
    func loadStats(for event: Event) async {
        do {
            let items = try await EventService.shared.fetchRegistryItems(eventID: event.id)
            let itemIds = items.map { $0.id }
            
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
            
            let percentage = totalTarget > 0 ? min(totalRaised / totalTarget, 1.0) : 0.0
            
            let members = try await EventService.shared.fetchEventMembersWithUsers(eventId: event.id)
            let guestCount = members.filter { $0.member.membershipType == "guest" }.count
            
            var activity: [Contributor] = []
            if !itemIds.isEmpty {
                let allReservations = try await EventService.shared.fetchAllReservationsForRegistryItems(itemIds: itemIds)
                let contributions = try await EventService.shared.fetchContributionsForRegistryItems(itemIds: itemIds)
                
                let contributionResIds = Set(contributions.map { $0.reservationId })
                let purchases = allReservations.filter { $0.isPurchased == true && !contributionResIds.contains($0.id) }
                
                var userIds = Set<UUID>()
                purchases.forEach { if let u = $0.reservedBy { userIds.insert(u) } }
                contributions.forEach { if let u = $0.contributorBy { userIds.insert(u) } }
                
                let users = try await EventService.shared.fetchUsers(ids: Array(userIds))
                let userMap = Dictionary(uniqueKeysWithValues: users.map { ($0.id, $0) })
                
                let itemMap = Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
                let reservationToItemMap = Dictionary(uniqueKeysWithValues: allReservations.map { ($0.id, $0.registryItemId) })
                
                for p in purchases {
                    guard let userId = p.reservedBy, let u = userMap[userId] else { continue }
                    guard let item = itemMap[p.registryItemId] else { continue }
                    activity.append(Contributor(
                        id: p.id,
                        name: u.fullName,
                        avatarURL: u.avatarUrl,
                        amount: item.price * Double(p.quantity ?? 1),
                        timeAgo: p.createdAt?.daysUntil ?? "Recently",
                        itemName: item.itemName,
                        date: p.createdAt
                    ))
                }
                
                for c in contributions {
                    guard let userId = c.contributorBy, let u = userMap[userId] else { continue }
                    let itemName = reservationToItemMap[c.reservationId].flatMap { itemMap[$0]?.itemName }
                    activity.append(Contributor(
                        id: c.id,
                        name: u.fullName,
                        avatarURL: u.avatarUrl,
                        amount: c.amount,
                        timeAgo: c.createdAt?.daysUntil ?? "Recently",
                        itemName: itemName,
                        date: c.createdAt
                    ))
                }
                
                // Sort by date descending (most recent first)
                activity.sort { ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast) }
            }
            
            eventStats[event.id] = EventDashboardStats(
                completePercentage: Int(percentage * 100),
                raisedAmount: totalRaised,
                guestsCount: guestCount,
                recentActivity: activity
            )
            
        } catch {
            print("Failed to load stats for event: \(error)")
        }
    }
}
