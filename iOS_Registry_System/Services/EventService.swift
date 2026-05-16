//
//  EventService.swift
//  iOS_Registry_System
//
//  Event & registry data service
//

import Foundation

// MARK: - Event Service

@MainActor
final class EventService {

    // MARK: Singleton

    static let shared = EventService()
    private init() {}

    // MARK: - Events

    /// Fetch all events for the current user
    func fetchMyEvents() async throws -> [Event] {
        // TODO: Implement Supabase query
        print("📅 EventService: fetchMyEvents — returning mock data")
        return Event.mockList
    }

    /// Fetch a single event by ID
    func fetchEvent(id: UUID) async throws -> Event? {
        // TODO: Implement Supabase query
        print("📅 EventService: fetchEvent(\(id)) — not yet implemented")
        return Event.mock
    }

    /// Create a new event
    func createEvent(_ event: Event) async throws -> Event {
        // TODO: Implement Supabase insert
        print("📅 EventService: createEvent — not yet implemented")
        return event
    }

    /// Update an existing event
    func updateEvent(_ event: Event) async throws {
        // TODO: Implement Supabase update
        print("📅 EventService: updateEvent — not yet implemented")
    }

    /// Delete an event
    func deleteEvent(id: UUID) async throws {
        // TODO: Implement Supabase delete
        print("📅 EventService: deleteEvent — not yet implemented")
    }

    // MARK: - Registry Items

    /// Fetch registry items for an event
    func fetchRegistryItems(eventID: UUID) async throws -> [RegistryItem] {
        // TODO: Implement Supabase query
        print("📅 EventService: fetchRegistryItems — not yet implemented")
        return [RegistryItem.mock]
    }

    /// Fetch events the user is contributing to
    func fetchFriendEvents() async throws -> [Event] {
        // TODO: Implement Supabase query
        print("📅 EventService: fetchFriendEvents — returning mock data")
        return Event.mockList
    }
}
