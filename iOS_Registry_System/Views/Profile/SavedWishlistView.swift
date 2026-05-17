//
//  SavedWishlistView.swift
//  iOS_Registry_System
//
//  Grid view for saved products and wishlist items
//

import SwiftUI
import Combine

struct WishlistItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let price: Int
    let imageUrl: String
}

// Persistent store so items removed survive back navigation
class WishlistStore: ObservableObject {
    static let shared = WishlistStore()

    @Published var savedItems: [WishlistItem] = [
        WishlistItem(title: "Smeg Kettle",   subtitle: "Matte Black", price: 190, imageUrl: "https://images.unsplash.com/photo-1590432314545-2b4a1b0b5c1c?w=600&q=80"),
        WishlistItem(title: "Vitamix Blender", subtitle: "Pro Series", price: 450, imageUrl: "https://images.unsplash.com/photo-1596541603953-29a59b5896a2?w=600&q=80"),
        WishlistItem(title: "Linen Apron",   subtitle: "Chef's Cut",  price: 45,  imageUrl: "https://images.unsplash.com/photo-1588698715873-41bb6239bc7a?w=600&q=80"),
        WishlistItem(title: "Wine Glasses",  subtitle: "Set of 6",    price: 85,  imageUrl: "https://images.unsplash.com/photo-1585553616435-2dc0a54e271d?w=600&q=80")
    ]

    func remove(_ item: WishlistItem) {
        savedItems.removeAll { $0.id == item.id }
    }
}

struct SavedWishlistView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = WishlistStore.shared

    let columns = [GridItem(.flexible(), spacing: AppSpacing.md), GridItem(.flexible(), spacing: AppSpacing.md)]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {

                Text("Your carefully curated\ncollection.")
                    .font(.system(size: 32, weight: .regular, design: .serif))
                    .foregroundStyle(AppColors.primaryText)
                    .lineSpacing(3)
                    .padding(.top, AppSpacing.sm)

                if store.savedItems.isEmpty {
                    VStack(spacing: AppSpacing.md) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.secondaryGray.opacity(0.3))
                        Text("No saved items yet.")
                            .font(AppTypography.bodyMedium)
                            .foregroundColor(AppColors.secondaryGray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                        ForEach(store.savedItems) { item in
                            wishlistCard(item: item)
                        }
                    }
                }

                Color.clear.frame(height: 40)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.md)
        }
        .appBackground()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.primaryText)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(AppColors.white)
                                .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
                        )
                }
                .buttonStyle(.plain)
            }
            ToolbarItem(placement: .principal) {
                Text("SAVED & WISHLIST")
                    .font(AppTypography.caption1Medium)
                    .tracking(1.5)
                    .foregroundColor(AppColors.secondaryGray)
            }
        }
    }

    private func wishlistCard(item: WishlistItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: item.imageUrl)) { img in
                    img.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(hex: "EDE8E3")
                }
                .frame(height: 160)
                .clipped()

                // Heart button — removes item from saved
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        store.remove(item)
                    }
                }) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.accentRed)
                        .padding(8)
                        .background(AppColors.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                }
                .padding(AppSpacing.sm)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)

                Text(item.subtitle)
                    .font(AppTypography.caption1)
                    .foregroundStyle(AppColors.secondaryGray)

                Text("$\(item.price)")
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)
                    .padding(.top, 4)
            }
            .padding(AppSpacing.sm)
        }
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
        .softShadow()
    }
}

#Preview {
    NavigationStack {
        SavedWishlistView()
    }
}
