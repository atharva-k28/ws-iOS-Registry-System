//
//  CollectionCard.swift
//  iOS_Registry_System
//
//  Large vertical collection card for Home View
//

import SwiftUI

struct CollectionCard: View {
    let title: String
    let category: String
    let actionText: String
    let imageUrl: String?
    var onTap: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Header
            AsyncImage(url: imageUrl.flatMap(URL.init(string:))) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 240)
            .clipped()

            // Content Footer
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text(category.uppercased())
                    .font(AppTypography.caption1Medium)
                    .tracking(1.5)
                    .foregroundColor(AppColors.secondaryGray)

                Text(title)
                    .font(AppTypography.premiumTitle)
                    .foregroundColor(AppColors.primaryText)
                    .lineLimit(2)
                    .padding(.bottom, AppSpacing.xxs)

                HStack {
                    Text(actionText.uppercased())
                        .font(AppTypography.caption1Medium)
                        .fontWeight(.bold)
                        .tracking(1.0)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(AppColors.primaryDark)
            }
            .padding(AppSpacing.xl)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl, style: .continuous))
        .onTapGesture {
            onTap?()
        }
        .accessibilityAddTraits(.isButton)
        .frame(maxWidth: .infinity, alignment: .leading)
        .softShadow()
    }
}
