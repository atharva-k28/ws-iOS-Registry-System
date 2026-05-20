//
//  ProductDetailView.swift
//  iOS_Registry_System
//
//  Product Detail Screen (Screen 2)
//

import SwiftUI
import Supabase

struct ProductDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let product: Product
    
    @State private var quantity: Int = 1
    @State private var showToast = false
    @State private var isFavorite = false
    @State private var showContributeSheet = false
    @State private var showARPreview = false
    @State private var relatedProducts: [Product] = []
    @State private var isLoadingRelatedProducts = false
    @State private var selectedRelatedProduct: Product?
    
    // Group Gifting Stats
    @State private var groupGiftingStats: (currentAmount: Double, targetAmount: Double, contributorsCount: Int)? = nil
    
    // Wishlist Logic
    @State private var wishlistErrorMessage: String? = nil
    
    // Registry Selection
    @State private var showRegistrySelection = false
    
    var body: some View {
        NavigationStack {
            productDetailContent
                .navigationDestination(isPresented: $showARPreview) {
                    ARPreviewView(product: product)
                        .navigationBarBackButtonHidden(true)
                }
        }
    }

    private var productDetailContent: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // MARK: Hero
                    heroCard
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.top, AppSpacing.md)
                    
                    VStack(alignment: .leading, spacing: AppSpacing.xl) {
                        // MARK: Title Block
                        titleBlock
                        
                        // MARK: Price & Quantity
                        priceRow
                        
                        // MARK: Group Gifting
                        if let stats = groupGiftingStats {
                            GroupGiftingCard(
                                currentAmount: stats.currentAmount,
                                targetAmount: stats.targetAmount,
                                contributorsCount: stats.contributorsCount
                            ) {
                                showContributeSheet = true
                            }
                        }
                        
                        // MARK: Pairs With
                        PairsWithRail(products: relatedProducts, isLoading: isLoadingRelatedProducts) { relatedProduct in
                            selectedRelatedProduct = relatedProduct
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.lg)
                    .padding(.bottom, 120) // Space for floating dock
                }
            }
            
            // MARK: Floating Dock
            floatingDock
            
            // MARK: Toast Notification
            if showToast {
                VStack {
                    Text(toastMessage)
                        .font(AppTypography.caption1Medium)
                        .foregroundColor(AppColors.white)
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.xs)
                        .background(AppColors.primaryDark)
                        .clipShape(Capsule())
                        .transition(.move(edge: .top).combined(with: .opacity))
                    Spacer()
                }
                .padding(.top, 60)
                .zIndex(1)
            }
        }
        .appBackground()
        .safeAreaInset(edge: .top) {
            topNavigationBar
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.xs)
                .padding(.bottom, AppSpacing.sm)
                .background(.ultraThinMaterial)
        }
        .sheet(isPresented: $showContributeSheet) {
            ContributeSheetView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showRegistrySelection) {
            SelectRegistrySheet(product: product) { event in
                Task {
                    do {
                        try await EventService.shared.addProductToRegistry(eventId: event.id, product: product)
                        await MainActor.run {
                            toastMessage = "Added to \(event.title)"
                            withAnimation { showToast = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation { showToast = false }
                            }
                        }
                    } catch {
                        print("Failed to add to registry: \(error)")
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
        }
        .sheet(item: $selectedRelatedProduct) { relatedProduct in
            ProductDetailView(product: relatedProduct)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
        .task {
            isLoadingRelatedProducts = true

            if let categoryProducts = try? await ProductService.shared.fetchProducts(category: product.category) {
                relatedProducts = categoryProducts.filter { $0.id != product.id }
            }

            let similarProducts = await AIService.shared.fetchSimilarProducts(
                targetProductId: product.id,
                targetProductName: product.name,
                targetCategory: product.category
            )
            if !similarProducts.isEmpty {
                relatedProducts = similarProducts
            }
            isLoadingRelatedProducts = false
            
            // Fetch group gifting stats if applicable
            groupGiftingStats = try? await EventService.shared.fetchGroupGiftingStats(for: product.id)
            
            // Check wishlist status
            await checkIfFavorited()
        }
    }
    
    @State private var toastMessage = "Added to cart"
    
    private func checkIfFavorited() async {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        do {
            let response = try await SupabaseManager.shared.client
                .from("product_wishlists")
                .select("product_id")
                .eq("user_id", value: userId.uuidString)
                .eq("product_id", value: product.id.uuidString)
                .execute()
            
            struct Row: Decodable { let product_id: UUID }
            let rows = try JSONDecoder().decode([Row].self, from: response.data)
            isFavorite = !rows.isEmpty
        } catch {
            print("Failed to check wishlist status: \(error)")
        }
    }
    
    private func toggleWishlist() {
        guard let userId = AuthService.shared.currentUser?.id else { return }
        let newState = !isFavorite
        withAnimation { isFavorite = newState }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        Task {
            do {
                if newState {
                    struct InsertPayload: Encodable {
                        let user_id: UUID
                        let product_id: UUID
                    }
                    try await SupabaseManager.shared.client
                        .from("product_wishlists")
                        .insert(InsertPayload(user_id: userId, product_id: product.id))
                        .execute()
                    
                    await MainActor.run {
                        toastMessage = "Added to wishlist"
                        withAnimation { showToast = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation { showToast = false }
                        }
                    }
                } else {
                    try await SupabaseManager.shared.client
                        .from("product_wishlists")
                        .delete()
                        .eq("user_id", value: userId.uuidString)
                        .eq("product_id", value: product.id.uuidString)
                        .execute()
                }
            } catch {
                print("Failed to toggle wishlist: \(error)")
                withAnimation { isFavorite = !newState }
            }
        }
    }
    
    // MARK: - Components
    
    private var topNavigationBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.primaryDark)
                    .frame(width: 44, height: 44)
                    .background(AppColors.white)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(AppColors.backgroundGray, lineWidth: 1))
            }
            
            Spacer()
            
            Text(product.category.uppercased())
                .font(AppTypography.caption1Medium)
                .tracking(1.5)
                .foregroundColor(AppColors.secondaryGray)
            
            Spacer()
            
            ShareLink(item: URL(string: "https://www.williams-sonoma.com")!) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.primaryDark)
                    .frame(width: 44, height: 44)
                    .background(AppColors.white)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(AppColors.backgroundGray, lineWidth: 1))
            }
        }
    }
    
    private var heroCard: some View {
        ZStack(alignment: .bottomLeading) {
            AppColors.backgroundGray
                .overlay {
                    let urlString = product.imageUrl ?? "https://loremflickr.com/600/600/\(product.name.replacingOccurrences(of: " ", with: ",")),cookware?lock=\(abs(product.id.hashValue % 100))"
                    AsyncImage(url: URL(string: urlString)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "frying.pan")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.secondaryGray.opacity(0.3))
                    }
                }
            
            // Top Right Heart Pill
            VStack {
                HStack {
                    Spacer()

                    VStack(spacing: AppSpacing.xs) {
                        Button {
                            toggleWishlist()
                        } label: {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 16))
                                .foregroundColor(isFavorite ? AppColors.accentRed : AppColors.primaryDark)
                                .frame(width: 36, height: 36)
                                .background(AppColors.white)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(isFavorite ? AppColors.accentRed : AppColors.backgroundGray, lineWidth: 1))
                        }

                        Button {
                            showARPreview = true
                        } label: {
                            Image(systemName: "arkit")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.primaryDark)
                                .frame(width: 36, height: 36)
                                .background(AppColors.white)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(AppColors.backgroundGray, lineWidth: 1))
                        }
                    }
                    .padding(AppSpacing.md)
                }
                Spacer()
            }
            
//            // Bottom Left Ivory Glass Pill
//            Text("Recommended for you")
//                .font(AppTypography.caption1.italic())
//                .foregroundColor(AppColors.primaryDark)
//                .padding(.horizontal, AppSpacing.md)
//                .padding(.vertical, 8)
//                .background(AppColors.white.opacity(0.85))
//                .clipShape(Capsule())
//                .padding(AppSpacing.md)
        }
        .frame(height: 300)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
    }
    
    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text((product.brand ?? product.category).uppercased())
                .font(AppTypography.caption2)
                .tracking(1.5)
                .foregroundColor(AppColors.secondaryGray)
            
            Text(product.name)
                .font(AppTypography.largeTitleSerif)
                .foregroundColor(AppColors.primaryText)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: AppSpacing.xxs) {
                HStack(spacing: 2) {
                    ForEach(0..<5) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.primaryDark)
                    }
                }
                Text("(186 reviews)")
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColors.secondaryGray)
            }
            .padding(.top, 4)
            
            Text(product.description ?? "Heirloom-quality pieces, selected for everyday luxury and built to anchor a beautiful registry.")
                .font(AppTypography.body)
                .foregroundColor(AppColors.secondaryGray)
                .padding(.top, AppSpacing.xs)
                .lineSpacing(4)
        }
    }
    
    private var priceRow: some View {
        HStack {
            Text(CurrencyFormatter.format(product.price))
                .font(AppTypography.largeTitleSerif)
                .foregroundColor(AppColors.primaryText)
            
            Spacer()
            
            QuantityStepper(quantity: $quantity)
        }
    }
    
    private var floatingDock: some View {
        HStack(spacing: AppSpacing.sm) {
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                showRegistrySelection = true
            } label: {
                Text("Add to registry")
                    .font(AppTypography.buttonMedium)
                    .foregroundColor(AppColors.primaryDark)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppColors.backgroundGray.opacity(0.6))
                    .clipShape(Capsule())
            }
            
            Button {
                if !isFavorite { toggleWishlist() }
            } label: {
                Text("Add to wishlist")
                    .font(AppTypography.buttonMedium)
                    .foregroundColor(AppColors.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(AppColors.accentRed)
                    .clipShape(Capsule())
                    .shadow(color: AppColors.accentRed.opacity(0.4), radius: 12, y: 4)
            }
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.sm)
        .background(
            Capsule()
                .fill(.white.opacity(0.95))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 0)
        )
        .padding(.horizontal, AppSpacing.md)
        .padding(.bottom, AppSpacing.md)
    }
}
