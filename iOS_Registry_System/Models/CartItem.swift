//
//  CartItem.swift
//  iOS_Registry_System
//
//  Model for an item in the shopping cart
//

import Foundation

struct CartItem: Identifiable, Codable {
    var id: UUID = UUID()
    var userId: UUID
    var productId: UUID
    var quantity: Int = 1
    var isSavedForLater: Bool? = nil
    var deliveryGroup: String? = nil
    var registryId: UUID? = nil
    var addedAt: Date? = nil
    
    // UI Convenience properties
    var product: Product? = nil
    var registryItem: RegistryItem? = nil
    var eventName: String? = nil

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case productId = "product_id"
        case quantity
        case isSavedForLater = "is_saved_for_later"
        case deliveryGroup = "delivery_group"
        case registryId = "registry_id"
        case addedAt = "added_at"
    }
}
