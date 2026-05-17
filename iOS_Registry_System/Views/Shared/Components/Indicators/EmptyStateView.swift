//
//  EmptyStateView.swift
//  iOS_Registry_System
//
//  Premium glassmorphic empty state view for event lists.
//

import SwiftUI

struct EmptyStateView: View {
    var systemImageName: String = "calendar.badge.plus"
    var title: String = "No events yet"
    var description: String = "Create a registry for your next big occasion."
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            // Icon with liquid glass shadow background
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.6), .white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )
                    .softShadow()
                
                Image(systemName: systemImageName)
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppColors.primaryText, AppColors.secondaryText],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .padding(.bottom, AppSpacing.xs)

            VStack(spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppTypography.premiumTitle)
                    .foregroundStyle(AppColors.primaryText)
                    .multilineTextAlignment(.center)

                Text(description)
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.lg)
            }

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(AppTypography.buttonMedium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, AppSpacing.xl)
                        .padding(.vertical, AppSpacing.sm)
                        .background(
                            Capsule()
                                .fill(AppColors.accentGradient)
                        )
                        .accentShadow()
                }
                .padding(.top, AppSpacing.xs)
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, AppSpacing.xxxl)
        .padding(.horizontal, AppSpacing.xl)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.xl)
                .fill(AppColors.white.opacity(0.45))
                .background(
                    RoundedRectangle(cornerRadius: AppCornerRadius.xl)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                )
        )
        .softShadow()
    }
}

#Preview {
    ZStack {
        AppColors.backgroundGray.ignoresSafeArea()
        
        VStack(spacing: 40) {
            EmptyStateView(
                systemImageName: "calendar.badge.plus",
                title: "No Events Yet",
                description: "You haven't created any events. Start hosting your first registry today!",
                actionTitle: "Create Event",
                action: {}
            )
            .padding(.horizontal, 20)
        }
    }
}
