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
                            // Complements field removed as it's not in the DB schema
                            
                            Text(product.name)
                                .font(AppTypography.premiumTitle)
                                .foregroundStyle(AppColors.primaryText)
                            
                            // Price & Asked Qty
                            HStack(alignment: .lastTextBaseline) {
                                Text(CurrencyFormatter.format(product.price))
                                    .font(AppTypography.title1)
                                    .foregroundStyle(AppColors.primaryDark)
                                
                                Spacer()
                                
                                if (item.quantityNeeded ?? 0) > 0 {
                                    Text("Asked: \((item.quantityNeeded ?? 0) - cartQuantity)")
                                        .font(AppTypography.subheadlineMedium)
                                        .foregroundStyle(AppColors.secondaryGray)
                                }
                            }
                        }

                        // Description
                        if let desc = product.description {
                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text("About this item")
                                    .font(AppTypography.subheadlineMedium)
                                
                                Text(desc)
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppColors.secondaryGray)
                                    .lineSpacing(4)
                            }
                        }

                        // Host Note removed as it's not in the DB schema

                        // Progress (for Group Gifting)
                        let targetAmount = item.price * Double(item.quantityNeeded ?? 1)
                        if isGroupGifting && (item.fundedAmount ?? 0.0) < targetAmount {
                            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                Text("Contribution Progress")
                                    .font(AppTypography.subheadlineMedium)
                                
                                ContributionProgressBar(
                                    progress: item.progress,
                                    currentAmount: item.fundedAmount ?? 0.0,
                                    targetAmount: targetAmount,
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
                    let targetAmount = item.price * Double(item.quantityNeeded ?? 1)
                    if (item.fundedAmount ?? 0.0) < targetAmount {
                        if isGroupGifting {
                            // Group Gifting: Only Contribute
                            Button {
                                // Contribute action
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
                                        if cartQuantity < (item.quantityNeeded ?? 1) {
                                            cartQuantity += 1
                                            CartService.shared.addToCart(product: product, registryItem: item, eventName: eventName)
                                        }
                                    } label: {
                                        Image(systemName: "plus")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundStyle(cartQuantity >= (item.quantityNeeded ?? 1) ? AppColors.secondaryGray : AppColors.primaryDark)
                                            .frame(width: 56, height: 56)
                                    }
                                    .disabled(cartQuantity >= (item.quantityNeeded ?? 1))
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
                                        // Enable Group Gift
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
