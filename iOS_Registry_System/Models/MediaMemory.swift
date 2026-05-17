//
//  MediaMemory.swift
//  iOS_Registry_System
//
//  Model for media_memories table
//

import Foundation
import Supabase

struct MediaMemory: Codable, Identifiable, Hashable {
    let id: UUID
    var eventId: UUID
    var registryItemId: UUID?
    var uploadedBy: UUID?
    var mediaUrl: String?
    var mediaType: String?
    var contributorsSnapshot: [String: AnyJSON]?
    var eventTheme: String?
    var generatedAt: Date?
    var uploadedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "event_id"
        case registryItemId = "registry_item_id"
        case uploadedBy = "uploaded_by"
        case mediaUrl = "media_url"
        case mediaType = "media_type"
        case contributorsSnapshot = "contributors_snapshot"
        case eventTheme = "event_theme"
        case generatedAt = "generated_at"
        case uploadedAt = "uploaded_at"
    }
}
