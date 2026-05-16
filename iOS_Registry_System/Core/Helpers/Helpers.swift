//
//  Helpers.swift
//  iOS_Registry_System
//
//  Utility helpers
//

import Foundation

// MARK: - Currency Formatter

enum CurrencyFormatter {

    private static let formatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: "en_US")
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 0
        return f
    }()

    /// Format a Double as a currency string — "$419.95"
    static func format(_ amount: Double) -> String {
        formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }

    /// Format as compact — "$420"
    static func formatCompact(_ amount: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.locale = Locale(identifier: "en_US")
        f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: amount)) ?? "$\(Int(amount))"
    }
}

// MARK: - Percentage Formatter

enum PercentageFormatter {

    /// Format 0.0–1.0 as "67%"
    static func format(_ value: Double) -> String {
        "\(Int(value * 100))%"
    }
}
