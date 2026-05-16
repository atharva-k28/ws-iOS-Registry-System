//
//  Typography.swift
//  iOS_Registry_System
//
//  Design System — Typography
//  SF Pro Display inspired hierarchy
//

import SwiftUI

// MARK: - App Typography

enum AppTypography {

    // MARK: Large Titles — Hero & Screen Titles

    static let largeTitle = Font.system(size: 34, weight: .bold, design: .default)
    static let largeTitleSerif = Font.system(size: 34, weight: .bold, design: .serif)

    // MARK: Titles — Section Headers

    static let title1 = Font.system(size: 28, weight: .bold, design: .default)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .default)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .default)

    // MARK: Headlines — Card Titles & Emphasis

    static let headline = Font.system(size: 17, weight: .semibold, design: .default)
    static let headlineRounded = Font.system(size: 17, weight: .semibold, design: .rounded)

    // MARK: Body — Primary Content

    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyMedium = Font.system(size: 17, weight: .medium, design: .default)
    static let bodySemibold = Font.system(size: 17, weight: .semibold, design: .default)

    // MARK: Callout — Secondary Content

    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    static let calloutMedium = Font.system(size: 16, weight: .medium, design: .default)

    // MARK: Subheadline — Supporting Text

    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
    static let subheadlineMedium = Font.system(size: 15, weight: .medium, design: .default)

    // MARK: Footnote — Metadata & Timestamps

    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let footnoteSemibold = Font.system(size: 13, weight: .semibold, design: .default)

    // MARK: Caption — Labels & Tags

    static let caption1 = Font.system(size: 12, weight: .regular, design: .default)
    static let caption1Medium = Font.system(size: 12, weight: .medium, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)

    // MARK: Button Typography

    static let buttonLarge = Font.system(size: 17, weight: .semibold, design: .default)
    static let buttonMedium = Font.system(size: 15, weight: .semibold, design: .default)
    static let buttonSmall = Font.system(size: 13, weight: .semibold, design: .default)

    // MARK: Premium / Decorative

    static let premiumTitle = Font.system(size: 24, weight: .bold, design: .serif)
    static let premiumSubtitle = Font.system(size: 16, weight: .medium, design: .serif)
    static let price = Font.system(size: 20, weight: .bold, design: .rounded)
    static let priceSmall = Font.system(size: 16, weight: .bold, design: .rounded)
}

// MARK: - View Modifier Convenience

extension View {
    func appFont(_ font: Font) -> some View {
        self.font(font)
    }
}
