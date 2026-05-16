//
//  RegistryItemDetailView.swift
//  iOS_Registry_System
//
//  Detailed view for a single registry item
//

import SwiftUI

struct RegistryItemDetailView: View {
    let item: RegistryItem
    let product: Product
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    
                    // Product Image
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        AppColors.primaryDark.opacity(0.1)
                            .overlay {
                                Image(systemName: "gift")
                                    .font(.system(size: 60))
                                    .foregroundStyle(AppColors.secondaryGray)
                            }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 350)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl))
                    .padding(.horizontal, AppSpacing.screenHorizontal)

                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        
                        // Header info
                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            if let complements = item.complementaryProductName {
                                Text("Complements \(complements)")
                                    .font(AppTypography.caption1Medium)
                                    .foregroundStyle(AppColors.accentRed)
                            }
                            
                            Text(product.name)
                                .font(AppTypography.premiumTitle)
                                .foregroundStyle(AppColors.primaryText)
                            
                            Text(CurrencyFormatter.format(product.price))
                                .font(AppTypography.title1)
                                .foregroundStyle(AppColors.primaryDark)
                        }

                        // Description
                        if let desc = product.productDescription {
                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text("About this item")
                                    .font(AppTypography.subheadlineMedium)
                                
                                Text(desc)
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppColors.secondaryGray)
                                    .lineSpacing(4)
                            }
                        }

                        // Host Note
                        if let note = item.note {
                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text("Host's Note")
                                    .font(AppTypography.subheadlineMedium)
                                
                                Text("\"\(note)\"")
                                    .font(AppTypography.body)
                                    .italic()
                                    .foregroundStyle(AppColors.secondaryGray)
                            }
                            .padding(AppSpacing.md)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
                        }

                        // Progress (if active)
                        if !item.isPurchased && item.progress > 0 {
                            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                Text("Contribution Progress")
                                    .font(AppTypography.subheadlineMedium)
                                
                                ContributionProgressBar(
                                    progress: item.progress,
                                    currentAmount: item.currentAmount,
                                    targetAmount: item.targetAmount,
                                    showLabels: true,
                                    height: 12
                                )
                            }
                            .padding(AppSpacing.md)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    
                    Spacer(minLength: 100)
                }
            }
            .appBackground()
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(AppColors.secondaryGray)
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: AppSpacing.sm) {
                    if !item.isPurchased && item.progress < 1.0 {
                        HStack(spacing: AppSpacing.md) {
                            Button {
                                // Contribute
                            } label: {
                                Text("Contribute")
                                    .font(AppTypography.buttonLarge)
                                    .foregroundStyle(AppColors.primaryDark)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(AppColors.white)
                                    .clipShape(Capsule())
                                    .overlay {
                                        Capsule()
                                            .strokeBorder(AppColors.primaryDark, lineWidth: 1.5)
                                    }
                            }

                            Button {
                                // Purchase
                            } label: {
                                Text("Purchase Full")
                                    .font(AppTypography.buttonLarge)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 56)
                                    .background(AppColors.primaryDark)
                                    .clipShape(Capsule())
                            }
                        }
                    } else {
                        Text(item.isPurchased ? "Item Already Purchased" : "Goal Reached!")
                            .font(AppTypography.subheadlineMedium)
                            .foregroundStyle(AppColors.secondaryGray)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppColors.white)
                            .clipShape(Capsule())
                    }
                }
                .padding(AppSpacing.lg)
                .background(.ultraThinMaterial)
            }
        }
    }

    private var imageURL: String {
        let seed = product.name.replacingOccurrences(of: " ", with: ",")
        return "https://loremflickr.com/800/800/\(seed),product?lock=\(abs(product.id.hashValue % 100))"
    }
}
