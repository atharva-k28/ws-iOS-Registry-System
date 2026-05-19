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

    @State private var isProcessingCheckout = false
    @State private var checkoutError: String? = nil
    @State private var showCheckoutErrorAlert = false
    @State private var showCheckoutSuccessAlert = false

    var body: some View {
        VStack(spacing: 0) {
            // Cart Items List
            if cartService.items.isEmpty {
                emptyCartView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                .frame(maxWidth: .infinity)
                
                checkoutSection
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appBackground()
        .navigationTitle("Your Bag")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                GlassButton(icon: "chevron.left") {
                    dismiss()
                }
            }
        }
        .alert("Checkout Success", isPresented: $showCheckoutSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Thank you for your purchase! The registry items have been updated.")
        }
        .alert("Checkout Failed", isPresented: $showCheckoutErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(checkoutError ?? "An unknown error occurred during checkout.")
        }
    }

    // MARK: - Components

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
                Task {
                    isProcessingCheckout = true
                    do {
                        // Loop through all items in the cart and update them in Supabase
                        for item in cartService.items {
                            guard let registryItem = item.registryItem else { continue }
                            let price = item.product?.price ?? 0.0
                            let totalAmount = price * Double(item.quantity)
                            
                            // Call EventService.shared.purchaseRegistryItem to update database
                            try await EventService.shared.purchaseRegistryItem(
                                id: registryItem.id,
                                quantityPurchasedDelta: item.quantity,
                                totalAmount: totalAmount,
                                isCashFund: registryItem.isCashFund ?? false
                            )
                        }
                        
                        // Clear cart upon successful database updates
                        cartService.clearCart()
                        isProcessingCheckout = false
                        showCheckoutSuccessAlert = true
                    } catch {
                        isProcessingCheckout = false
                        checkoutError = error.localizedDescription
                        showCheckoutErrorAlert = true
                    }
                }
            } label: {
                HStack {
                    if isProcessingCheckout {
                        ProgressView()
                            .tint(.white)
                            .padding(.trailing, 8)
                    }
                    Text(isProcessingCheckout ? "Processing..." : "Checkout")
                        .font(AppTypography.buttonLarge)
                    Spacer()
                    if !isProcessingCheckout {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                .foregroundStyle(.white)
                .padding(.horizontal, AppSpacing.xl)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(AppColors.primaryDark)
                .clipShape(Capsule())
                .softShadow()
            }
            .disabled(isProcessingCheckout)
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
                Text((item.eventName ?? "Default Event").uppercased())
                    .font(AppTypography.caption2)
                    .foregroundStyle(AppColors.accentRed)
                    .tracking(1)
                
                Text(item.product?.name ?? "Unknown Product")
                    .font(AppTypography.subheadlineMedium)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(2)
                
                HStack {
                    Text(CurrencyFormatter.format(item.product?.price ?? 0.0))
                        .font(AppTypography.priceSmall)
                        .foregroundStyle(AppColors.primaryDark)
                    
                    Spacer()
                    
                    // Quantity Toggle
                    HStack(spacing: 0) {
                        Button {
                            CartService.shared.updateQuantity(for: item.id, delta: -1)
                        } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(AppColors.primaryDark)
                                .frame(width: 28, height: 28)
                        }

                        Text("\(item.quantity)")
                            .font(AppTypography.caption1Medium)
                            .foregroundStyle(AppColors.primaryDark)
                            .frame(minWidth: 20)

                        Button {
                            if item.quantity < (item.registryItem?.quantityNeeded ?? 1) {
                                CartService.shared.updateQuantity(for: item.id, delta: 1)
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(item.quantity >= (item.registryItem?.quantityNeeded ?? 1) ? AppColors.secondaryGray : AppColors.primaryDark)
                                .frame(width: 28, height: 28)
                        }
                        .disabled(item.quantity >= (item.registryItem?.quantityNeeded ?? 1))
                    }
                    .background(AppColors.backgroundGray.opacity(0.5))
                    .clipShape(Capsule())
                }
            }
        }
        .padding(AppSpacing.sm)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
        .softShadow()
    }
    
    private var imageURL: String {
        if let imageUrl = item.product?.imageUrl, !imageUrl.isEmpty {
            return imageUrl
        }
        if let imageUrl = item.registryItem?.imageUrl, !imageUrl.isEmpty {
            return imageUrl
        }
        let name = item.product?.name ?? "Product"
        let seed = name.replacingOccurrences(of: " ", with: ",")
        let id = item.product?.id ?? UUID()
        return "https://loremflickr.com/200/200/\(seed),product?lock=\(abs(id.hashValue % 100))"
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
