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

    static let mockList: [Product] = [
        .mock,
        Product(
            id: UUID(),
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
            id: UUID(),
            name: "Aesop Reverence Kit",
            brand: "Aesop",
            productDescription: "Hand care duo with aromatique balm",
            price: 89.00,
            imageURL: nil,
            category: "Wellness",
            affiliateURL: nil,
            isAIRecommended: true
        )
    ]
}
