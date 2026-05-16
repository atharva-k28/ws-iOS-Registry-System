//
//  Contribution.swift
//  iOS_Registry_System
//
//  Contribution model — tracks gift contributions
//

import Foundation

// MARK: - Contribution

struct Contribution: Codable, Identifiable, Hashable {
    let id: UUID
    var registryItemID: UUID
    var contributorID: UUID
    var amount: Double
    var message: String?
    var isAnonymous: Bool
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case registryItemID = "registry_item_id"
        case contributorID = "contributor_id"
        case amount
        case message
        case isAnonymous = "is_anonymous"
        case createdAt = "created_at"
    }
}

// MARK: - Mock

extension Contribution {
    static let mock = Contribution(
        id: UUID(),
        registryItemID: UUID(),
        contributorID: UUID(),
        amount: 50.00,
        message: "Congrats! Can't wait for the big day 🎉",
        isAnonymous: false,
        createdAt: .now
    )
}
