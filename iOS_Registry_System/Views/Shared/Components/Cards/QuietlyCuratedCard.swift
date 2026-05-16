//
//  QuietlyCuratedCard.swift
//  iOS_Registry_System
//
//  Premium card for AI recommendations and social proof
//

import SwiftUI

struct QuietlyCuratedCard: View {
    let title: String
    let description: String
    var actionTitle: String = "Explore"
    var onAction: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.secondaryGray)
                    
                    Text("QUIETLY CURATED")
                        .font(AppTypography.caption2)
                        .tracking(1.5)
                        .foregroundColor(AppColors.secondaryGray)
                }
                
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(title)
                        .font(AppTypography.premiumTitle)
                        .foregroundColor(AppColors.white)
                    
                    if !description.isEmpty {
                        Text(description)
                            .font(AppTypography.subheadline)
                            .foregroundColor(AppColors.white.opacity(0.8))
                            .lineLimit(2)
                    }
                }
                
                if !actionTitle.isEmpty {
                    PrimaryButton(title: actionTitle, style: .accent) {
                        onAction?()
                    }
                    .padding(.top, AppSpacing.xs)
                }
            }
            
            Spacer()
            
            if actionTitle.isEmpty {
                Image(systemName: "arrow.right")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(AppColors.white)
            }
        }
        .padding(AppSpacing.xl)
        .background(AppColors.primaryDark)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl, style: .continuous))
        .darkCardShadow()
    }
}

#Preview {
    QuietlyCuratedCard(
        title: "For the Coffee Lover",
        description: "A selection of premium espresso machines and accessories loved by tastemakers."
    )
    .padding()
    .background(AppColors.background)
}
