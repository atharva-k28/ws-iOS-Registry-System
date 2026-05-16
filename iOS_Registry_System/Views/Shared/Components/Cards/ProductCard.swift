//
//  ProductCard.swift
//  iOS_Registry_System
//
//  Elegant product/gift card component
//

import SwiftUI

// MARK: - Product Card

struct ProductCard: View {

    let product: Product
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: Image Area

                ZStack(alignment: .topTrailing) {
                    // Product Image
                    AsyncImage(url: URL(string: "https://loremflickr.com/300/300/\(product.name.replacingOccurrences(of: " ", with: ",")),cookware?lock=\(abs(product.id.hashValue % 100))")) { image in
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
                    .frame(height: 160)
                    .clipped()

                    // Badges and Actions
                    HStack(alignment: .top) {
                        if product.isAIRecommended {
                            AIBadge()
                        }
                        
                        Spacer()
                        
                        Button {
                            // Toggle favorite
                        } label: {
                            Image(systemName: "heart")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.primaryDark)
                                .frame(width: 32, height: 32)
                                .background(AppColors.white)
                                .clipShape(Circle())
                                .softShadow()
                        }
                    }
                    .padding(AppSpacing.xs)
                }

                // MARK: Details

                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    // Brand
                    if let brand = product.brand {
                        Text(brand.uppercased())
                            .font(AppTypography.caption2)
                            .foregroundStyle(AppColors.secondaryGray)
                            .tracking(1)
                    }

                    // Name
                    Text(product.name)
                        .font(AppTypography.subheadlineMedium)
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    // Price
                    Text(CurrencyFormatter.format(product.price))
                        .font(AppTypography.priceSmall)
                        .foregroundStyle(AppColors.primaryDark)
                        .padding(.top, AppSpacing.xxxs)
                }
                .padding(AppSpacing.sm)
            }
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
            .softShadow()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - AI Recommendation Badge

struct AIBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkles")
                .font(.system(size: 10, weight: .bold))
            Text("AI Pick")
                .font(AppTypography.caption2)
                .fontWeight(.semibold)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            LinearGradient(
                colors: [AppColors.accentRed, AppColors.accentRed.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview("Product Card") {
    ScrollView {
        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 16) {
            ForEach(Product.mockList) { product in
                ProductCard(product: product)
            }
        }
        .padding(20)
    }
    .background(AppColors.background)
}
