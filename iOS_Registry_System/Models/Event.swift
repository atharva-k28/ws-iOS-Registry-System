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
    case specialEvent = "special_event"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .wedding: return "Wedding"
        case .babyShower: return "Baby Shower"
        case .housewarming: return "Housewarming"
        case .birthday: return "Birthday"
        case .specialEvent: return "Special Event"
        }
    }

    var icon: String {
        switch self {
        case .wedding: return "heart.fill"
        case .babyShower: return "stroller.fill"
        case .housewarming: return "house.fill"
        case .birthday: return "birthday.cake.fill"
        case .specialEvent: return "sparkles"
        }
    }
}

// MARK: - Event

struct Event: Codable, Identifiable, Hashable {
    let id: UUID
    var hostID: UUID
    var title: String
    var eventDescription: String?
    var eventType: String
    var eventDate: Date?
    var coverImageURL: String?
    var isPublic: Bool
    var createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case hostID = "host_id"
        case title
        case eventDescription = "description"
        case eventType = "event_type"
        case eventDate = "event_date"
        case coverImageURL = "cover_image_url"
        case isPublic = "is_public"
        case createdAt = "created_at"
    }
}

// MARK: - Mock

extension Event {
    static let mock = Event(
        id: UUID(),
        hostID: UUID(),
        title: "Sarah & James's Wedding",
        eventDescription: "Join us in celebrating our special day",
        eventType: EventType.wedding.rawValue,
        eventDate: Calendar.current.date(byAdding: .day, value: 45, to: .now),
        coverImageURL: nil,
        isPublic: true,
        createdAt: .now
    )

    static let mockList: [Event] = [
        .mock,
        Event(
            id: UUID(),
            hostID: UUID(),
            title: "Emma's Baby Shower",
            eventDescription: "Welcome baby Emma!",
            eventType: EventType.babyShower.rawValue,
            eventDate: Calendar.current.date(byAdding: .day, value: 20, to: .now),
            coverImageURL: nil,
            isPublic: true,
            createdAt: .now
        ),
        Event(
            id: UUID(),
            hostID: UUID(),
            title: "New Home Celebration",
            eventDescription: "Help us make our house a home",
            eventType: EventType.housewarming.rawValue,
            eventDate: Calendar.current.date(byAdding: .day, value: 10, to: .now),
            coverImageURL: nil,
            isPublic: false,
            createdAt: .now
        )
    ]
}
