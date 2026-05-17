//
//  GiftReservation.swift
//  iOS_Registry_System
//
//  Model for gift_reservations table
//

import Foundation

struct GiftReservation: Codable, Identifiable, Hashable {
    let id: UUID
    var registryItemId: UUID
    var reservedBy: UUID?
    var quantity: Int?
    var reservationStatus: String?
    var isPurchased: Bool?
    var purchasedAt: Date?
    var expiresAt: Date?
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case registryItemId = "registry_item_id"
        case reservedBy = "reserved_by"
        case quantity
        case reservationStatus = "reservation_status"
        case isPurchased = "is_purchased"
        case purchasedAt = "purchased_at"
        case expiresAt = "expires_at"
        case createdAt = "created_at"
    }
}
