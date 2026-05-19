//
//  PairsWithRail.swift
//  iOS_Registry_System
//
//  Horizontal scrolling related products rail
//

import SwiftUI

struct PairsWithRail: View {
    let products: [Product]
    var isLoading: Bool = false
    let onSelect: (Product) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("PAIRS BEAUTIFULLY WITH")
                .font(AppTypography.caption1Medium)
                .tracking(1.5)
                .foregroundColor(AppColors.secondaryGray)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    if isLoading && products.isEmpty {
                        ForEach(0..<4, id: \.self) { _ in
                            loadingCard
                        }
                    } else {
                        ForEach(products.prefix(4)) { product in
                            Button {
                                onSelect(product)
                            } label: {
                                productCard(product)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, -AppSpacing.screenHorizontal)
            .padding(.leading, AppSpacing.screenHorizontal)
        }
    }

    private func productCard(_ product: Product) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            ZStack {
                AppColors.backgroundGray
                    .overlay {
                        let urlString = product.imageUrl ?? "https://loremflickr.com/200/200/\(product.name.replacingOccurrences(of: " ", with: ",")),kitchen?lock=\(abs(product.id.hashValue % 100))"
                        AsyncImage(url: URL(string: urlString)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: "fork.knife")
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.secondaryGray.opacity(0.3))
                        }
                    }
            }
            .frame(width: 120, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm, style: .continuous))

            Text(product.name)
                .font(AppTypography.caption1)
                .foregroundColor(AppColors.primaryText)
                .lineLimit(2)
                .frame(width: 120, alignment: .leading)

            Text(CurrencyFormatter.format(product.price))
                .font(AppTypography.caption1Medium)
                .foregroundColor(AppColors.primaryText)
        }
        .contentShape(Rectangle())
    }

    private var loadingCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            RoundedRectangle(cornerRadius: AppCornerRadius.sm, style: .continuous)
                .fill(AppColors.backgroundGray)
                .frame(width: 120, height: 120)
                .redacted(reason: .placeholder)

            RoundedRectangle(cornerRadius: AppCornerRadius.xs, style: .continuous)
                .fill(AppColors.backgroundGray)
                .frame(width: 104, height: 14)

            RoundedRectangle(cornerRadius: AppCornerRadius.xs, style: .continuous)
                .fill(AppColors.backgroundGray)
                .frame(width: 62, height: 14)
        }
        .redacted(reason: .placeholder)
    }
}

#Preview {
    PairsWithRail(products: [], onSelect: { _ in })
        .padding()
}
