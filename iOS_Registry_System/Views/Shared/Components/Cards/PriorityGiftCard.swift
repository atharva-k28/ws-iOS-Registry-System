//
//  PriorityGiftCard.swift
//  iOS_Registry_System
//
//  Card for priority gifts list in My Events view
//

import SwiftUI

struct PriorityGiftCard: View {
    let title: String
    let currentAmount: Double
    let goalAmount: Double
    let imageSeed: String

    var progress: Double {
        return min(currentAmount / goalAmount, 1.0)
    }

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Image
            AsyncImage(url: URL(string: "https://loremflickr.com/200/200/cookware,bakery,kitchen?lock=\(abs(imageSeed.hashValue % 100))")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm, style: .continuous))

            // Details
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(AppColors.primaryText)

                Text("$\(Int(currentAmount)) of $\(Int(goalAmount))")
                    .font(AppTypography.footnote)
                    .foregroundColor(AppColors.secondaryGray)

                ProgressBar(progress: progress, height: 4)
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.trailing, AppSpacing.sm)
        }
        .padding(AppSpacing.sm)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
        .softShadow()
    }
}

#Preview {
    VStack {
        PriorityGiftCard(
            title: "Made In Cookware Set",
            currentAmount: 320,
            goalAmount: 500,
            imageSeed: "pans"
        )
        PriorityGiftCard(
            title: "Outdoor BBQ Bundle",
            currentAmount: 95,
            goalAmount: 280,
            imageSeed: "bbq"
        )
    }
    .padding()
    .background(AppColors.background)
}
