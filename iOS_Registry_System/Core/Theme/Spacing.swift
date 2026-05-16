//
//  Spacing.swift
//  iOS_Registry_System
//
//  Design System — Spacing & Corner Radius
//  Breathable, curated, luxurious spacing scale
//

import SwiftUI

// MARK: - App Spacing

enum AppSpacing {

    // MARK: Base Scale (4pt grid)

    static let xxxs: CGFloat = 2
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let xxxl: CGFloat = 40
    static let huge: CGFloat = 48
    static let massive: CGFloat = 64

    // MARK: Semantic Spacing

    /// Horizontal padding for screen edges
    static let screenHorizontal: CGFloat = 20

    /// Vertical padding for screen top/bottom
    static let screenVertical: CGFloat = 16

    /// Space between cards in a list
    static let cardGap: CGFloat = 16

    /// Internal card padding
    static let cardPadding: CGFloat = 20

    /// Space between sections
    static let sectionGap: CGFloat = 32

    /// Space between a section header and its content
    static let sectionHeaderGap: CGFloat = 16

    /// Space between inline elements (icon + text, etc.)
    static let inlineGap: CGFloat = 8

    /// Tab bar height
    static let tabBarHeight: CGFloat = 72

    /// Bottom safe area offset for floating tab bar
    static let tabBarBottomOffset: CGFloat = 28
}

// MARK: - App Corner Radius

enum AppCornerRadius {

    /// Small interactive elements: tags, badges
    static let xs: CGFloat = 8

    /// Buttons, text fields
    static let sm: CGFloat = 12

    /// Cards, modals
    static let md: CGFloat = 16

    /// Featured cards, prominent elements
    static let lg: CGFloat = 24

    /// Premium cards, hero sections
    static let xl: CGFloat = 30

    /// Fully rounded (pills)
    static let full: CGFloat = 100
}
