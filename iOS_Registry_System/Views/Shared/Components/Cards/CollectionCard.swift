//
//  CollectionCard.swift
//  iOS_Registry_System
//
//  Large vertical collection card for Home View
//

import SwiftUI

struct CollectionCard: View {
    let title: String
    let category: String
    let actionText: String
    let imageSeed: String
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Image Header
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.2)
                }
                .frame(height: 240)
                .clipped()
                
                // Content Footer
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(category.uppercased())
                        .font(AppTypography.caption1Medium)
                        .tracking(1.5)
                        .foregroundColor(AppColors.secondaryGray)
                    
                    Text(title)
                        .font(AppTypography.premiumTitle)
                        .foregroundColor(AppColors.primaryText)
                        .lineLimit(2)
                        .padding(.bottom, AppSpacing.xxs)
                    
                    HStack {
                        Text(actionText.uppercased())
                            .font(AppTypography.caption1Medium)
                            .fontWeight(.bold)
                            .tracking(1.0)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(AppColors.primaryDark)
                }
                .padding(AppSpacing.xl)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.white)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl, style: .continuous))
            .softShadow()
        }
        .buttonStyle(.plain)
    }

    private var imageUrl: String {
        let normalized = imageSeed.lowercased()
        if normalized.contains("margarita") { return "https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=800" }
        if normalized.contains("outdoor") { return "https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=800" }
        if normalized.contains("grill") { return "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=800" }
        if normalized.contains("kitchen") { return "https://images.unsplash.com/photo-1556911220-e15024029581?w=800" }
        return "https://loremflickr.com/400/300/tableware,cookware?lock=\(abs(imageSeed.hashValue % 100))"
    }
}

#Preview {
    CollectionCard(
        title: "Mix bright, bar-worthy cocktails",
        category: "Margarita Season",
        actionText: "Shop Bar",
        imageSeed: "margarita"
    )
    .padding()
    .background(AppColors.background)
}
