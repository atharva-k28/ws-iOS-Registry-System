//
//  Constants.swift
//  iOS_Registry_System
//
//  App-wide constants
//

import Foundation

// MARK: - App Constants

enum AppConstants {

    /// App display name
    static let appName = "Registry Together"

    /// App tagline
    static let tagline = "Gifting, Together."

    // MARK: Animation Durations

    static let animationFast: Double = 0.2
    static let animationDefault: Double = 0.3
    static let animationSlow: Double = 0.5
    static let animationSpring: Double = 0.6

    // MARK: Event Types

    static let eventTypes = [
        "Wedding",
        "Baby Shower",
        "Housewarming",
        "Birthday",
        "Special Event"
    ]

    // MARK: Tab Items

    enum Tab: Int, CaseIterable {
        case home = 0
        case events = 1
        case friends = 2
        case profile = 3

        var title: String {
            switch self {
            case .home: return "Home"
            case .events: return "My Events"
            case .friends: return "Friends"
            case .profile: return "Profile"
            }
        }

        var icon: String {
            switch self {
            case .home: return "house"
            case .events: return "calendar"
            case .friends: return "heart"
            case .profile: return "person"
            }
        }
    }

    // MARK: AI Features

    static let aiFeatureEnabled = true

    // MARK: Networking

    static let requestTimeout: TimeInterval = 30
    static let maxRetries = 3
}
