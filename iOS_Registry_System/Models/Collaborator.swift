//
//  Collaborator.swift
//  iOS_Registry_System
//
//  Collaborator model — drives the entire co-host flow.
//

import Foundation

// MARK: - Collaborator Role

enum CollaboratorRole: String, CaseIterable, Identifiable {
    case partner        = "Partner"
    case family         = "Family Organizer"
    case planner        = "Event Planner"
    case friend         = "Friend"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .partner:  return "heart.fill"
        case .family:   return "person.3.fill"
        case .planner:  return "calendar.badge.clock"
        case .friend:   return "sparkles"
        }
    }

    var description: String {
        switch self {
        case .partner:  return "Can help manage registry, guests, and planning."
        case .family:   return "Helps coordinate guests and logistics."
        case .planner:  return "Manages schedule and reminders."
        case .friend:   return "Limited collaboration access."
        }
    }

    var defaultPermissions: CollaboratorPermissions {
        switch self {
        case .partner:  return CollaboratorPermissions(editRegistry: true, addGifts: true, removeGifts: true, inviteGuests: true, manageRSVPs: true, editTimeline: true, sendReminders: true, viewContributions: true, manageGroupGifts: true)
        case .family:   return CollaboratorPermissions(editRegistry: false, addGifts: false, removeGifts: false, inviteGuests: true, manageRSVPs: true, editTimeline: false, sendReminders: true, viewContributions: false, manageGroupGifts: false)
        case .planner:  return CollaboratorPermissions(editRegistry: false, addGifts: false, removeGifts: false, inviteGuests: false, manageRSVPs: false, editTimeline: true, sendReminders: true, viewContributions: false, manageGroupGifts: false)
        case .friend:   return CollaboratorPermissions(editRegistry: false, addGifts: false, removeGifts: false, inviteGuests: false, manageRSVPs: false, editTimeline: false, sendReminders: false, viewContributions: false, manageGroupGifts: false)
        }
    }
}

// MARK: - Collaborator Status

enum CollaboratorStatus: String {
    case pending  = "Invite Pending"
    case active   = "Active"
    case declined = "Declined"
    case expired  = "Invite Expired"
}

// MARK: - Collaborator Permissions

struct CollaboratorPermissions {
    var editRegistry:     Bool
    var addGifts:         Bool
    var removeGifts:      Bool
    var inviteGuests:     Bool
    var manageRSVPs:      Bool
    var editTimeline:     Bool
    var sendReminders:    Bool
    var viewContributions: Bool
    var manageGroupGifts: Bool
}

// MARK: - Collaborator

struct Collaborator: Identifiable {
    let id = UUID()
    var name: String
    var avatarURL: String?
    var role: CollaboratorRole
    var status: CollaboratorStatus
    var invitedDate: Date
    var permissions: CollaboratorPermissions

    var accessSummary: [String] {
        var items: [String] = []
        if permissions.editRegistry  { items.append("Registry") }
        if permissions.inviteGuests  { items.append("Guests") }
        if permissions.editTimeline  { items.append("Timeline") }
        if permissions.viewContributions { items.append("Contributions") }
        return items
    }
}

// MARK: - Mock

extension Collaborator {
    static let mockPending = Collaborator(
        name: "James Carter",
        avatarURL: "https://i.pravatar.cc/150?img=11",
        role: .partner,
        status: .pending,
        invitedDate: .now,
        permissions: CollaboratorRole.partner.defaultPermissions
    )

    static let mockActive = Collaborator(
        name: "Maya Chen",
        avatarURL: "https://i.pravatar.cc/150?img=5",
        role: .family,
        status: .active,
        invitedDate: Calendar.current.date(byAdding: .day, value: -3, to: .now) ?? .now,
        permissions: CollaboratorRole.family.defaultPermissions
    )
}
