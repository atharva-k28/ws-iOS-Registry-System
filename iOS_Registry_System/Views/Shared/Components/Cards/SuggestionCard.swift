//
//  SuggestionCard.swift
//  iOS_Registry_System
//
//  Dark horizontal suggestion card for My Events view
//

import SwiftUI

struct SuggestionCard: View {
    let title: String
    let subtitle: String
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: AppSpacing.md) {
                // Icon Badge
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: "sparkles")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTypography.bodyMedium)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.white)
                    
                    Text(subtitle)
                        .font(AppTypography.footnote)
                        .foregroundColor(AppColors.secondaryGray)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.white)
            }
            .padding(AppSpacing.lg)
            .background(AppColors.primaryDark)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl, style: .continuous))
            .darkCardShadow()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SuggestionCard(
        title: "A few quiet suggestions",
        subtitle: "5 thoughtful additions for your registry"
    )
    .padding()
    .background(AppColors.background)
}
