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
    var isLoading = false
    var errorMessage: String?
    var selectedEventType: EventType?

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
}
