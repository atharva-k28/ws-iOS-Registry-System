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
    let eventName: String
    let isGroupGifting: Bool
    var onContribute: (() -> Void)? = nil
    var onEnableGroupGifting: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss
    @State private var cartQuantity = 0

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
                            
                            // Price & Asked Qty
                            HStack(alignment: .lastTextBaseline) {
                                Text(CurrencyFormatter.format(product.price))
                                    .font(AppTypography.title1)
                                    .foregroundStyle(AppColors.primaryDark)
                                
                                Spacer()
                                
                                if item.requestedQuantity > 0 {
                                    Text("Asked: \(item.requestedQuantity - cartQuantity)")
                                        .font(AppTypography.subheadlineMedium)
                                        .foregroundStyle(AppColors.secondaryGray)
                                }
                            }
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
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
                        }

                        // Progress (for Group Gifting)
                        if isGroupGifting && !item.isPurchased {
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
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppColors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    
                    Spacer(minLength: 120)
                }
            }
            .appBackground()
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    GlassButton(icon: "xmark", iconSize: 14) {
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: AppSpacing.sm) {
                    if !item.isPurchased {
                        if isGroupGifting {
                            // Group Gifting: Only Contribute
                            Button {
                                onContribute?()
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
                        } else {
                            // Purchase Item: Group Gift + Add to cart / Toggle
                            if cartQuantity > 0 {
                                // Quantity Toggle
                                HStack {
                                    Button {
                                        if cartQuantity > 0 { cartQuantity -= 1 }
                                    } label: {
                                        Image(systemName: "minus")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundStyle(AppColors.primaryDark)
                                            .frame(width: 56, height: 56)
                                    }

                                    Spacer()
                                    
                                    Text("\(cartQuantity)")
                                        .font(AppTypography.buttonLarge)
                                        .foregroundStyle(AppColors.primaryDark)
                                    
                                    Spacer()

                                    Button {
                                        if cartQuantity < item.requestedQuantity {
                                            cartQuantity += 1
                                            CartService.shared.addToCart(product: product, registryItem: item, eventName: eventName)
                                        }
                                    } label: {
                                        Image(systemName: "plus")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundStyle(cartQuantity >= item.requestedQuantity ? AppColors.secondaryGray : AppColors.primaryDark)
                                            .frame(width: 56, height: 56)
                                    }
                                    .disabled(cartQuantity >= item.requestedQuantity)
                                }
                                .background(AppColors.white)
                                .clipShape(Capsule())
                                .overlay {
                                    Capsule()
                                        .strokeBorder(AppColors.primaryDark, lineWidth: 1.5)
                                }
                                .frame(height: 56)
                            } else {
                                HStack(spacing: AppSpacing.md) {
                                    Button {
                                        onEnableGroupGifting?()
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: "person.2.fill")
                                                .font(.system(size: 14, weight: .semibold))
                                            Text("Group Gift")
                                                .font(AppTypography.buttonLarge)
                                        }
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
                                        cartQuantity = 1
                                        CartService.shared.addToCart(product: product, registryItem: item, eventName: eventName)
                                    } label: {
                                        Image(systemName: "cart.badge.plus")
                                            .font(.system(size: 20, weight: .semibold))
                                            .foregroundStyle(.white)
                                            .frame(width: 56, height: 56)
                                            .background(AppColors.primaryDark)
                                            .clipShape(Circle())
                                    }
                                }
                            }
                        }
                    } else {
                        Text("Item Purchased")
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
