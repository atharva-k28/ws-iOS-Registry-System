//
//  Notification.swift
//  iOS_Registry_System
//
//  Model for notifications table
//

import Foundation

struct Notification: Codable, Identifiable, Hashable {
    let id: UUID
    var userId: UUID
    var registryId: UUID?
    var type: String?
    var title: String?
    var body: String?
    var isRead: Bool?
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case registryId = "registry_id"
        case type
        case title
        case body
        case isRead = "is_read"
        case createdAt = "created_at"
    }
}
