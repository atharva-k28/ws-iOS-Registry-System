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
    var eventID: UUID
    var productID: UUID
    var targetAmount: Double
    var currentAmount: Double
    var isPurchased: Bool
    var priority: Int
    var note: String?
    var complementaryProductName: String?
    var addedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case eventID = "event_id"
        case productID = "product_id"
        case targetAmount = "target_amount"
        case currentAmount = "current_amount"
        case isPurchased = "is_purchased"
        case priority
        case note
        case complementaryProductName = "complementary_product_name"
        case addedAt = "added_at"
    }

    /// Progress from 0.0 to 1.0
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
}

// MARK: - Mock

extension RegistryItem {

    static let mockEventID = UUID(uuidString: "E0000001-0000-0000-0000-000000000001")!

    static let mock = RegistryItem(
        id: UUID(),
        eventID: mockEventID,
        productID: Product.mockID1,
        targetAmount: 419.95,
        currentAmount: 280.00,
        isPurchased: false,
        priority: 1,
        note: "We'd love the Marseille color!",
        addedAt: .now
    )

    static let mockList: [RegistryItem] = [
        RegistryItem(
            id: UUID(),
            eventID: mockEventID,
            productID: Product.mockID1,
            targetAmount: 419.95,
            currentAmount: 280.00,
            isPurchased: false,
            priority: 1,
            note: "We'd love the Marseille color!",
            complementaryProductName: "Dyson V15",
            addedAt: .now
        ),
        RegistryItem(
            id: UUID(),
            eventID: mockEventID,
            productID: Product.mockID2,
            targetAmount: 749.99,
            currentAmount: 749.99,
            isPurchased: true,
            priority: 2,
            note: nil,
            complementaryProductName: nil,
            addedAt: .now
        ),
        RegistryItem(
            id: UUID(),
            eventID: mockEventID,
            productID: Product.mockID3,
            targetAmount: 89.00,
            currentAmount: 45.00,
            isPurchased: false,
            priority: 3,
            note: "The aromatique scent is our favorite",
            complementaryProductName: nil,
            addedAt: .now
        ),
        RegistryItem(
            id: UUID(),
            eventID: mockEventID,
            productID: Product.mockID4,
            targetAmount: 239.00,
            currentAmount: 0,
            isPurchased: false,
            priority: 2,
            note: nil,
            complementaryProductName: nil,
            addedAt: .now
        ),
        RegistryItem(
            id: UUID(),
            eventID: mockEventID,
            productID: Product.mockID5,
            targetAmount: 699.95,
            currentAmount: 350.00,
            isPurchased: false,
            priority: 1,
            note: "This would make our mornings!",
            complementaryProductName: "Riedel Vinum Set",
            addedAt: .now
        ),
        RegistryItem(
            id: UUID(),
            eventID: mockEventID,
            productID: Product.mockID6,
            targetAmount: 329.00,
            currentAmount: 329.00,
            isPurchased: false,
            priority: 3,
            note: nil,
            addedAt: .now
        ),
    ]
}

