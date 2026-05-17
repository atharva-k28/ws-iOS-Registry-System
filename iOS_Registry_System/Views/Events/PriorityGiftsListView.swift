//
//  PriorityGiftsListView.swift
//  iOS_Registry_System
//
//  Full Priority Gifts list — "See all" destination from My Events.
//  Shows large editorial gift cards with progress, contributor avatars,
//  and urgency labels.
//

import SwiftUI

// MARK: - Priority Gifts List View

struct PriorityGiftsListView: View {

    // In production this would be injected from a ViewModel
    private let gifts: [PriorityGiftItem] = PriorityGiftItem.allMock
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: AppSpacing.cardGap) {

                // Editorial intro banner
                introBanner

                // Gift cards
                ForEach(gifts) { gift in
                    LargeGiftCard(gift: gift)
                }

                Color.clear.frame(height: AppSpacing.xxl)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.md)
        }
        .appBackground()
        .navigationTitle("Priority Gifts")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.primaryText)
                        .frame(width: 38, height: 38)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 0.5))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    // MARK: - Intro Banner

    private var introBanner: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "sparkles")
                .font(.system(size: 22))
                .foregroundStyle(AppColors.accentRed)
                .frame(width: 46, height: 46)
                .background(AppColors.accentRed.opacity(0.08))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text("Group gifts — every contribution matters.")
                    .font(.system(size: 15, weight: .semibold, design: .serif))
                    .foregroundStyle(AppColors.primaryText)
                Text("Tap any gift to chip in or invite friends.")
                    .font(AppTypography.caption1)
                    .foregroundStyle(AppColors.secondaryGray)
            }
            Spacer()
        }
        .padding(AppSpacing.md)
        .background(AppColors.accentRed.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md, style: .continuous))
    }
}

// MARK: - Large Gift Card

private struct LargeGiftCard: View {

    let gift: PriorityGiftItem

    var body: some View {
        NavigationLink(destination: GroupGiftDetailView(gift: gift)) {
            VStack(alignment: .leading, spacing: 0) {

                // Hero image
                AsyncImage(url: URL(string: gift.galleryURL(index: 0))) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(hex: "E8E2DC")
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 28))
                                .foregroundStyle(AppColors.secondaryGray)
                        )
                }
                .frame(height: 200)
                .clipped()
                .overlay(alignment: .topLeading) {
                    urgencyLabel
                }
                .overlay(alignment: .topTrailing) {
                    if gift.isAIRecommended {
                        aiChip
                    }
                }

                // Content
                VStack(alignment: .leading, spacing: AppSpacing.sm) {

                    // Collection + Title
                    VStack(alignment: .leading, spacing: 2) {
                        Text(gift.collectionLabel)
                            .font(AppTypography.caption2)
                            .tracking(1.5)
                            .foregroundStyle(AppColors.secondaryGray)
                        Text(gift.title)
                            .font(AppTypography.title3)
                            .foregroundStyle(AppColors.primaryText)
                    }

                    // Progress bar
                    ProgressBar(progress: gift.progress, height: 5)

                    // Amount row
                    HStack {
                        Text("$\(Int(gift.currentAmount)) of $\(Int(gift.goalAmount)) raised")
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.secondaryGray)
                        Spacer()
                        Text("\(gift.percentFunded)%")
                            .font(AppTypography.footnoteSemibold)
                            .foregroundStyle(AppColors.accentRed)
                    }

                    // Contributor avatars
                    contributorAvatars
                }
                .padding(AppSpacing.md)
            }
            .background(AppColors.white)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
            .softShadow()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Urgency Label

    private var urgencyLabel: some View {
        Group {
            if gift.amountToGo < 100 {
                Text("ALMOST FUNDED")
                    .font(AppTypography.caption2)
                    .tracking(1)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppColors.accentRed)
                    .clipShape(Capsule())
                    .padding(AppSpacing.sm)
            }
        }
    }

    // MARK: - AI Chip

    private var aiChip: some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkles")
                .font(.system(size: 10, weight: .semibold))
            Text("AI Pick")
                .font(AppTypography.caption2)
                .fontWeight(.semibold)
        }
        .foregroundStyle(AppColors.primaryDark)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.4), lineWidth: 0.5))
        .padding(AppSpacing.sm)
    }

    // MARK: - Contributor Avatars

    private var contributorAvatars: some View {
        HStack(spacing: -10) {
            ForEach(Array(gift.contributors.prefix(4))) { contributor in
                AsyncImage(url: URL(string: contributor.avatarURL ?? "")) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(AppColors.backgroundGray)
                        .overlay(Text(String(contributor.name.prefix(1)))
                            .font(AppTypography.caption2)
                            .foregroundStyle(AppColors.secondaryGray))
                }
                .frame(width: 28, height: 28)
                .clipShape(Circle())
                .overlay(Circle().stroke(AppColors.white, lineWidth: 1.5))
            }

            if gift.contributorCount > 4 {
                Text("+\(gift.contributorCount - 4)")
                    .font(AppTypography.caption2)
                    .foregroundStyle(AppColors.secondaryGray)
                    .frame(width: 28, height: 28)
                    .background(AppColors.backgroundGray)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(AppColors.white, lineWidth: 1.5))
            }

            Spacer()

            Text("\(gift.contributorCount) friends joined")
                .font(AppTypography.caption1)
                .foregroundStyle(AppColors.secondaryGray)
        }
    }
}

// MARK: - Preview

#Preview("Priority Gifts List") {
    NavigationStack {
        PriorityGiftsListView()
    }
}
