//
//  AIPlannerSession.swift
//  iOS_Registry_System
//
//  Model for ai_planner_sessions table
//

import Foundation
import Supabase

struct AIPlannerSession: Codable, Identifiable, Hashable {
    let id: UUID
    var registryId: UUID
    var userId: UUID
    var eventContext: String?
    var suggestedItems: [String: AnyJSON]?
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case registryId = "registry_id"
        case userId = "user_id"
        case eventContext = "event_context"
        case suggestedItems = "suggested_items"
        case createdAt = "created_at"
    }
}
