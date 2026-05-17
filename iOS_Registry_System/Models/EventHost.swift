//
//  EventHost.swift
//  iOS_Registry_System
//
//  Model for event_hosts table
//

import Foundation

struct EventHost: Codable, Identifiable, Hashable {
    let id: UUID
    var eventId: UUID
    var userId: UUID
    var label: String?
    var addedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "event_id"
        case userId = "user_id"
        case label
        case addedAt = "added_at"
    }
}
