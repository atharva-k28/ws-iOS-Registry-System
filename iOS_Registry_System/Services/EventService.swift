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
            
            // 1. Try ISO8601DateFormatter
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: dateStr) {
                return date
            }
            
            isoFormatter.formatOptions = [.withInternetDateTime]
            if let date = isoFormatter.date(from: dateStr) {
                return date
            }
            
            // 2. Try DateFormatter with fallback formats
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            let formats = [
                "yyyy-MM-dd HH:mm:ss.SSSX",
                "yyyy-MM-dd HH:mm:ss.SSSZZZZZ",
                "yyyy-MM-dd HH:mm:ss.SSSZ",
                "yyyy-MM-dd HH:mm:ss.SSSSSSX",
                "yyyy-MM-dd HH:mm:ss.SSSSSSZZZZZ",
                "yyyy-MM-dd HH:mm:ss.SSSSSSZ",
                "yyyy-MM-dd HH:mm:ssX",
                "yyyy-MM-dd HH:mm:ssZZZZZ",
                "yyyy-MM-dd HH:mm:ssZ",
                "yyyy-MM-dd'T'HH:mm:ss.SSSX",
                "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ",
                "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSX",
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ",
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ",
                "yyyy-MM-dd'T'HH:mm:ssX",
                "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
                "yyyy-MM-dd'T'HH:mm:ssZ",
                "yyyy-MM-dd"
            ]
            
            for format in formats {
                formatter.dateFormat = format
                if let date = formatter.date(from: dateStr) {
                    return date
                }
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
        do {
            let registryResponse = try await SupabaseManager.shared.client
                .from("registries")
                .select("id")
                .eq("event_id", value: eventID.uuidString)
                .single()
                .execute()
                
            let registryIdMap = try JSONSerialization.jsonObject(with: registryResponse.data) as? [String: Any]
            guard let registryId = registryIdMap?["id"] as? String else {
                print("⚠️ Registry ID was empty or missing 'id' key for event \(eventID)")
                return []
            }

            let response = try await SupabaseManager.shared.client
                .from("registry_items")
                .select()
                .eq("registry_id", value: registryId)
                .execute()
                
            return try decoder.decode([RegistryItem].self, from: response.data)
        } catch {
            print("❌ Failed to fetch registry items in EventService: \(error)")
            throw error
        }
    }

    /// Fetch events the user is contributing to (accepted only)
    func fetchFriendEvents() async throws -> [Event] {
        guard let userId = AuthService.shared.currentUser?.id else {
            return []
        }
        let memberResponse = try await SupabaseManager.shared.client
            .from("event_members")
            .select("events(*)")
            .eq("user_id", value: userId.uuidString)
            .eq("status", value: "accepted")
            .execute()
            
        struct EventMemberJoin: Codable {
            let events: Event?
        }
        
        let members = try decoder.decode([EventMemberJoin].self, from: memberResponse.data)
        return members.compactMap { $0.events }
    }

    /// Fetch pending invites for the current user
    func fetchPendingInvites() async throws -> [Event] {
        guard let userId = AuthService.shared.currentUser?.id else {
            return []
        }
        let memberResponse = try await SupabaseManager.shared.client
            .from("event_members")
            .select("events(*)")
            .eq("user_id", value: userId.uuidString)
            .eq("status", value: "pending")
            .execute()
            
        struct EventMemberJoin: Codable {
            let events: Event?
        }
        
        let members = try decoder.decode([EventMemberJoin].self, from: memberResponse.data)
        return members.compactMap { $0.events }
    }

    /// Accept a pending invite
    func acceptInvite(eventId: UUID) async throws {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        try await SupabaseManager.shared.client
            .from("event_members")
            .update(["status": "accepted"])
            .eq("event_id", value: eventId.uuidString)
            .eq("user_id", value: userId.uuidString)
            .execute()
    }

    /// Decline a pending invite (removes the record)
    func declineInvite(eventId: UUID) async throws {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        try await SupabaseManager.shared.client
            .from("event_members")
            .delete()
            .eq("event_id", value: eventId.uuidString)
            .eq("user_id", value: userId.uuidString)
            .execute()
    }

    /// Add a collaborator (user) to an event
    func addCollaborator(eventId: UUID, userId: UUID) async throws {
        struct EventMemberInsert: Codable {
            let id: UUID
            let event_id: UUID
            let user_id: UUID
            let membership_type: String
            let status: String
        }
        
        let insert = EventMemberInsert(
            id: UUID(),
            event_id: eventId,
            user_id: userId,
            membership_type: "collaborator",
            status: "pending"
        )
        let _ = try await SupabaseManager.shared.client
            .from("event_members")
            .insert(insert)
            .execute()
    }

    /// Fetch user IDs already invited to an event
    func fetchEventMemberUserIds(eventId: UUID) async throws -> Set<UUID> {
        let response = try await SupabaseManager.shared.client
            .from("event_members")
            .select("user_id")
            .eq("event_id", value: eventId.uuidString)
            .execute()
        
        struct MemberUserId: Codable {
            let user_id: UUID?
        }
        let members = try decoder.decode([MemberUserId].self, from: response.data)
        return Set(members.compactMap { $0.user_id })
    }

    /// Helper to get or dynamically create a registry for an event
    func getOrCreateRegistryID(for eventId: UUID) async throws -> UUID {
        // 1. Try to fetch the registry
        let response = try? await SupabaseManager.shared.client
            .from("registries")
            .select("id")
            .eq("event_id", value: eventId.uuidString)
            .single()
            .execute()
            
        if let response = response,
           let registryIdMap = try? JSONSerialization.jsonObject(with: response.data) as? [String: String],
           let registryIdString = registryIdMap["id"],
           let registryId = UUID(uuidString: registryIdString) {
            return registryId
        }
        
        // Fetch event to get title
        let event = try? await fetchEvent(id: eventId)
        let eventTitle = event?.title ?? "My Event"
        
        // 2. If it doesn't exist, create it programmatically
        let newRegistryId = UUID()
        struct RegistryInsert: Codable {
            let id: UUID
            let event_id: UUID
            let title: String
            let description: String?
        }
        let insertData = RegistryInsert(
            id: newRegistryId,
            event_id: eventId,
            title: "\(eventTitle) Registry",
            description: "Gift registry for \(eventTitle)"
        )
        
        let _ = try await SupabaseManager.shared.client
            .from("registries")
            .insert(insertData)
            .execute()
            
        return newRegistryId
    }

    /// Add a product to the registry of an event
    func addProductToRegistry(eventId: UUID, product: Product) async throws {
        // Pre-emptively insert/upsert the product record into "products" table to satisfy foreign key constraints
        do {
            let _ = try await SupabaseManager.shared.client
                .from("products")
                .upsert(product)
                .execute()
        } catch {
            print("⚠️ Pre-emptive product upsert: \(error)")
        }

        let registryId = try await getOrCreateRegistryID(for: eventId)
        
        // Check if already in the registry to prevent duplicates
        let existingResponse = try? await SupabaseManager.shared.client
            .from("registry_items")
            .select("id")
            .eq("registry_id", value: registryId.uuidString)
            .eq("product_id", value: product.id.uuidString)
            .execute()
            
        if let data = existingResponse?.data,
           let items = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
           !items.isEmpty {
            // Already added, skip
            return
        }
        
        let registryItemId = UUID()
        let insertItem = RegistryItem(
            id: registryItemId,
            registryId: registryId,
            addedBy: AuthService.shared.currentUser?.id,
            itemName: product.name,
            itemLink: product.productUrl,
            imageUrl: product.imageUrl,
            price: product.price,
            priority: "medium",
            quantityNeeded: 1,
            quantityReserved: 0,
            quantityPurchased: 0,
            fundedAmount: 0.0,
            isCashFund: false,
            reservationsEnabled: true,
            createdAt: nil,
            updatedAt: nil,
            productId: product.id,
            sku: product.sku,
            isBestSeller: product.isBestSeller,
            isFreeShipping: product.isFreeShipping
        )
        
        let _ = try await SupabaseManager.shared.client
            .from("registry_items")
            .insert(insertItem)
            .execute()
    }

    /// Remove a product from the registry of an event
    func removeProductFromRegistry(eventId: UUID, productId: UUID) async throws {
        let registryId = try await getOrCreateRegistryID(for: eventId)
        let _ = try await SupabaseManager.shared.client
            .from("registry_items")
            .delete()
            .eq("registry_id", value: registryId.uuidString)
            .eq("product_id", value: productId.uuidString)
            .execute()
    }

    /// Purchase a registry item by updating its quantity_purchased and funded_amount
    func purchaseRegistryItem(id: UUID, quantityPurchasedDelta: Int, totalAmount: Double, isCashFund: Bool) async throws {
        // 1. Fetch current details
        let currentItemResponse = try await SupabaseManager.shared.client
            .from("registry_items")
            .select("quantity_purchased, funded_amount")
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            
        let itemMap = try JSONSerialization.jsonObject(with: currentItemResponse.data) as? [String: Any]
        let currentPurchased = itemMap?["quantity_purchased"] as? Int ?? 0
        let currentFunded = itemMap?["funded_amount"] as? Double ?? 0.0
        
        let newPurchased = currentPurchased + quantityPurchasedDelta
        let newFunded = currentFunded + totalAmount
        
        // 2. Update database using type-safe Encodable structures
        if isCashFund {
            struct CashFundUpdate: Encodable {
                let quantity_purchased: Int
                let funded_amount: Double
            }
            let updateObj = CashFundUpdate(quantity_purchased: newPurchased, funded_amount: newFunded)
            try await SupabaseManager.shared.client
                .from("registry_items")
                .update(updateObj)
                .eq("id", value: id.uuidString)
                .execute()
        } else {
            struct PhysicalUpdate: Encodable {
                let quantity_purchased: Int
            }
            let updateObj = PhysicalUpdate(quantity_purchased: newPurchased)
            try await SupabaseManager.shared.client
                .from("registry_items")
                .update(updateObj)
                .eq("id", value: id.uuidString)
                .execute()
        }
    }

    /// Contribute an amount to a group-gifting registry item and mark as purchased if fully funded
    func contributeToRegistryItem(id: UUID, amount: Double) async throws {
        // 1. Fetch current details
        let currentItemResponse = try await SupabaseManager.shared.client
            .from("registry_items")
            .select("price, quantity_needed, quantity_purchased, funded_amount")
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            
        let itemMap = try JSONSerialization.jsonObject(with: currentItemResponse.data) as? [String: Any]
        let price = itemMap?["price"] as? Double ?? 0.0
        let quantityNeeded = itemMap?["quantity_needed"] as? Int ?? 1
        let currentPurchased = itemMap?["quantity_purchased"] as? Int ?? 0
        let currentFunded = itemMap?["funded_amount"] as? Double ?? 0.0
        
        let newFunded = currentFunded + amount
        let targetAmount = price * Double(quantityNeeded)
        
        // If it completes full contribution, we also mark quantity_purchased = quantity_needed
        let newPurchased = newFunded >= targetAmount ? quantityNeeded : currentPurchased
        
        struct GroupGiftingUpdate: Encodable {
            let funded_amount: Double
            let quantity_purchased: Int
        }
        
        let updateObj = GroupGiftingUpdate(funded_amount: newFunded, quantity_purchased: newPurchased)
        
        try await SupabaseManager.shared.client
            .from("registry_items")
            .update(updateObj)
            .eq("id", value: id.uuidString)
            .execute()
    }
}
