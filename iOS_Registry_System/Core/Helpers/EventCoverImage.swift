//
//  EventCoverImage.swift
//  iOS_Registry_System
//
//  Centralized helper for event cover images.
//  Returns a curated, high-quality Unsplash image URL
//  matched to each event type. Supports the event's
//  custom `coverImage` field if one is set in the DB.
//

import Foundation

enum EventCoverImage {

    /// Returns the best cover image URL for a given event.
    /// Priority: event.coverImage (custom) → event-type curated image.
    static func url(for event: Event) -> String {
        // 1. Use the event's custom cover if it exists
        if let custom = event.coverImage, !custom.isEmpty {
            return custom
        }
        // 2. Fall back to event-type curated image
        return url(forType: event.eventType)
    }

    /// Returns a curated cover image URL for a given event type string.
    static func url(forType type: String) -> String {
        let t = type.lowercased()

        // Wedding — elegant table setting / ceremony
        if t.contains("wedding") {
            return "https://images.unsplash.com/photo-1519741497674-611481863552?w=800&q=80"
        }

        // Baby Shower — soft nursery / baby items
        if t.contains("baby") {
            return "https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=800&q=80"
        }

        // Housewarming — cozy living room / new home
        if t.contains("house") {
            return "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&q=80"
        }

        // Birthday — celebration / cake / party
        if t.contains("birth") {
            return "https://images.unsplash.com/photo-1530103862676-de8c9debad1d?w=800&q=80"
        }

        // Anniversary — romantic dinner / champagne
        if t.contains("anniversary") {
            return "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800&q=80"
        }

        // Graduation — caps & celebration
        if t.contains("graduation") || t.contains("grad") {
            return "https://images.unsplash.com/photo-1523050854058-8df90110c476?w=800&q=80"
        }

        // Special Event — elegant gathering
        if t.contains("special") {
            return "https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=800&q=80"
        }

        // Other / fallback — tasteful gift & celebration
        return "https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=800&q=80"
    }
}
