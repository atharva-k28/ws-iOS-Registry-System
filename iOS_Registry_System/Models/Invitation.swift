//
//  Invitation.swift
//  iOS_Registry_System
//
//  Model for invitations table
//

import Foundation

struct Invitation: Codable, Identifiable, Hashable {
    let id: UUID
    var eventId: UUID
    var createdBy: UUID?
    var guestName: String?
    var guestEmail: String?
    var guestPhone: String?
    var inviteToken: String?
    var inviteStatus: String?
    var sentAt: Date?
    var acceptedAt: Date?
    var expiresAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "event_id"
        case createdBy = "created_by"
        case guestName = "guest_name"
        case guestEmail = "guest_email"
        case guestPhone = "guest_phone"
        case inviteToken = "invite_token"
        case inviteStatus = "invite_status"
        case sentAt = "sent_at"
        case acceptedAt = "accepted_at"
        case expiresAt = "expires_at"
    }
}
