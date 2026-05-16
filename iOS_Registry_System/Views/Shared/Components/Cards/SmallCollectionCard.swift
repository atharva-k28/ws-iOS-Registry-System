//
//  SmallCollectionCard.swift
//  iOS_Registry_System
//
//  Small grid collection card for Home View
//

import SwiftUI

struct SmallCollectionCard: View {
    let title: String
    let imageSeed: String
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Image
                AsyncImage(url: URL(string: "https://loremflickr.com/300/300/cookware,tableware,plates?lock=\(abs(imageSeed.hashValue % 100))")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(height: 140)
                .clipped()
                
                // Footer
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppTypography.bodyMedium)
                        .foregroundColor(AppColors.primaryText)
                    
                    HStack(spacing: 4) {
                        Text("Shop now")
                            .font(AppTypography.caption1)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(AppColors.secondaryGray)
                }
                .padding(AppSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.white)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
            .softShadow()
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SmallCollectionCard(title: "Coffee HQ", imageSeed: "coffee")
        .frame(width: 160)
        .padding()
        .background(AppColors.background)
}
