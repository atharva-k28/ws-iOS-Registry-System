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
    var name: String
    var brand: String?
    var productDescription: String?
    var price: Double
    var imageURL: String?
    var category: String?
    var affiliateURL: String?
    var isAIRecommended: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case brand
        case productDescription = "description"
        case price
        case imageURL = "image_url"
        case category
        case affiliateURL = "affiliate_url"
        case isAIRecommended = "is_ai_recommended"
    }
}

// MARK: - Mock

extension Product {
    static let mock = Product(
        id: UUID(),
        name: "Le Creuset Dutch Oven",
        brand: "Le Creuset",
        productDescription: "Classic 5.5 Qt Round Dutch Oven in Marseille",
        price: 419.95,
        imageURL: nil,
        category: "Kitchen",
        affiliateURL: nil,
        isAIRecommended: true
    )

    // Stable IDs for cross-referencing with RegistryItem mocks
    static let mockID1 = UUID(uuidString: "A0000001-0000-0000-0000-000000000001")!
    static let mockID2 = UUID(uuidString: "A0000001-0000-0000-0000-000000000002")!
    static let mockID3 = UUID(uuidString: "A0000001-0000-0000-0000-000000000003")!
    static let mockID4 = UUID(uuidString: "A0000001-0000-0000-0000-000000000004")!
    static let mockID5 = UUID(uuidString: "A0000001-0000-0000-0000-000000000005")!
    static let mockID6 = UUID(uuidString: "A0000001-0000-0000-0000-000000000006")!

    static let mockList: [Product] = [
        Product(
            id: mockID1,
            name: "Le Creuset Dutch Oven",
            brand: "Le Creuset",
            productDescription: "Classic 5.5 Qt Round Dutch Oven in Marseille",
            price: 419.95,
            imageURL: nil,
            category: "Kitchen",
            affiliateURL: nil,
            isAIRecommended: true
        ),
        Product(
            id: mockID2,
            name: "Dyson V15 Detect",
            brand: "Dyson",
            productDescription: "Cordless vacuum with laser dust detection",
            price: 749.99,
            imageURL: nil,
            category: "Home",
            affiliateURL: nil,
            isAIRecommended: false
        ),
        Product(
            id: mockID3,
            name: "Aesop Reverence Kit",
            brand: "Aesop",
            productDescription: "Hand care duo with aromatique balm",
            price: 89.00,
            imageURL: nil,
            category: "Wellness",
            affiliateURL: nil,
            isAIRecommended: true
        ),
        Product(
            id: mockID4,
            name: "Riedel Vinum Set",
            brand: "Riedel",
            productDescription: "Set of 8 crystal wine glasses for red & white",
            price: 239.00,
            imageURL: nil,
            category: "Dining",
            affiliateURL: nil,
            isAIRecommended: false
        ),
        Product(
            id: mockID5,
            name: "Breville Barista Express",
            brand: "Breville",
            productDescription: "Espresso machine with integrated grinder",
            price: 699.95,
            imageURL: nil,
            category: "Kitchen",
            affiliateURL: nil,
            isAIRecommended: true
        ),
        Product(
            id: mockID6,
            name: "Parachute Linen Duvet",
            brand: "Parachute",
            productDescription: "European flax linen duvet cover, king size",
            price: 329.00,
            imageURL: nil,
            category: "Home",
            affiliateURL: nil,
            isAIRecommended: false
        ),
    ]
}
