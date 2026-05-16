//
//  Shadows.swift
//  iOS_Registry_System
//
//  Design System — Premium Shadow Presets
//

import SwiftUI

// MARK: - App Shadows

enum AppShadows {

    /// Subtle elevation — cards resting on background
    static func soft() -> some ViewModifier {
        ShadowModifier(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    /// Medium elevation — interactive cards on hover/press
    static func medium() -> some ViewModifier {
        ShadowModifier(color: .black.opacity(0.1), radius: 16, x: 0, y: 6)
    }

    /// Strong elevation — floating elements (tab bar, FABs)
    static func floating() -> some ViewModifier {
        ShadowModifier(color: .black.opacity(0.12), radius: 24, x: 0, y: 8)
    }

    /// Colored accent shadow — premium CTAs
    static func accent() -> some ViewModifier {
        ShadowModifier(color: AppColors.accentRed.opacity(0.3), radius: 16, x: 0, y: 6)
    }

    /// Dark card inner glow effect
    static func darkCard() -> some ViewModifier {
        ShadowModifier(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Shadow View Modifier

struct ShadowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: radius, x: x, y: y)
    }
}

// MARK: - Convenience Extension

extension View {
    func softShadow() -> some View {
        modifier(AppShadows.soft())
    }

    func mediumShadow() -> some View {
        modifier(AppShadows.medium())
    }

    func floatingShadow() -> some View {
        modifier(AppShadows.floating())
    }

    func accentShadow() -> some View {
        modifier(AppShadows.accent())
    }

    func darkCardShadow() -> some View {
        modifier(AppShadows.darkCard())
    }
}
