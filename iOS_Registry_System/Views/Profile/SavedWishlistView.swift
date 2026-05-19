//
//  SavedWishlistView.swift
//  iOS_Registry_System
//
//  Grid view for saved products and wishlist items
//

import SwiftUI
import Supabase

struct SavedWishlistView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var savedProducts: [Product] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    let columns = [GridItem(.flexible(), spacing: AppSpacing.md), GridItem(.flexible(), spacing: AppSpacing.md)]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {

                Text("Your carefully curated\ncollection.")
                    .font(.system(size: 32, weight: .regular, design: .serif))
                    .foregroundStyle(AppColors.primaryText)
                    .lineSpacing(3)
                    .padding(.top, AppSpacing.sm)

                if isLoading {
                    InlineLoadingView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                } else if savedProducts.isEmpty {
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
                    if let errorMessage {
                        Text(errorMessage)
                            .font(AppTypography.footnote)
                            .foregroundColor(AppColors.secondaryGray)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                        ForEach(savedProducts) { product in
                            wishlistCard(product: product)
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
        .task {
            await loadWishlist()
        }
    }

    private func wishlistCard(product: Product) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: product.imageUrl.flatMap(URL.init(string:))) { img in
                    img.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    AppColors.backgroundGray
                }
                .frame(height: 160)
                .clipped()

                Button(action: {
                    Task {
                        await remove(product)
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
                Text(product.name)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)

                Text(product.brand ?? product.category)
                    .font(AppTypography.caption1)
                    .foregroundStyle(AppColors.secondaryGray)

                Text(CurrencyFormatter.format(product.price))
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

    private func loadWishlist() async {
        guard let userId = AuthService.shared.currentUser?.id else {
            savedProducts = []
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await SupabaseManager.shared.client
                .from("product_wishlists")
                .select("product_id")
                .eq("user_id", value: userId.uuidString)
                .execute()

            struct Row: Decodable {
                let productId: UUID

                enum CodingKeys: String, CodingKey {
                    case productId = "product_id"
                }
            }

            let rows = try JSONDecoder().decode([Row].self, from: response.data)
            savedProducts = try await ProductService.shared.fetchProducts(ids: rows.map(\.productId))
        } catch {
            savedProducts = []
            errorMessage = error.localizedDescription
        }
    }

    private func remove(_ product: Product) async {
        guard let userId = AuthService.shared.currentUser?.id else { return }

        do {
            try await SupabaseManager.shared.client
                .from("product_wishlists")
                .delete()
                .eq("user_id", value: userId.uuidString)
                .eq("product_id", value: product.id.uuidString)
                .execute()

            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                savedProducts.removeAll { $0.id == product.id }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationStack {
        SavedWishlistView()
    }
}
