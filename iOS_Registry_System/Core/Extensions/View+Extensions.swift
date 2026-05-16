//
//  View+Extensions.swift
//  iOS_Registry_System
//
//  Reusable SwiftUI View extensions
//

import SwiftUI

// MARK: - View Extensions

extension View {

    /// Apply the app's background color
    func appBackground() -> some View {
        self.background(AppColors.background.ignoresSafeArea())
    }

    /// Standard screen padding
    func screenPadding() -> some View {
        self.padding(.horizontal, AppSpacing.screenHorizontal)
    }

    /// Card styling with white background, rounded corners, and soft shadow
    func cardStyle(cornerRadius: CGFloat = AppCornerRadius.lg) -> some View {
        self
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .softShadow()
    }

    /// Dark premium card styling
    func darkCardStyle(cornerRadius: CGFloat = AppCornerRadius.lg) -> some View {
        self
            .background(AppColors.cardDark)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .darkCardShadow()
    }

    /// Hide the default navigation bar background for custom styling
    func transparentNavigationBar() -> some View {
        self
            .toolbarBackground(.hidden, for: .navigationBar)
    }

    /// Rounded rectangle clip with continuous corners
    func continuousCorners(_ radius: CGFloat) -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

// MARK: - Conditional Modifier

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
