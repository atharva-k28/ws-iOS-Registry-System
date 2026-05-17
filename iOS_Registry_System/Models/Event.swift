//
//  Event.swift
//  iOS_Registry_System
//
//  Event / Registry model
//

import Foundation

// MARK: - Event Type

enum EventType: String, Codable, CaseIterable, Identifiable {
    case wedding = "wedding"
    case babyShower = "baby_shower"
    case housewarming = "housewarming"
    case birthday = "birthday"
    case anniversary = "anniversary"
    case specialEvent = "special_event"
    case other = "other"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .wedding: return "Wedding"
        case .babyShower: return "Baby Shower"
        case .housewarming: return "Housewarming"
        case .birthday: return "Birthday"
        case .anniversary: return "Anniversary"
        case .specialEvent: return "Special Event"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .wedding: return "heart.fill"
        case .babyShower: return "stroller.fill"
        case .housewarming: return "house.fill"
        case .birthday: return "birthday.cake.fill"
        case .anniversary: return "gift.fill"
        case .specialEvent: return "sparkles"
        case .other: return "star.fill"
        }
    }
}

// MARK: - Event

struct Event: Codable, Identifiable, Hashable {
    let id: UUID
    var ownerUserId: UUID
    var title: String
    var eventType: String
    var venue: String?
    var startDate: Date?
    var endDate: Date?
    var coverImage: String?
    var isPrivate: Bool?
    var createdAt: Date?
    var eventDate: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case ownerUserId = "owner_user_id"
        case title
        case eventType = "event_type"
        case venue
        case startDate = "start_date"
        case endDate = "end_date"
        case coverImage = "cover_image"
        case isPrivate = "is_private"
        case createdAt = "created_at"
        case eventDate = "event_date"
    }
}
