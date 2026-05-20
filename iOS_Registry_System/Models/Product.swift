//
//  Product.swift
//  iOS_Registry_System
//
//  Product / Gift item model
//

import Foundation

// MARK: - Product

struct Product: Codable, Identifiable, Hashable {
    let id: UUID
    var sku: String? = nil
    var name: String
    var description: String? = nil
    var brand: String? = nil
    var category: String
    var subcategory: String? = nil
    var price: Double
    var salePrice: Double? = nil
    var originalPrice: Double? = nil
    var isSale: Bool? = nil
    var saleLabel: String? = nil
    var isBestSeller: Bool? = nil
    var isExclusive: Bool? = nil
    var isFreeShipping: Bool? = nil
    var isPickupAvailable: Bool? = nil
    var isInStore: Bool? = nil
    var imageUrl: String? = nil
    var productUrl: String? = nil
    var isActive: Bool? = nil
    var isRegistryEligible: Bool? = nil
    var isGiftEligible: Bool? = nil
    var width: Double? = nil
    var height: Double? = nil
    var depth: Double? = nil
    var createdAt: Date? = nil

    enum CodingKeys: String, CodingKey {
        case id
        case sku
        case name
        case description
        case brand
        case category
        case subcategory
        case price
        case salePrice = "sale_price"
        case originalPrice = "original_price"
        case isSale = "is_sale"
        case saleLabel = "sale_label"
        case isBestSeller = "is_best_seller"
        case isExclusive = "is_exclusive"
        case isFreeShipping = "is_free_shipping"
        case isPickupAvailable = "is_pickup_available"
        case isInStore = "is_in_store"
        case imageUrl = "image_url"
        case productUrl = "product_url"
        case isActive = "is_active"
        case isRegistryEligible = "is_registry_eligible"
        case isGiftEligible = "is_gift_eligible"
        case width
        case height
        case depth
        case createdAt = "created_at"
    }
}
