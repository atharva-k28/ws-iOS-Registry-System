//
//  RegistryCategoryDetailView.swift
//  iOS_Registry_System
//
//  Detail view showing all gifts inside a specific registry category.
//

import SwiftUI

struct RegistryCategoryDetailView: View {
    
    let categoryTitle: String
    
    @Environment(\.dismiss) private var dismiss
    
    // Mock items based on category
    private var categoryItems: [PriorityGiftItem] {
        let all = PriorityGiftItem.allMock
        guard all.count >= 3 else { return all } // Safety check
        switch categoryTitle {
        case "Kitchen": return [all[0], all[2]] // Cookware, Espresso
        case "Dining":  return [all[0]]         // Cookware
        case "Outdoor": return [all[1]]         // BBQ
        default:        return all
        }
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: AppSpacing.cardGap) {
                // Header Banner
                headerBanner
                
                // Gifts List
                ForEach(categoryItems) { gift in
                    CategoryGiftCard(gift: gift)
                }
                
                Color.clear.frame(height: AppSpacing.xxl)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.md)
        }
        .appBackground()
        .navigationTitle(categoryTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.primaryText)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(.regularMaterial)
                                .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 0.5))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }
    
    private var headerBanner: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "square.grid.2x2.fill")
                .font(.system(size: 22))
                .foregroundStyle(AppColors.accentRed)
                .frame(width: 46, height: 46)
                .background(AppColors.accentRed.opacity(0.08))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text("\(categoryTitle) Collection")
                    .font(.system(size: 15, weight: .semibold, design: .serif))
                    .foregroundStyle(AppColors.primaryText)
                Text("\(categoryItems.count) beautiful items for your home.")
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

// MARK: - Category Gift Card

private struct CategoryGiftCard: View {

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
                .frame(height: 180)
                .clipped()
                
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
                }
                .padding(AppSpacing.md)
            }
            .background(AppColors.white)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
            .softShadow()
        }
        .buttonStyle(.plain)
    }
}
