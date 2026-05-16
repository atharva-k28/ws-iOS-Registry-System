//
//  Colors.swift
//  iOS_Registry_System
//
//  Design System — Color Palette
//  65% light surfaces · 25% dark surfaces · 10% red accents
//

import SwiftUI

// MARK: - App Colors

enum AppColors {

    // MARK: Primary Palette

    /// #252525 — Primary dark, used for featured cards & premium sections
    static let primaryDark = Color(hex: "252525")

    /// #FF362D — Accent red, used sparingly for CTAs & highlights
    static let accentRed = Color(hex: "FF362D")

    /// #EFEFEF — Background gray, primary surface color
    static let backgroundGray = Color(hex: "EFEFEF")

    /// #FFFFFF — Pure white, card & content surfaces
    static let white = Color.white

    /// #898989 — Secondary gray, captions & secondary text
    static let secondaryGray = Color(hex: "898989")

    // MARK: Semantic Aliases

    static let background = backgroundGray
    static let surface = white
    static let primaryText = primaryDark
    static let secondaryText = secondaryGray
    static let accent = accentRed
    static let cardDark = primaryDark
    static let cardLight = white

    // MARK: Gradients

    static let premiumCardGradient = LinearGradient(
        colors: [primaryDark, Color(hex: "3A3A3A")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentGradient = LinearGradient(
        colors: [accentRed, Color(hex: "FF5E57")],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let subtleSurfaceGradient = LinearGradient(
        colors: [white, backgroundGray.opacity(0.5)],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Hex Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
