//
//  SmallCollectionCard.swift
//  iOS_Registry_System
//
//  Small grid collection card for Home View
//

import SwiftUI

struct SmallCollectionCard: View {
    let title: String
    let imageUrl: String?
    var onTap: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            AsyncImage(url: imageUrl.flatMap(URL.init(string:))) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .clipped()

            // Footer
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(AppColors.primaryText)

                HStack(spacing: 4) {
                    Text("Shop now")
                        .font(AppTypography.caption1)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 10))
                }
                .foregroundColor(AppColors.secondaryGray)
            }
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
        .onTapGesture {
            onTap?()
        }
        .accessibilityAddTraits(.isButton)
        .frame(maxWidth: .infinity, alignment: .leading)
        .softShadow()
    }
}
