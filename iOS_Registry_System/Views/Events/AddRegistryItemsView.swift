//
//  AddRegistryItemsView.swift
//  iOS_Registry_System
//
//  Premium "Add Items to Registry" screen (Screen 2 of Event Creation).
//  Features:
//    - Dynamic self-healing category horizontal scroll filter
//    - Premium 2-column Pinterest/Gallery format matching Friend's Registry
//    - Interactive soft-shadow glass cards with dynamic capsule haptic toggles
//    - Real-time Supabase sync with Optimistic UI updates
//    - Database RLS and connection resilience with native popup alerts
//    - Fully scrollable safe CTA bar to avoid tab-bar collision
//

import SwiftUI

struct AddRegistryItemsView: View {
    let event: Event
    let isNewEvent: Bool
    let collaborators: [Collaborator]
    let mood: String?
    let onFinish: () -> Void

    @Environment(\.dismiss) private var dismiss

    init(event: Event, isNewEvent: Bool = false, collaborators: [Collaborator] = [], mood: String? = nil, onFinish: @escaping () -> Void) {
        self.event = event
        self.isNewEvent = isNewEvent
        self.collaborators = collaborators
        self.mood = mood
        self.onFinish = onFinish
    }
    
    // State variables
    @State private var products: [Product] = []
    @State private var registryItems: [RegistryItem] = []
    @State private var addedProductIds: Set<UUID> = []
    @State private var selectedCategory: String? = nil
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var isFinishing = false
    @State private var recommendations: [AIService.AIRecommendation] = []
    
    // Alert state variables for database troubleshooting
    @State private var showErrorAlert = false
    @State private var alertTitle = "Error"
    @State private var alertMessage = ""
    

    
    // Dynamically computed categories to always adapt to whatever is loaded in the catalog
    var dynamicCategories: [String] {
        let cats = Set(products.map { p in
            let cat = p.category.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !cat.isEmpty else { return "Other" }
            // Capitalize category beautifully
            return cat.prefix(1).uppercased() + cat.dropFirst().lowercased()
        })
        return cats.sorted()
    }
    
    var filteredProducts: [Product] {
        guard let category = selectedCategory else {
            return products
        }
        
        return products.filter { p in
            let normalizedCat = p.category.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return normalizedCat == category.lowercased()
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Title Block
            titleBlock
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.sm)
            
            // Categories Horizontal Scroll Filter
            categoriesFilter
                .padding(.bottom, AppSpacing.md)
            
            // Product Catalog list
            Group {
                if isLoading {
                    loadingView
                } else if let error = errorMessage {
                    errorState(error)
                } else if filteredProducts.isEmpty {
                    emptyState
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: AppSpacing.sectionGap) {
                            if selectedCategory == nil && !recommendations.isEmpty {
                                recommendationsSection
                            }
                            
                            productGrid(for: filteredProducts)
                        }
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                        .padding(.top, AppSpacing.xs)
                    }
                    .safeAreaInset(edge: .bottom) {
                        bottomCTABar
                            .padding(.top, AppSpacing.md)
                            .padding(.bottom, AppSpacing.tabBarHeight + AppSpacing.sm)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        AppColors.background.opacity(0.0),
                                        AppColors.background.opacity(0.8),
                                        AppColors.background
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                }
            }
        }
        .appBackground()
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .tabBar) // Collapses the tab bar during layout stack
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.primaryText)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(.regularMaterial)
                                .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 0.5))
                        )
                }
                .buttonStyle(.plain)
            }
            
            ToolbarItem(placement: .principal) {
                Text("BUILD REGISTRY")
                    .font(AppTypography.caption1Medium)
                    .tracking(1.5)
                    .foregroundStyle(AppColors.secondaryGray)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if isNewEvent {
                    Button {
                        handleSkip()
                    } label: {
                        Text("Skip")
                            .font(AppTypography.footnoteSemibold)
                            .foregroundStyle(AppColors.secondaryGray)
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(AppColors.backgroundGray.opacity(0.6))
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(isFinishing)
                } else {
                    Button {
                        handleFinish()
                    } label: {
                        if isFinishing {
                            ProgressView()
                                .tint(AppColors.accentRed)
                        } else {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(AppColors.accentRed)
                                .padding(.horizontal, AppSpacing.md)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(AppColors.accentRed.opacity(0.12))
                                )
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(isFinishing)
                }
            }
        }
        .alert(alertTitle, isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .task {
            await loadData()
        }
    }
    
    // MARK: - Components
    
    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("ADD ITEMS TO REGISTRY")
                    .font(AppTypography.caption1Medium)
                    .tracking(2)
                    .foregroundStyle(AppColors.secondaryGray)
                Spacer()
                
                // Count badge
                Text("\(addedProductIds.count) added")
                    .font(AppTypography.caption2)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppColors.primaryDark)
                    .clipShape(Capsule())
            }
            
            Text("Select items for\nyour gift list.")
                .font(.system(size: 30, weight: .regular, design: .serif))
                .foregroundStyle(AppColors.primaryText)
        }
    }
    
    private var categoriesFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.xs) {
                StatusChip(
                    title: "All",
                    isSelected: selectedCategory == nil
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedCategory = nil
                    }
                }
                
                ForEach(dynamicCategories, id: \.self) { category in
                    StatusChip(
                        title: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .tint(AppColors.primaryDark)
            Text("Loading products…")
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.secondaryGray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorState(_ message: String) -> some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundStyle(AppColors.accentRed)
            Text("Failed to load catalog")
                .font(AppTypography.bodyMedium)
                .foregroundStyle(AppColors.primaryText)
            Text(message)
                .font(AppTypography.caption1)
                .foregroundStyle(AppColors.secondaryGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button("Retry") {
                Task { await loadData() }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, 8)
            .background(AppColors.primaryText)
            .clipShape(Capsule())
            .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyState: some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: "cart.badge.questionmark")
                .font(.system(size: 36))
                .foregroundStyle(AppColors.secondaryGray.opacity(0.6))
            Text("No items found")
                .font(AppTypography.bodyMedium)
                .foregroundStyle(AppColors.primaryText)
            Text("Try choosing another category.")
                .font(AppTypography.caption1)
                .foregroundStyle(AppColors.secondaryGray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    private func productGrid(for items: [Product]) -> some View {
        LazyVGrid(columns: gridColumns, spacing: 12) {
            ForEach(items) { item in
                catalogCard(product: item)
            }
        }
    }
    
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.xs) {
                Text("✨ AI Suggested for You")
                    .font(AppTypography.premiumTitle)
                    .foregroundStyle(AppColors.primaryText)
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(recommendations) { rec in
                        if let product = products.first(where: { $0.id.uuidString.lowercased() == rec.product_id.lowercased() }) {
                            aiRecommendationCard(product: product, reason: rec.reason, matchScore: rec.match_score)
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, 8)
            }
            .padding(.horizontal, -AppSpacing.screenHorizontal)
        }
    }
    
    private func aiRecommendationCard(product: Product, reason: String, matchScore: Int) -> some View {
        let isAdded = addedProductIds.contains(product.id)
        
        return VStack(alignment: .leading, spacing: 0) {
            // Image Area
            ZStack(alignment: .topTrailing) {
                let urlString = product.imageUrl ?? "https://loremflickr.com/300/300/\(product.name.replacingOccurrences(of: " ", with: ",")),cookware?lock=\(abs(product.id.hashValue % 100))"
                AsyncImage(url: URL(string: urlString)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 120)
                        .clipped()
                } placeholder: {
                    Color.gray.opacity(0.1)
                        .frame(height: 120)
                }
                
                // Match score badge
                Text("\(matchScore)% Match")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.accentRed)
                    .clipShape(Capsule())
                    .padding(8)
            }
            
            // Details
            VStack(alignment: .leading, spacing: 6) {
                Text(product.name)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                
                Text(reason)
                    .font(AppTypography.caption1)
                    .foregroundStyle(AppColors.secondaryGray)
                    .lineLimit(2)
                    .frame(height: 32, alignment: .topLeading)
                
                HStack {
                    Text(CurrencyFormatter.format(product.price))
                        .font(AppTypography.priceSmall)
                        .foregroundStyle(AppColors.primaryDark)
                    Spacer()
                    
                    Button {
                        toggleProduct(product)
                    } label: {
                        Text(isAdded ? "Added" : "+ Add")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(isAdded ? .white : AppColors.primaryText)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule().fill(isAdded ? AnyShapeStyle(AppColors.accentRed) : AnyShapeStyle(AppColors.backgroundGray.opacity(0.6)))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppSpacing.sm)
        }
        .frame(width: 240)
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
        .softShadow()
    }
    
    private func catalogCard(product: Product) -> some View {
        let isAdded = addedProductIds.contains(product.id)
        
        return VStack(alignment: .leading, spacing: 0) {
            // Image Area
            ZStack(alignment: .topTrailing) {
                let urlString = product.imageUrl ?? "https://loremflickr.com/300/300/\(product.name.replacingOccurrences(of: " ", with: ",")),cookware?lock=\(abs(product.id.hashValue % 100))"
                AsyncImage(url: URL(string: urlString)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 140)
                        .clipped()
                } placeholder: {
                    Color.gray.opacity(0.1)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(height: 140)
                        .overlay {
                            Image(systemName: "gift.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(AppColors.secondaryGray.opacity(0.4))
                        }
                }
                .frame(height: 140)
                .frame(maxWidth: .infinity)
                .clipped()
                
                // Top corner badges
                HStack(alignment: .top) {
                    if product.isBestSeller ?? false {
                        AIBadge()
                    }
                    Spacer()
                }
                .padding(AppSpacing.xs)
            }
            
            // Details Area
            VStack(alignment: .leading, spacing: 4) {
                if let brand = product.brand {
                    Text(brand.uppercased())
                        .font(AppTypography.caption2)
                        .foregroundStyle(AppColors.secondaryGray)
                        .tracking(1)
                }
                
                Text(product.name)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(minHeight: 38, alignment: .topLeading)
                
                HStack {
                    Text(CurrencyFormatter.format(product.price))
                        .font(AppTypography.priceSmall)
                        .foregroundStyle(AppColors.primaryDark)
                    
                    Spacer()
                    
                    // Interactive dynamic pill add button
                    Button {
                        toggleProduct(product)
                    } label: {
                        Text(isAdded ? "Added" : "+ Add")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(isAdded ? .white : AppColors.primaryText)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(isAdded ? AnyShapeStyle(AppColors.accentRed) : AnyShapeStyle(AppColors.backgroundGray.opacity(0.6)))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(isAdded ? Color.clear : Color.black.opacity(0.08), lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 4)
            }
            .padding(AppSpacing.sm)
        }
        .background(AppColors.surface)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
        .softShadow()
    }
    
    private var bottomCTABar: some View {
        Button {
            handleFinish()
        } label: {
            if isFinishing {
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(AppColors.accentRed)
                    .clipShape(Capsule())
            } else {
                Text("Finish Registry")
                    .font(AppTypography.buttonLarge)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(AppColors.accentRed)
                    .clipShape(Capsule())
                    .shadow(color: AppColors.accentRed.opacity(0.35), radius: 14, y: 5)
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .disabled(isFinishing)
    }
    
    // MARK: - Actions
    
    private func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. Fetch catalog products
            let fetchedProducts = try await ProductService.shared.fetchAllProducts()
            self.products = fetchedProducts
            
            // Fetch recommendations asynchronously so it doesn't block UI
            Task {
                let occasion = mood != nil ? "\(event.title) with a \(mood!) vibe" : event.title
                do {
                    let recs = try await AIService.shared.getRecommendations(occasion: occasion)
                    await MainActor.run {
                        self.recommendations = recs
                    }
                } catch {
                    print("⚠️ Failed to load AI recommendations: \(error)")
                }
            }
            
            if !isNewEvent {
                // 2. Fetch existing registry items for event to match states
                let existingItems = try await EventService.shared.fetchRegistryItems(eventID: event.id)
                self.registryItems = existingItems
                let existingProductIds = existingItems.compactMap { $0.productId }
                self.addedProductIds = Set(existingProductIds)
            } else {
                self.registryItems = []
                self.addedProductIds = []
            }
        } catch {
            print("❌ Failed to load registry setup data: \(error)")
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func toggleProduct(_ product: Product) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        let isAdded = addedProductIds.contains(product.id)
        
        if !isNewEvent {
            if isAdded {
                if let existingItem = registryItems.first(where: { $0.productId == product.id }) {
                    let purchased = existingItem.quantityPurchased ?? 0
                    let funded = existingItem.fundedAmount ?? 0.0
                    if purchased > 0 || funded > 0.0 {
                        self.alertTitle = "Cannot Remove Item"
                        self.alertMessage = "This item has already been purchased or has contributions, and cannot be removed."
                        self.showErrorAlert = true
                        return
                    }
                }
            }
        }
        
        // 1. Optimistic Update for instantaneous premium UI feedback
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if isAdded {
                addedProductIds.remove(product.id)
            } else {
                addedProductIds.insert(product.id)
            }
        }
        
        if isNewEvent {
            return
        }
        
        Task {
            do {
                if isAdded {
                    // Remove from registry
                    try await EventService.shared.removeProductFromRegistry(eventId: event.id, productId: product.id)
                } else {
                    // Add to registry
                    try await EventService.shared.addProductToRegistry(eventId: event.id, product: product)
                }
            } catch {
                print("❌ Failed to toggle product in registry: \(error)")
                
                // 2. Revert local state immediately upon database error
                await MainActor.run {
                    withAnimation(.spring()) {
                        if isAdded {
                            addedProductIds.insert(product.id)
                        } else {
                            addedProductIds.remove(product.id)
                        }
                    }
                    
                    // 3. Show native user-friendly popup listing exact database/RLS error
                    self.alertTitle = "Database Error"
                    self.alertMessage = error.localizedDescription
                    self.showErrorAlert = true
                }
            }
        }
    }
    
    private func handleFinish() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        isFinishing = true
        
        Task {
            do {
                if isNewEvent {
                    // 1. Create the event in the database
                    _ = try await EventService.shared.createEvent(event)
                    
                    // 2. Create the collaborators in the database
                    for collaborator in collaborators {
                        if let uId = collaborator.userId {
                            try await EventService.shared.addCollaborator(eventId: event.id, userId: uId)
                        }
                    }
                    
                    // 3. Add all selected products to the registry
                    for productId in addedProductIds {
                        if let product = products.first(where: { $0.id == productId }) {
                            try await EventService.shared.addProductToRegistry(eventId: event.id, product: product)
                        }
                    }
                } else {
                    // Pre-emptively ensure that the registry record is successfully created in Supabase
                    _ = try await EventService.shared.getOrCreateRegistryID(for: event.id)
                }
                
                await MainActor.run {
                    isFinishing = false
                    onFinish()
                }
            } catch {
                print("⚠️ Finished setup/registry failed: \(error)")
                await MainActor.run {
                    isFinishing = false
                    self.alertTitle = "Error Creating Event"
                    self.alertMessage = error.localizedDescription
                    self.showErrorAlert = true
                }
            }
        }
    }
    
    private func handleSkip() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        isFinishing = true
        
        Task {
            do {
                // 1. Create the event in the database
                _ = try await EventService.shared.createEvent(event)
                
                // 2. Create the collaborators in the database
                for collaborator in collaborators {
                    if let uId = collaborator.userId {
                        try await EventService.shared.addCollaborator(eventId: event.id, userId: uId)
                    }
                }
                
                await MainActor.run {
                    isFinishing = false
                    onFinish()
                }
            } catch {
                print("⚠️ Skipping registry setup failed: \(error)")
                await MainActor.run {
                    isFinishing = false
                    self.alertTitle = "Error Creating Event"
                    self.alertMessage = error.localizedDescription
                    self.showErrorAlert = true
                }
            }
        }
    }
}
