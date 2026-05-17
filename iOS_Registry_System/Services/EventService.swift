//
//  EventService.swift
//  iOS_Registry_System
//
//  Event & registry data service
//

import Foundation
import Supabase

// MARK: - Event Service

@MainActor
final class EventService {

    // MARK: Singleton

    static let shared = EventService()
    private init() {}

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: dateStr) {
                return date
            }
            
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateStr) {
                return date
            }
            
            // Fallback for date-only strings (e.g. "2026-05-17")
            let simpleFormatter = DateFormatter()
            simpleFormatter.dateFormat = "yyyy-MM-dd"
            if let date = simpleFormatter.date(from: dateStr) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateStr)")
        }
        return decoder
    }

    // MARK: - Events

    /// Fetch all events for the current user
    func fetchMyEvents() async throws -> [Event] {
        guard let userId = AuthService.shared.currentUser?.id else {
            return []
        }
        let response = try await SupabaseManager.shared.client
            .from("events")
            .select()
            .eq("owner_user_id", value: userId.uuidString)
            .execute()
        return try decoder.decode([Event].self, from: response.data)
    }

    /// Fetch a single event by ID
    func fetchEvent(id: UUID) async throws -> Event? {
        let response = try await SupabaseManager.shared.client
            .from("events")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
        return try decoder.decode(Event.self, from: response.data)
    }

    /// Create a new event
    func createEvent(_ event: Event) async throws -> Event {
        let response = try await SupabaseManager.shared.client
            .from("events")
            .insert(event)
            .select()
            .single()
            .execute()
        return try decoder.decode(Event.self, from: response.data)
    }

    /// Update an existing event
    func updateEvent(_ event: Event) async throws {
        try await SupabaseManager.shared.client
            .from("events")
            .update(event)
            .eq("id", value: event.id.uuidString)
            .execute()
    }

    /// Delete an event
    func deleteEvent(id: UUID) async throws {
        try await SupabaseManager.shared.client
            .from("events")
            .delete()
            .eq("id", value: id.uuidString)
            .execute()
    }

    // MARK: - Registry Items

    /// Fetch registry items for an event
    func fetchRegistryItems(eventID: UUID) async throws -> [RegistryItem] {
        // First get the registry for the event
        let registryResponse = try? await SupabaseManager.shared.client
            .from("registries")
            .select("id")
            .eq("event_id", value: eventID.uuidString)
            .single()
            .execute()
            
        guard let registryData = registryResponse?.data,
              let registryIdMap = try? JSONSerialization.jsonObject(with: registryData) as? [String: String],
              let registryId = registryIdMap["id"] else {
            return []
        }

        let response = try await SupabaseManager.shared.client
            .from("registry_items")
            .select()
            .eq("registry_id", value: registryId)
            .execute()
        return try JSONDecoder().decode([RegistryItem].self, from: response.data)
    }

    /// Fetch events the user is contributing to
    func fetchFriendEvents() async throws -> [Event] {
        guard let userId = AuthService.shared.currentUser?.id else {
            return []
        }
        // This requires a join query or fetching contributions and mapping.
        // Assuming there's a view or doing a simple select from event_members for now.
        let memberResponse = try await SupabaseManager.shared.client
            .from("event_members")
            .select("events(*)")
            .eq("user_id", value: userId.uuidString)
            .execute()
            
        struct EventMember: Codable {
            let events: Event?
        }
        
        let members = try JSONDecoder().decode([EventMember].self, from: memberResponse.data)
        return members.compactMap { $0.events }
    }
}
