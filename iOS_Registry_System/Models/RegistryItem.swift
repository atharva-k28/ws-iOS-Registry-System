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
    static let mock = RegistryItem(
        id: UUID(),
        eventID: UUID(),
        productID: UUID(),
        targetAmount: 419.95,
        currentAmount: 280.00,
        isPurchased: false,
        priority: 1,
        note: "We'd love the Marseille color!",
        addedAt: .now
    )
}
