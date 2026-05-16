//
//  Date+Extensions.swift
//  iOS_Registry_System
//
//  Date formatting helpers
//

import Foundation

extension Date {

    /// "May 15, 2026"
    var formattedLong: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    /// "May 15"
    var formattedShort: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }

    /// "3 days left"
    var daysUntil: String {
        let days = Calendar.current.dateComponents([.day], from: .now, to: self).day ?? 0
        if days < 0 {
            return "Past"
        } else if days == 0 {
            return "Today"
        } else if days == 1 {
            return "Tomorrow"
        } else {
            return "\(days) days left"
        }
    }
}
