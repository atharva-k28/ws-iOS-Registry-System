//
//  EventMember.swift
//  iOS_Registry_System
//
//  Model for event_members table
//

import Foundation

struct EventMember: Codable, Identifiable, Hashable {
    let id: UUID
    var eventId: UUID
    var userId: UUID?
    var membershipType: String?
    var status: String?
    var joinedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "event_id"
        case userId = "user_id"
        case membershipType = "membership_type"
        case status
        case joinedAt = "joined_at"
    }
}
