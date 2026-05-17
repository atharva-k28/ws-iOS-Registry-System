//
//  Registry.swift
//  iOS_Registry_System
//
//  Registry model matching the registries table schema
//

import Foundation

struct Registry: Codable, Identifiable, Hashable {
    let id: UUID
    var eventId: UUID
    var title: String
    var description: String?
    var shareCode: String?
    var qrCodeUrl: String?
    var isPublic: Bool?
    var status: String?
    var createdAt: Date?
    var registrantFirstName: String?
    var registrantLastName: String?
    var registrantAddress: String?
    var registrantAddress2: String?
    var registrantCity: String?
    var registrantState: String?
    var registrantZip: String?
    var registrantPhone: String?
    var shipToDifferentAddress: Bool?
    var shipAddress: String?
    var shipAddress2: String?
    var shipCity: String?
    var shipState: String?
    var shipZip: String?
    var visibility: String?
    var textNotificationsEnabled: Bool?
    var guestMessage: String?
    var completionDiscountUsed: Bool?
    var completionDiscountPct: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case eventId = "event_id"
        case title
        case description
        case shareCode = "share_code"
        case qrCodeUrl = "qr_code_url"
        case isPublic = "is_public"
        case status
        case createdAt = "created_at"
        case registrantFirstName = "registrant_first_name"
        case registrantLastName = "registrant_last_name"
        case registrantAddress = "registrant_address"
        case registrantAddress2 = "registrant_address2"
        case registrantCity = "registrant_city"
        case registrantState = "registrant_state"
        case registrantZip = "registrant_zip"
        case registrantPhone = "registrant_phone"
        case shipToDifferentAddress = "ship_to_different_address"
        case shipAddress = "ship_address"
        case shipAddress2 = "ship_address2"
        case shipCity = "ship_city"
        case shipState = "ship_state"
        case shipZip = "ship_zip"
        case visibility
        case textNotificationsEnabled = "text_notifications_enabled"
        case guestMessage = "guest_message"
        case completionDiscountUsed = "completion_discount_used"
        case completionDiscountPct = "completion_discount_pct"
    }
}
