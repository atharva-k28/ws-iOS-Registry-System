//
//  PrimaryButton.swift
//  iOS_Registry_System
//
//  Reusable primary CTA button
//

import SwiftUI

// MARK: - Primary Button

struct PrimaryButton: View {

    let title: String
    var icon: String?
    var style: ButtonVariant = .accent
    var isLoading: Bool = false
    var isFullWidth: Bool = true
    let action: () -> Void

    enum ButtonVariant {
        case accent   // Red CTA
        case dark     // Dark premium
        case outline  // Bordered
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(foregroundColor)
                        .scaleEffect(0.85)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .semibold))
                    }
                    Text(title)
                        .font(AppTypography.buttonLarge)
                }
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .frame(height: 54)
            .padding(.horizontal, AppSpacing.xl)
            .background(backgroundContent)
            .clipShape(Capsule())
            .overlay {
                if style == .outline {
                    Capsule()
                        .strokeBorder(AppColors.primaryDark.opacity(0.2), lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(.plain)
        .if(style == .accent) { view in
            view.accentShadow()
        }
    }

    // MARK: - Computed Styles

    private var foregroundColor: Color {
        switch style {
        case .accent, .dark:
            return .white
        case .outline:
            return AppColors.primaryDark
        }
    }

    @ViewBuilder
    private var backgroundContent: some View {
        switch style {
        case .accent:
            AppColors.accentGradient
        case .dark:
            AppColors.primaryDark
        case .outline:
            Color.clear
        }
    }
}

// MARK: - Preview

#Preview("Primary Buttons") {
    VStack(spacing: 16) {
        PrimaryButton(title: "Add to Registry", icon: "plus") {}
        PrimaryButton(title: "View Event", style: .dark) {}
        PrimaryButton(title: "Share Registry", icon: "square.and.arrow.up", style: .outline) {}
        PrimaryButton(title: "Loading...", isLoading: true) {}
    }
    .padding(24)
    .background(AppColors.background)
}
