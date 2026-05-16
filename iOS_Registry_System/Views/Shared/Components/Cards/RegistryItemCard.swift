//
//  RegistryItemCard.swift
//  iOS_Registry_System
//
//  Card component for displaying a registry gift item (friend-facing view)
//

import SwiftUI

// MARK: - Registry Item Card

struct RegistryItemCard: View {

    let product: Product
    let registryItem: RegistryItem
    var isGroupGifting: Bool = false
    var onPurchase: (() -> Void)?
    var onContribute: (() -> Void)?
    var onShare: (() -> Void)?
    var onEnableGroupGifting: (() -> Void)?
    var onTap: (() -> Void)?

    @State private var cartQuantity = 0

    private var isFunded: Bool {
        registryItem.progress >= 1.0
    }

    private var isPurchased: Bool {
        registryItem.isPurchased
    }

    /// Whether the item is completed (purchased or fully funded)
    private var isCompleted: Bool {
        isPurchased || (isGroupGifting && isFunded)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // MARK: Image Area

            ZStack(alignment: .top) {
                // Product Image
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.1)
                        .overlay {
                            Image(systemName: "gift.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(AppColors.secondaryGray.opacity(0.4))
                        }
                }
                .frame(height: 180)
                .clipped()

                // Top Overlays
                HStack(alignment: .top) {
                    // Status Labels (Top-Left)
                    Group {
                        if isCompleted {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 10, weight: .bold))
                                Text("Purchased")
                                    .font(AppTypography.caption1Medium)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, 6)
                            .background(AppColors.primaryDark.opacity(0.9))
                            .clipShape(Capsule())
                        } else if isGroupGifting {
                            HStack(spacing: 4) {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 10, weight: .semibold))
                                Text("Group Gifting")
                                    .font(AppTypography.caption1Medium)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, 6)
                            .background(AppColors.accentRed.opacity(0.9))
                            .clipShape(Capsule())
                        }
                    }
                    
                    Spacer()
                    
                    VStack(spacing: AppSpacing.xs) {
                        
                        
                        // Share button
                        if !isCompleted {
                            Button {
                                onShare?()
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(AppColors.primaryDark)
                                    .frame(width: 32, height: 32)
                                    .background(AppColors.white)
                                    .clipShape(Circle())
                                    .softShadow()
                            }
                        }
                    }
                }
                .padding(AppSpacing.xs)
            }

            // MARK: Details

            VStack(alignment: .leading, spacing: AppSpacing.xs) {

                // Complementary message
                if let complements = registryItem.complementaryProductName {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10))
                        Text("Complements \(complements)")
                            .font(AppTypography.caption2)
                    }
                    .foregroundStyle(AppColors.secondaryGray)
                }

                // Product name
                Text(product.name)
                    .font(AppTypography.subheadlineMedium)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Price & Quantity Requested
                HStack(alignment: .lastTextBaseline) {
                    Text(CurrencyFormatter.format(product.price))
                        .font(AppTypography.priceSmall)
                        .foregroundStyle(AppColors.primaryText)
                    
                    Spacer()
                    
                    if registryItem.requestedQuantity > 0 {
                        Text("Asked: \(registryItem.requestedQuantity - cartQuantity)")
                            .font(AppTypography.caption1Medium)
                            .foregroundStyle(AppColors.secondaryGray)
                    }
                }

                // Progress Area (Compact)
                if isGroupGifting && !isPurchased {
                    ContributionProgressBar(
                        progress: registryItem.progress,
                        currentAmount: registryItem.currentAmount,
                        targetAmount: registryItem.targetAmount,
                        showLabels: true,
                        height: 4,
                        tint: isFunded ? AppColors.primaryDark : AppColors.accentRed
                    )
                    .padding(.top, AppSpacing.xxxs)
                }

                // Action buttons (only for active items)
                if !isCompleted {
                    actionButtons
                        .padding(.top, AppSpacing.xs)
                }
            }
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.sm)
        }
        .frame(maxWidth: .infinity)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
        .softShadow()
        .opacity(isCompleted ? 0.5 : 1.0)
        .onTapGesture {
            onTap?()
        }
    }

    // MARK: - Action Buttons

    @ViewBuilder
    private var actionButtons: some View {
        if isGroupGifting {
            // Group gifting: Contribute button only
            Button {
                onContribute?()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 12, weight: .semibold))
                    Text("Contribute")
                        .font(AppTypography.buttonSmall)
                }
                .foregroundStyle(AppColors.primaryDark)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(AppColors.white)
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .strokeBorder(AppColors.primaryDark.opacity(0.2), lineWidth: 1.5)
                }
            }
            .buttonStyle(.plain)
        } else {
            if cartQuantity > 0 {
                // Quantity Toggle
                HStack(spacing: 0) {
                    Button {
                        if cartQuantity > 0 {
                            cartQuantity -= 1
                            // In a real app, update cart
                        }
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppColors.primaryDark)
                            .frame(width: 40, height: 40)
                    }

                    Spacer()
                    
                    Text("\(cartQuantity)")
                        .font(AppTypography.buttonSmall)
                        .foregroundStyle(AppColors.primaryDark)
                    
                    Spacer()

                    Button {
                        if cartQuantity < registryItem.requestedQuantity {
                            cartQuantity += 1
                            onPurchase?()
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(cartQuantity >= registryItem.requestedQuantity ? AppColors.secondaryGray : AppColors.primaryDark)
                            .frame(width: 40, height: 40)
                    }
                    .disabled(cartQuantity >= registryItem.requestedQuantity)
                }
                .background(AppColors.white)
                .clipShape(Capsule())
                .overlay {
                    Capsule()
                        .strokeBorder(AppColors.primaryDark.opacity(0.2), lineWidth: 1.5)
                }
                .frame(height: 40)
            } else {
                // Group Gift (Expanded) + Add to cart (SF-only)
                HStack(spacing: AppSpacing.xs) {
                    Button {
                        onEnableGroupGifting?()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 10, weight: .semibold))
                            Text("Group Gift")
                                .font(AppTypography.buttonSmall)
                        }
                        .foregroundStyle(AppColors.primaryDark)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(AppColors.white)
                        .clipShape(Capsule())
                        .overlay {
                            Capsule()
                                .strokeBorder(AppColors.primaryDark.opacity(0.2), lineWidth: 1.5)
                        }
                    }
                    .buttonStyle(.plain)

                    Button {
                        cartQuantity = 1
                        onPurchase?()
                    } label: {
                        Image(systemName: "cart")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(AppColors.primaryDark)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Image URL

    private var imageURL: String {
        let seed = product.name.replacingOccurrences(of: " ", with: ",")
        return "https://loremflickr.com/400/400/\(seed),product?lock=\(abs(product.id.hashValue % 100))"
    }
}

// MARK: - Preview

#Preview("Registry Item Card") {
    ScrollView {
        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 16) {
            RegistryItemCard(
                product: Product.mockList[0],
                registryItem: RegistryItem.mockList[0],
                isGroupGifting: true
            )
            RegistryItemCard(
                product: Product.mockList[1],
                registryItem: RegistryItem.mockList[1]
            )
            RegistryItemCard(
                product: Product.mockList[2],
                registryItem: RegistryItem.mockList[2]
            )
            RegistryItemCard(
                product: Product.mockList[3],
                registryItem: RegistryItem.mockList[3]
            )
        }
        .padding(20)
    }
    .background(AppColors.background)
}
