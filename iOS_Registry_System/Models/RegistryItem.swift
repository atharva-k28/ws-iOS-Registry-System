//
//  RegistryItem.swift
//  iOS_Registry_System
//
//  Registry item — links a product to an event
//

import Foundation

// MARK: - Registry Item

struct RegistryItem: Codable, Identifiable, Hashable {
    let id: UUID
    var registryId: UUID
    var addedBy: UUID?
    var itemName: String
    var itemLink: String?
    var imageUrl: String?
    var price: Double
    var priority: String?
    var quantityNeeded: Int?
    var quantityReserved: Int?
    var quantityPurchased: Int?
    var fundedAmount: Double?
    var isCashFund: Bool?
    var reservationsEnabled: Bool?
    var createdAt: Date?
    var updatedAt: Date?
    var productId: UUID?
    var sku: String?
    var isBestSeller: Bool?
    var isFreeShipping: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case registryId = "registry_id"
        case addedBy = "added_by"
        case itemName = "item_name"
        case itemLink = "item_link"
        case imageUrl = "image_url"
        case price
        case priority
        case quantityNeeded = "quantity_needed"
        case quantityReserved = "quantity_reserved"
        case quantityPurchased = "quantity_purchased"
        case fundedAmount = "funded_amount"
        case isCashFund = "is_cash_fund"
        case reservationsEnabled = "reservations_enabled"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case productId = "product_id"
        case sku
        case isBestSeller = "is_best_seller"
        case isFreeShipping = "is_free_shipping"
    }

    /// Progress from 0.0 to 1.0 (requires calculating targetAmount from price * quantityNeeded)
    var progress: Double {
        let targetAmount = price * Double(quantityNeeded ?? 1)
        guard targetAmount > 0 else { return 0 }
        return min((fundedAmount ?? 0) / targetAmount, 1.0)
    }
}
