//
//  MockData.swift
//  iOS_Registry_System
//
//  Centralized mock data for previews and development
//

import Foundation

// MARK: - Mock Data

enum MockData {

    // MARK: Users

    static let currentUser = User.mock

    static let friends: [User] = [
        User(id: UUID(), email: "sarah@example.com", displayName: "Sarah Chen", avatarURL: nil, bio: "Wedding planning mode 💍", createdAt: .now),
        User(id: UUID(), email: "james@example.com", displayName: "James Wilson", avatarURL: nil, bio: nil, createdAt: .now),
        User(id: UUID(), email: "emma@example.com", displayName: "Emma Rodriguez", avatarURL: nil, bio: "Mom-to-be 🍼", createdAt: .now),
    ]

    // MARK: Events

    static let events = Event.mockList

    // MARK: Products

    static let products = Product.mockList

    // MARK: Registry Items

    static let registryItems: [RegistryItem] = [
        RegistryItem.mock,
        RegistryItem(
            id: UUID(),
            eventID: UUID(),
            productID: UUID(),
            targetAmount: 749.99,
            currentAmount: 375.00,
            isPurchased: false,
            priority: 2,
            note: nil,
            complementaryProductName: nil,
            requestedQuantity: 1,
            purchasedQuantity: 0,
            addedAt: .now
        ),
        RegistryItem(
            id: UUID(),
            eventID: UUID(),
            productID: UUID(),
            targetAmount: 89.00,
            currentAmount: 89.00,
            isPurchased: true,
            priority: 3,
            note: "Fully funded! 🎉",
            complementaryProductName: nil,
            requestedQuantity: 1,
            purchasedQuantity: 1,
            addedAt: .now
        ),
    ]

    // MARK: Contributions

    static let contributions: [Contribution] = [
        Contribution.mock,
        Contribution(
            id: UUID(),
            registryItemID: UUID(),
            contributorID: UUID(),
            amount: 100.00,
            message: "Happy housewarming! 🏡",
            isAnonymous: false,
            createdAt: .now
        ),
        Contribution(
            id: UUID(),
            registryItemID: UUID(),
            contributorID: UUID(),
            amount: 25.00,
            message: nil,
            isAnonymous: true,
            createdAt: .now
        ),
    ]
}
