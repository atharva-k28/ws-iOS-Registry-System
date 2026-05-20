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

    /// Fetch all events for the current user (owned or accepted collaborator)
    func fetchMyEvents() async throws -> [Event] {
        guard let userId = AuthService.shared.currentUser?.id else {
            return []
        }
        
        // 1. Fetch events owned by the user
        let ownedResponse = try await SupabaseManager.shared.client
            .from("events")
            .select()
            .eq("owner_user_id", value: userId.uuidString)
            .execute()
        let ownedEvents = try decoder.decode([Event].self, from: ownedResponse.data)
        
        // 2. Fetch events where user is collaborator (status accepted)
        let memberResponse = try await SupabaseManager.shared.client
            .from("event_members")
            .select("events(*)")
            .eq("user_id", value: userId.uuidString)
            .eq("membership_type", value: "collaborator")
            .eq("status", value: "accepted")
            .execute()
            
        struct EventMemberJoin: Codable {
            let events: Event?
        }
        let joined = try decoder.decode([EventMemberJoin].self, from: memberResponse.data)
        let collabEvents = joined.compactMap { $0.events }
        
        // Combine them (unique by id)
        var allEvents = ownedEvents
        for event in collabEvents {
            if !allEvents.contains(where: { $0.id == event.id }) {
                allEvents.append(event)
            }
        }
        return allEvents
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
        let registryId: String
        do {
            let registryResponse = try await SupabaseManager.shared.client
                .from("registries")
                .select("id")
                .eq("event_id", value: eventID.uuidString)
                .single()
                .execute()
                
            let registryIdMap = try JSONSerialization.jsonObject(with: registryResponse.data) as? [String: Any]
            guard let id = registryIdMap?["id"] as? String else {
                print("⚠️ Registry ID was empty or missing 'id' key for event \(eventID)")
                return []
            }
            registryId = id
        } catch {
            print("⚠️ Registry does not exist yet for event \(eventID): \(error)")
            return []
        }

        do {
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

    /// Fetch completed purchases/reservations for a list of registry items
    func fetchPurchasesForRegistryItems(itemIds: [UUID]) async throws -> [GiftReservation] {
        guard !itemIds.isEmpty else { return [] }
        let idStrings = itemIds.map { $0.uuidString }
        let response = try await SupabaseManager.shared.client
            .from("gift_reservations")
            .select()
            .in("registry_item_id", values: idStrings)
            .eq("is_purchased", value: true)
            .execute()
        return try decoder.decode([GiftReservation].self, from: response.data)
    }

    /// Fetch all reservations (both active and completed) for a list of registry items
    func fetchAllReservationsForRegistryItems(itemIds: [UUID]) async throws -> [GiftReservation] {
        guard !itemIds.isEmpty else { return [] }
        let idStrings = itemIds.map { $0.uuidString }
        let response = try await SupabaseManager.shared.client
            .from("gift_reservations")
            .select()
            .in("registry_item_id", values: idStrings)
            .execute()
        return try decoder.decode([GiftReservation].self, from: response.data)
    }

    /// Fetch contributions for a list of registry items (requires fetching reservations first)
    func fetchContributionsForRegistryItems(itemIds: [UUID]) async throws -> [Contribution] {
        guard !itemIds.isEmpty else { return [] }
        let idStrings = itemIds.map { $0.uuidString }
        let resResponse = try await SupabaseManager.shared.client
            .from("gift_reservations")
            .select("id")
            .in("registry_item_id", values: idStrings)
            .execute()
        
        struct ResID: Codable { let id: UUID }
        let resIds = try decoder.decode([ResID].self, from: resResponse.data).map { $0.id.uuidString }
        
        guard !resIds.isEmpty else { return [] }
        
        let response = try await SupabaseManager.shared.client
            .from("contributions")
            .select()
            .in("reservation_id", values: resIds)
            .execute()
        return try decoder.decode([Contribution].self, from: response.data)
    }

    /// Fetch users by IDs
    func fetchUsers(ids: [UUID]) async throws -> [User] {
        guard !ids.isEmpty else { return [] }
        let uniqueIds = Array(Set(ids.map { $0.uuidString }))
        let response = try await SupabaseManager.shared.client
            .from("users")
            .select()
            .in("id", values: uniqueIds)
            .execute()
        return try decoder.decode([User].self, from: response.data)
    }

    /// Fetch invitations for an event
    func fetchInvitations(eventId: UUID) async throws -> [Invitation] {
        let response = try await SupabaseManager.shared.client
            .from("invitations")
            .select()
            .eq("event_id", value: eventId.uuidString)
            .execute()
        return try decoder.decode([Invitation].self, from: response.data)
    }

    /// Fetch event members with joined user data
    func fetchEventMembersWithUsers(eventId: UUID) async throws -> [(member: EventMember, user: User?)] {
        // 1. Fetch all event members
        let memberResponse = try await SupabaseManager.shared.client
            .from("event_members")
            .select()
            .eq("event_id", value: eventId.uuidString)
            .execute()
        let members = try decoder.decode([EventMember].self, from: memberResponse.data)
        
        // 2. Fetch associated users
        let userIds = members.compactMap { $0.userId }
        let users = try await fetchUsers(ids: userIds)
        let userMap = Dictionary(uniqueKeysWithValues: users.map { ($0.id, $0) })
        
        // 3. Pair them
        return members.map { member in
            (member: member, user: member.userId.flatMap { userMap[$0] })
        }
    }

    /// Fetch events the user is contributing to (accepted guests only)
    func fetchFriendEvents() async throws -> [Event] {
        guard let userId = AuthService.shared.currentUser?.id else {
            return []
        }
        let memberResponse = try await SupabaseManager.shared.client
            .from("event_members")
            .select("events(*)")
            .eq("user_id", value: userId.uuidString)
            .eq("membership_type", value: "guest")
            .eq("status", value: "accepted")
            .execute()
            
        struct EventMemberJoin: Codable {
            let events: Event?
        }
        
        let members = try decoder.decode([EventMemberJoin].self, from: memberResponse.data)
        return members.compactMap { $0.events }
    }

    /// Fetch pending invites for the current user (guests only)
    func fetchPendingInvites() async throws -> [Event] {
        guard let userId = AuthService.shared.currentUser?.id else {
            return []
        }
        let memberResponse = try await SupabaseManager.shared.client
            .from("event_members")
            .select("events(*)")
            .eq("user_id", value: userId.uuidString)
            .eq("membership_type", value: "guest")
            .eq("status", value: "pending")
            .execute()
            
        struct EventMemberJoin: Codable {
            let events: Event?
        }
        
        let members = try decoder.decode([EventMemberJoin].self, from: memberResponse.data)
        return members.compactMap { $0.events }
    }

    /// Fetch pending collaborator invites for the current user
    func fetchPendingCollaboratorInvites() async throws -> [Event] {
        guard let userId = AuthService.shared.currentUser?.id else {
            return []
        }
        let memberResponse = try await SupabaseManager.shared.client
            .from("event_members")
            .select("events(*)")
            .eq("user_id", value: userId.uuidString)
            .eq("membership_type", value: "collaborator")
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
            
        // Trigger notification to the collaborator
        try? await NotificationService.shared.createNotification(
            userId: userId,
            type: "new_event",
            title: "Co-host Invitation",
            body: "You've been invited to co-host an event."
        )
    }

    /// Add a guest (user) to an event
    func addGuest(eventId: UUID, userId: UUID) async throws {
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
            membership_type: "guest",
            status: "pending"
        )
        let _ = try await SupabaseManager.shared.client
            .from("event_members")
            .insert(insert)
            .execute()
            
        // Trigger notification to the guest
        try? await NotificationService.shared.createNotification(
            userId: userId,
            type: "new_event",
            title: "Registry Invitation",
            body: "You've been invited to a new registry."
        )
    }

    /// Fetch active collaborators (co-hosts) with user details for an event
    func fetchCollaboratorsWithUsers(eventId: UUID) async throws -> [(member: EventMember, user: User?)] {
        let memberResponse = try await SupabaseManager.shared.client
            .from("event_members")
            .select()
            .eq("event_id", value: eventId.uuidString)
            .eq("membership_type", value: "collaborator")
            .execute()
        let members = try decoder.decode([EventMember].self, from: memberResponse.data)
        
        let userIds = members.compactMap { $0.userId }
        let users = try await fetchUsers(ids: userIds)
        let userMap = Dictionary(uniqueKeysWithValues: users.map { ($0.id, $0) })
        
        return members.map { member in
            (member: member, user: member.userId.flatMap { userMap[$0] })
        }
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

    private func fetchHostIdForRegistryItem(itemId: UUID) async throws -> UUID {
        struct RegistryItemOwnerLookup: Decodable {
            let registry_id: UUID
        }

        struct RegistryOwnerLookup: Decodable {
            let event_id: UUID
        }

        struct EventOwnerLookup: Decodable {
            let owner_user_id: UUID
        }

        let itemResponse = try await SupabaseManager.shared.client
            .from("registry_items")
            .select("registry_id")
            .eq("id", value: itemId.uuidString)
            .single()
            .execute()
        let item = try decoder.decode(RegistryItemOwnerLookup.self, from: itemResponse.data)

        let registryResponse = try await SupabaseManager.shared.client
            .from("registries")
            .select("event_id")
            .eq("id", value: item.registry_id.uuidString)
            .single()
            .execute()
        let registry = try decoder.decode(RegistryOwnerLookup.self, from: registryResponse.data)

        let eventResponse = try await SupabaseManager.shared.client
            .from("events")
            .select("owner_user_id")
            .eq("id", value: registry.event_id.uuidString)
            .single()
            .execute()
        let event = try decoder.decode(EventOwnerLookup.self, from: eventResponse.data)

        return event.owner_user_id
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
                
            // Record cash fund contribution in gift_reservations and contributions
            let currentUserId = AuthService.shared.currentUser?.id
            let reservationId = UUID()
            let dateStr = ISO8601DateFormatter().string(from: Date())
            
            struct GiftReservationInsert: Encodable {
                let id: String
                let registry_item_id: String
                let reserved_by: String?
                let quantity: Int
                let reservation_status: String
                let is_purchased: Bool
                let purchased_at: String
            }
            
            let reservationInsert = GiftReservationInsert(
                id: reservationId.uuidString,
                registry_item_id: id.uuidString,
                reserved_by: currentUserId?.uuidString,
                quantity: quantityPurchasedDelta,
                reservation_status: "completed",
                is_purchased: true,
                purchased_at: dateStr
            )
            
            let _ = try await SupabaseManager.shared.client
                .from("gift_reservations")
                .insert(reservationInsert)
                .execute()
                
            struct ContributionInsert: Encodable {
                let id: String
                let reservation_id: String
                let contributor_by: String?
                let amount: Double
                let contribution_type: String
                let payment_status: String
            }
            
            let contributionInsert = ContributionInsert(
                id: UUID().uuidString,
                reservation_id: reservationId.uuidString,
                contributor_by: currentUserId?.uuidString,
                amount: totalAmount,
                contribution_type: "cash_fund",
                payment_status: "completed"
            )
            
            let _ = try await SupabaseManager.shared.client
                .from("contributions")
                .insert(contributionInsert)
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
                
            // Record physical purchase in gift_reservations
            let currentUserId = AuthService.shared.currentUser?.id
            let reservationId = UUID()
            let dateStr = ISO8601DateFormatter().string(from: Date())
            
            struct GiftReservationInsert: Encodable {
                let id: String
                let registry_item_id: String
                let reserved_by: String?
                let quantity: Int
                let reservation_status: String
                let is_purchased: Bool
                let purchased_at: String
            }
            
            let reservationInsert = GiftReservationInsert(
                id: reservationId.uuidString,
                registry_item_id: id.uuidString,
                reserved_by: currentUserId?.uuidString,
                quantity: quantityPurchasedDelta,
                reservation_status: "completed",
                is_purchased: true,
                purchased_at: dateStr
            )
            
            let _ = try await SupabaseManager.shared.client
                .from("gift_reservations")
                .insert(reservationInsert)
                .execute()
        }
        
        // Notify host about the purchase
        if let hostId = try? await fetchHostIdForRegistryItem(itemId: id) {
            if let currentUserId = AuthService.shared.currentUser?.id, hostId != currentUserId {
                try? await NotificationService.shared.createNotification(
                    userId: hostId,
                    type: "purchase",
                    title: "New Gift Purchased!",
                    body: isCashFund ? "Someone contributed $\(Int(totalAmount)) to your cash fund." : "Someone purchased an item from your registry."
                )
            }
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
            
        // Record contribution in gift_reservations and contributions
        let currentUserId = AuthService.shared.currentUser?.id
        let reservationId = UUID()
        let dateStr = ISO8601DateFormatter().string(from: Date())
        
        struct GiftReservationInsert: Encodable {
            let id: String
            let registry_item_id: String
            let reserved_by: String?
            let quantity: Int
            let reservation_status: String
            let is_purchased: Bool
            let purchased_at: String
        }
        
        let reservationInsert = GiftReservationInsert(
            id: reservationId.uuidString,
            registry_item_id: id.uuidString,
            reserved_by: currentUserId?.uuidString,
            quantity: 1,
            reservation_status: "completed",
            is_purchased: true,
            purchased_at: dateStr
        )
        
        let _ = try await SupabaseManager.shared.client
            .from("gift_reservations")
            .insert(reservationInsert)
            .execute()
            
        struct ContributionInsert: Encodable {
            let id: String
            let reservation_id: String
            let contributor_by: String?
            let amount: Double
            let contribution_type: String
            let payment_status: String
        }
        
        let contributionInsert = ContributionInsert(
            id: UUID().uuidString,
            reservation_id: reservationId.uuidString,
            contributor_by: currentUserId?.uuidString,
            amount: amount,
            contribution_type: "group_gift",
            payment_status: "completed"
        )
        
        let _ = try await SupabaseManager.shared.client
            .from("contributions")
            .insert(contributionInsert)
            .execute()
            
        // Notify host about the contribution
        if let hostId = try? await fetchHostIdForRegistryItem(itemId: id) {
            if hostId != currentUserId {
                try? await NotificationService.shared.createNotification(
                    userId: hostId,
                    type: "contribution",
                    title: "New Group Contribution!",
                    body: "Someone contributed $\(Int(amount)) towards a group gift."
                )
            }
        }
    }
    
    /// Fetch group gifting stats for a product if it is in any of the user's registries and has collaborators
    func fetchGroupGiftingStats(for productId: UUID) async throws -> (currentAmount: Double, targetAmount: Double, contributorsCount: Int)? {
        let events = try await fetchMyEvents()
        for event in events {
            do {
                let registryId = try await getOrCreateRegistryID(for: event.id)
                
                // Fetch the registry item for this product
                let response = try await SupabaseManager.shared.client
                    .from("registry_items")
                    .select("id, price, funded_amount, quantity_needed")
                    .eq("product_id", value: productId.uuidString)
                    .eq("registry_id", value: registryId.uuidString)
                    .execute()
                
                struct MinimalRegistryItem: Codable {
                    let id: UUID
                    let price: Double
                    let funded_amount: Double?
                    let quantity_needed: Int?
                }
                
                let data = response.data
                if let items = try? JSONDecoder().decode([MinimalRegistryItem].self, from: data),
                   let item = items.first {
                    
                    // Fetch reservations to find contributors
                    let reservationsResponse = try await SupabaseManager.shared.client
                        .from("gift_reservations")
                        .select("id")
                        .eq("registry_item_id", value: item.id.uuidString)
                        .execute()
                    
                    struct MinimalReservation: Codable {
                        let id: UUID
                    }
                    
                    var contributorsCount = 0
                    let resData = reservationsResponse.data
                    if let reservations = try? JSONDecoder().decode([MinimalReservation].self, from: resData) {
                        
                        let reservationIds = reservations.map { $0.id.uuidString }
                        if !reservationIds.isEmpty {
                            let contribResponse = try await SupabaseManager.shared.client
                                .from("contributions")
                                .select("contributor_by")
                                .in("reservation_id", values: reservationIds)
                                .execute()
                            
                            struct MinimalContrib: Codable {
                                let contributor_by: UUID?
                            }
                            let cData = contribResponse.data
                            if let contribs = try? JSONDecoder().decode([MinimalContrib].self, from: cData) {
                                // Count unique contributors
                                contributorsCount = Set(contribs.compactMap { $0.contributor_by }).count
                            }
                        }
                    }
                    
                    let target = item.price * Double(item.quantity_needed ?? 1)
                    let current = item.funded_amount ?? 0
                    
                    if contributorsCount > 0 {
                        return (currentAmount: current, targetAmount: target, contributorsCount: contributorsCount)
                    }
                }
            } catch {
                continue
            }
        }
        return nil
    }
}
