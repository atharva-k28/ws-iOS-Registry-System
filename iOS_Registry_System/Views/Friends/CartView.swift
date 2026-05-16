//
//  CartView.swift
//  iOS_Registry_System
//
//  Shopping cart screen showing items to be purchased
//

import SwiftUI

struct CartView: View {
    @StateObject private var cartService = CartService.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            header
            
            if cartService.items.isEmpty {
                emptyCartView
            } else {
                ScrollView {
                    VStack(spacing: AppSpacing.md) {
                        ForEach(cartService.items) { item in
                            CartItemRow(item: item)
                        }
                    }
                    .padding(AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.md)
                }
                
                checkoutSection
            }
        }
        .appBackground()
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Components

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.primaryDark)
                    .frame(width: 40, height: 40)
                    .background(AppColors.white)
                    .clipShape(Circle())
                    .softShadow()
            }
            
            Spacer()
            
            Text("Your Cart")
                .font(AppTypography.title3)
                .foregroundStyle(AppColors.primaryText)
            
            Spacer()
            
            // Empty placeholder for balance
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, 10)
        .padding(.bottom, AppSpacing.sm)
    }

    private var emptyCartView: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            
            Image(systemName: "cart.badge.minus")
                .font(.system(size: 80))
                .foregroundStyle(AppColors.secondaryGray.opacity(0.3))
            
            VStack(spacing: AppSpacing.xs) {
                Text("Your cart is empty")
                    .font(AppTypography.title2)
                Text("Browse registry items to add them here.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryGray)
            }
            
            Button {
                dismiss()
            } label: {
                Text("Browse Items")
                    .font(AppTypography.buttonLarge)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(AppColors.primaryDark)
                    .clipShape(Capsule())
            }
            
            Spacer()
        }
        .multilineTextAlignment(.center)
    }

    private var checkoutSection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Text("Total")
                    .font(AppTypography.headline)
                Spacer()
                Text(CurrencyFormatter.format(cartService.totalPrice))
                    .font(AppTypography.price)
                    .foregroundStyle(AppColors.primaryDark)
            }
            .padding(.horizontal, AppSpacing.xs)
            
            Button {
                // Checkout action
            } label: {
                HStack {
                    Text("Checkout")
                        .font(AppTypography.buttonLarge)
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, AppSpacing.xl)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(AppColors.primaryDark)
                .clipShape(Capsule())
                .softShadow()
            }
        }
        .padding(AppSpacing.lg)
        .padding(.bottom, AppSpacing.tabBarHeight + AppSpacing.tabBarBottomOffset)
        .background(AppColors.surface)
        .clipShape(RoundedCorner(radius: AppCornerRadius.xl, corners: [.topLeft, .topRight]))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: -5)
    }
}

// MARK: - Cart Item Row

struct CartItemRow: View {
    let item: CartItem
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Product Image
            AsyncImage(url: URL(string: imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.1)
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.eventName.uppercased())
                    .font(AppTypography.caption2)
                    .foregroundStyle(AppColors.accentRed)
                    .tracking(1)
                
                Text(item.product.name)
                    .font(AppTypography.subheadlineMedium)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(2)
                
                HStack {
                    Text(CurrencyFormatter.format(item.product.price))
                        .font(AppTypography.priceSmall)
                        .foregroundStyle(AppColors.primaryDark)
                    
                    Spacer()
                    
                    Text("Qty: \(item.quantity)")
                        .font(AppTypography.caption1Medium)
                        .foregroundStyle(AppColors.secondaryGray)
                }
            }
        }
        .padding(AppSpacing.sm)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
        .softShadow()
    }
    
    private var imageURL: String {
        let seed = item.product.name.replacingOccurrences(of: " ", with: ",")
        return "https://loremflickr.com/200/200/\(seed),product?lock=\(abs(item.product.id.hashValue % 100))"
    }
}

// MARK: - Helpers

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
