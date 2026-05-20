//
//  HomeView.swift
//  iOS_Registry_System
//
//  Home screen — starter layout
//

import SwiftUI

// MARK: - Home View

struct HomeView: View {

    @State private var viewModel = HomeViewModel()
    @State private var activeModal: HomeModal?
    @State private var showNotifications = false
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        GeometryReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {

                        // MARK: Header

                        headerSection

                        emptyTapShield(height: AppSpacing.sectionGap)

                        if isSearchActive {
                            searchResultsSection
                        } else {
                        // MARK: Featured Events
                        if !viewModel.featuredEvents.isEmpty {
                            sectionHeader(title: "Upcoming Events", subtitle: "Registries you're part of")

                            emptyTapShield(height: AppSpacing.sectionHeaderGap)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: AppSpacing.cardGap) {
                                    ForEach(viewModel.featuredEvents) { event in
                                        EventCard(event: event)
                                            .frame(width: 300)
                                    }
                                }
                                .padding(.horizontal, AppSpacing.screenHorizontal)
                            }

                            emptyTapShield(height: AppSpacing.sectionGap)
                        }

                        // MARK: Curated Hero
                        if viewModel.shouldShowAICuratedCard {
                            QuietlyCuratedCard(
                                title: viewModel.aiBundleTitle,
                                description: viewModel.aiBundleDescription,
                                actionTitle: ""
                            )
                            .contentShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl, style: .continuous))
                            .onTapGesture {
                                activeModal = .aiBundle(
                                    products: viewModel.aiBundleProducts,
                                    title: viewModel.aiBundleTitle
                                )
                            }
                            .homeContentMargins()

                            emptyTapShield(height: AppSpacing.sectionGap)
                        }

                        // MARK: Collections List
                        if !viewModel.collectionProducts.isEmpty {
                            VStack(spacing: 0) {
                                ForEach(Array(viewModel.collectionProducts.enumerated()), id: \.element.id) { index, product in
                                    CollectionCard(
                                        title: product.name,
                                        category: product.subcategory ?? product.category,
                                        actionText: product.category,
                                        imageUrl: product.imageUrl,
                                        onTap: {
                                            activeModal = .product(product)
                                        }
                                    )

                                    if index < viewModel.collectionProducts.count - 1 {
                                        emptyTapShield(height: AppSpacing.lg)
                                    }
                                }
                            }
                            .homeContentMargins()

                            emptyTapShield(height: AppSpacing.sectionGap)
                        }

                        // MARK: More to explore
                        if !viewModel.moreToExploreProducts.isEmpty {
                            VStack(alignment: .leading, spacing: AppSpacing.md) {
                                Text("More to explore")
                                    .font(AppTypography.title3)
                                    .foregroundStyle(AppColors.primaryText)
                                    .homeContentMargins()

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(alignment: .top, spacing: AppSpacing.md) {
                                        ForEach(viewModel.moreToExploreProducts) { product in
                                            SmallCollectionCard(title: product.name, imageUrl: product.imageUrl, onTap: {
                                                activeModal = .product(product)
                                            })
                                        }
                                    }
                                    .padding(.horizontal, AppSpacing.screenHorizontal)
                                }
                            }

                            emptyTapShield(height: AppSpacing.sectionGap)
                        }

                        // MARK: Registry Progress
                        if let progress = viewModel.registryProgress {
                            RegistryProgressCard(
                                eventTitle: progress.eventTitle,
                                eventType: progress.eventType,
                                progress: progress.progress,
                                itemsClaimed: progress.itemsClaimed,
                                totalItems: progress.totalItems,
                                contributors: progress.contributors
                            )
                            .homeContentMargins()
                            .padding(.top, AppSpacing.sm)
                        }
                        }

                        // Bottom spacer for tab bar
                        Color.clear.frame(height: AppSpacing.tabBarHeight + AppSpacing.xxl)
                    }
                    .frame(width: proxy.size.width, alignment: .leading)
                    .padding(.top, AppSpacing.md)
                }
            }
            .appBackground()
            .transparentNavigationBar()
            .sheet(item: $activeModal) { modal in
                switch modal {
                case .product(let product):
                    ProductDetailView(product: product)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(28)
                case .aiBundle(let products, let title):
                    PackagingRevealView(bundleTitle: title, products: products)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                        .presentationCornerRadius(28)
                }
            }
            .sheet(isPresented: $showNotifications) {
                NotificationsSheet(viewModel: viewModel)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
            }
            .task {
                await viewModel.loadHomeData()
            }
            .onDisappear {
                searchTask?.cancel()
            }
    }

    private var isSearchActive: Bool {
        !viewModel.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            if viewModel.isSearching {
                InlineLoadingView()
                    .homeContentMargins()
            } else if viewModel.searchResults.isEmpty {
                EmptyStateView(
                    systemImageName: "shippingbox",
                    title: "No Products Found",
                    description: "Try another product name, brand, or category."
                )
                .homeContentMargins()
            } else {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("Search Results")
                        .font(AppTypography.title3)
                        .foregroundStyle(AppColors.primaryText)

                    ForEach(viewModel.searchResults) { product in
                        Button {
                            activeModal = .product(product)
                        } label: {
                            searchResultRow(product)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .homeContentMargins()
            }
        }
    }

    private func searchResultRow(_ product: Product) -> some View {
        HStack(spacing: AppSpacing.md) {
            AsyncImage(url: product.imageUrl.flatMap(URL.init(string:))) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                AppColors.backgroundGray
            }
            .frame(width: 72, height: 72)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md, style: .continuous))

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(product.name)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                Text(product.brand ?? product.category)
                    .font(AppTypography.caption1)
                    .foregroundStyle(AppColors.secondaryGray)

                Text(CurrencyFormatter.format(product.price))
                    .font(AppTypography.caption1Medium)
                    .foregroundStyle(AppColors.primaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppColors.secondaryGray)
        }
        .padding(AppSpacing.sm)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md, style: .continuous))
        .softShadow()
    }

    private func scheduleSearch() {
        searchTask?.cancel()

        guard isSearchActive else {
            viewModel.searchResults = []
            return
        }

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }
            await viewModel.searchProducts()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            
            // Top Nav Bar
            HStack {
                Color.clear
                    .frame(width: 44, height: 44)
                
                Spacer()
                
                // Mock Logo
                VStack(spacing: 2) {
                    Text("WILLIAMS")
                    Text("SONOMA")
                }
                .font(AppTypography.footnoteSemibold.weight(.bold))
                .tracking(2)
                .foregroundColor(AppColors.primaryDark)
                
                Spacer()
                
                Button {
                    showNotifications = true
                    Task {
                        await viewModel.loadNotifications()
                        await viewModel.markNotificationsRead()
                    }
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.primaryDark)
                            .frame(width: 44, height: 44)
                            .background(AppColors.white)
                            .clipShape(Circle())
                            .softShadow()

                        if viewModel.unreadNotificationCount > 0 {
                            Circle()
                                .fill(AppColors.accentRed)
                                .frame(width: 10, height: 10)
                                .offset(x: -3, y: 3)
                        }
                    }
                }
            }
            .homeContentMargins()
            
            // Greeting & Title
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(viewModel.greeting)
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppColors.secondaryGray)

                Text("Curated for your\nregistry.")
                    .font(AppTypography.largeTitleSerif)
                    .foregroundStyle(AppColors.primaryText)
            }
            .homeContentMargins()
            
            // Search Bar
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16))
                    .foregroundStyle(AppColors.secondaryGray)

                TextField("Search products...", text: $viewModel.searchQuery)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.primaryText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .submitLabel(.search)
                    .onSubmit {
                        searchTask?.cancel()
                        Task {
                            await viewModel.searchProducts()
                        }
                    }
                    .onChange(of: viewModel.searchQuery) { _, _ in
                        scheduleSearch()
                    }

                if !viewModel.searchQuery.isEmpty {
                    Button {
                        searchTask?.cancel()
                        viewModel.searchQuery = ""
                        viewModel.searchResults = []
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(AppColors.secondaryGray)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppSpacing.md)
            .background(AppColors.white)
            .clipShape(Capsule())
            .softShadow()
            .homeContentMargins()
        }
    }

    // MARK: - Section Header

    private func sectionHeader(title: String, subtitle: String? = nil, showBadge: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
            HStack(spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppTypography.premiumTitle)
                    .foregroundStyle(AppColors.primaryText)

                if showBadge {
                    AIBadge()
                }

                Spacer()

                Button("See All") {
                    // TODO: Navigate to full list
                }
                .font(AppTypography.subheadlineMedium)
                .foregroundStyle(AppColors.accentRed)
            }

            if let subtitle {
                Text(subtitle)
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.secondaryGray)
            }
        }
        .homeContentMargins()
    }

    private func emptyTapShield(height: CGFloat) -> some View {
        Color.white.opacity(0.001)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .contentShape(Rectangle())
            .highPriorityGesture(TapGesture().onEnded {})
            .accessibilityHidden(true)
    }

    private func emptyTapShield(width: CGFloat) -> some View {
        Color.white.opacity(0.001)
            .frame(width: width)
            .contentShape(Rectangle())
            .highPriorityGesture(TapGesture().onEnded {})
            .accessibilityHidden(true)
    }
}

private enum HomeModal: Identifiable {
    case product(Product)
    case aiBundle(products: [Product], title: String)

    var id: String {
        switch self {
        case .product(let product):
            return "product-\(product.id.uuidString)"
        case .aiBundle(let products, _):
            return "ai-bundle-\(products.map(\.id.uuidString).joined(separator: "-"))"
        }
    }
}

private struct NotificationsSheet: View {
    @Bindable var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            topBar
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.sm)
                .background(AppColors.backgroundGray)

            notificationContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(AppColors.backgroundGray.ignoresSafeArea())
    }

    private var notificationContent: some View {
        Group {
            if viewModel.isLoadingNotifications {
                LoadingView(message: "Loading notifications...")
            } else if viewModel.notifications.isEmpty {
                notificationEmptyState
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: AppSpacing.sm) {
                        ForEach(viewModel.notifications) { notification in
                            notificationRow(notification)
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.vertical, AppSpacing.md)
                }
            }
        }
    }

    private var notificationEmptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Spacer(minLength: 0)

            Image(systemName: "bell")
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(AppColors.secondaryGray)
                .frame(width: 84, height: 84)
                .background(AppColors.white)
                .clipShape(Circle())
                .overlay(Circle().stroke(AppColors.backgroundGray, lineWidth: 1))
                .softShadow()

            VStack(spacing: AppSpacing.xs) {
                Text("No Notifications")
                    .font(AppTypography.premiumTitle)
                    .foregroundStyle(AppColors.primaryText)
                    .multilineTextAlignment(.center)

                Text("Registry updates and gift activity will appear here.")
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.backgroundGray)
    }

    private var topBar: some View {
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

            Text("NOTIFICATIONS")
                .font(AppTypography.caption1Medium)
                .tracking(1.5)
                .foregroundColor(AppColors.secondaryGray)

            Spacer()

            Color.clear.frame(width: 44, height: 44)
        }
    }

    private func notificationRow(_ notification: Notification) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Circle()
                .fill(notification.isRead == true ? AppColors.backgroundGray : AppColors.accentRed)
                .frame(width: 10, height: 10)
                .padding(.top, 7)

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(notification.title ?? notification.type?.capitalized ?? "Notification")
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)

                if let body = notification.body, !body.isEmpty {
                    Text(body)
                        .font(AppTypography.subheadline)
                        .foregroundStyle(AppColors.secondaryGray)
                        .lineLimit(3)
                }

                if let createdAt = notification.createdAt {
                    Text(createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(AppTypography.caption1)
                        .foregroundStyle(AppColors.secondaryGray)
                }
            }

            Spacer()
        }
        .padding(AppSpacing.md)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md, style: .continuous))
        .softShadow()
    }
}

// MARK: - Preview

#Preview("Home") {
    HomeView()
}

private extension View {
    func homeContentMargins() -> some View {
        HStack(spacing: 0) {
            self
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
    }
}
