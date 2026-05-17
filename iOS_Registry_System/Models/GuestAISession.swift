//
//  GuestAISession.swift
//  iOS_Registry_System
//
//  Model for guest_ai_sessions table
//

import Foundation
import Supabase

struct GuestAISession: Codable, Identifiable, Hashable {
    let id: UUID
    var registryId: UUID
    var guestId: UUID
    var budgetMax: Double?
    var relationshipToHost: String?
    var suggestedGifts: [String: AnyJSON]?
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case registryId = "registry_id"
        case guestId = "guest_id"
        case budgetMax = "budget_max"
        case relationshipToHost = "relationship_to_host"
        case suggestedGifts = "suggested_gifts"
        case createdAt = "created_at"
    }
}
