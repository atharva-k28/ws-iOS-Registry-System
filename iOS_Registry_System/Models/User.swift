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
    var fullName: String
    var email: String
    var phone: String?
    var avatarUrl: String?
    var createdAt: Date?
    var firstName: String?
    var lastName: String?
    var address: String?
    var address2: String?
    var city: String?
    var state: String?
    var zip: String?

    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case email
        case phone
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
        case firstName = "first_name"
        case lastName = "last_name"
        case address
        case address2
        case city
        case state
        case zip
    }
}
