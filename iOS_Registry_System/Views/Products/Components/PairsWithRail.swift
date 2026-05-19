//
//  PairsWithRail.swift
//  iOS_Registry_System
//
//  Horizontal scrolling related products rail
//

import SwiftUI

struct PairsWithRail: View {
    let products: [Product]
    let onSelect: (Product) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("PAIRS BEAUTIFULLY WITH")
                .font(AppTypography.caption1Medium)
                .tracking(1.5)
                .foregroundColor(AppColors.secondaryGray)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(products.prefix(4)) { product in
                        Button {
                            onSelect(product)
                        } label: {
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
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, -AppSpacing.screenHorizontal)
            .padding(.leading, AppSpacing.screenHorizontal)
        }
    }
}

#Preview {
    PairsWithRail(products: [], onSelect: { _ in })
        .padding()
}
