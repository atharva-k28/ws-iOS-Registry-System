//
//  User.swift
//  iOS_Registry_System
//
//  User model
//

import Foundation

// MARK: - User

struct User: Codable, Identifiable, Hashable {
    let id: UUID
    var email: String
    var displayName: String
    var avatarURL: String?
    var bio: String?
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case displayName = "display_name"
        case avatarURL = "avatar_url"
        case bio
        case createdAt = "created_at"
    }
}

// MARK: - Mock

extension User {
    static let mock = User(
        id: UUID(),
        email: "jane@example.com",
        displayName: "Jane Doe",
        avatarURL: nil,
        bio: "Love curating the perfect gifts ✨",
        createdAt: .now
    )
}
