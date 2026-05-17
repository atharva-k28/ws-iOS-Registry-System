//
//  PriorityGiftCard.swift
//  iOS_Registry_System
//
//  Tappable priority gift list card — navigates to GroupGiftDetailView.
//

import SwiftUI

// MARK: - Priority Gift Card

struct PriorityGiftCard: View {

    // Accept a rich PriorityGiftItem for full navigation,
    // or fall back to the legacy scalar params.
    var giftItem: PriorityGiftItem?

    // Legacy scalar API (kept so existing call sites compile)
    var title: String
    var currentAmount: Double
    var goalAmount: Double
    var imageSeed: String

    // Derived convenience
    private var resolvedItem: PriorityGiftItem {
        giftItem ?? PriorityGiftItem(
            id: UUID(),
            title: title,
            collectionLabel: "FEATURED",
            currentAmount: currentAmount,
            goalAmount: goalAmount,
            imageSeed: imageSeed,
            galleryURLs: [],
            isAIRecommended: false,
            contributors: []
        )
    }

    private var progress: Double { resolvedItem.progress }

    var body: some View {
        NavigationLink(destination: GroupGiftDetailView(gift: resolvedItem)) {
            HStack(spacing: AppSpacing.md) {

                // Thumbnail
                AsyncImage(url: URL(string: "https://loremflickr.com/200/200/\(imageSeed)?lock=\(abs(imageSeed.hashValue % 100))")) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(hex: "E8E2DC")
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

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppColors.secondaryGray)
            }
            .padding(AppSpacing.sm)
            .background(AppColors.white)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
            .softShadow()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Convenience initialiser matching existing call sites

extension PriorityGiftCard {
    /// Backwards-compatible init used in MyEventsView
    init(title: String, currentAmount: Double, goalAmount: Double, imageSeed: String) {
        self.giftItem = nil
        self.title = title
        self.currentAmount = currentAmount
        self.goalAmount = goalAmount
        self.imageSeed = imageSeed
    }

    /// Rich init used in the new flow
    init(gift: PriorityGiftItem) {
        self.giftItem = gift
        self.title = gift.title
        self.currentAmount = gift.currentAmount
        self.goalAmount = gift.goalAmount
        self.imageSeed = gift.imageSeed
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        VStack(spacing: 16) {
            PriorityGiftCard(gift: .cookwareSet)
            PriorityGiftCard(gift: .bbqBundle)
            PriorityGiftCard(gift: .espressoMachine)
        }
        .padding()
        .background(AppColors.background)
    }
}
