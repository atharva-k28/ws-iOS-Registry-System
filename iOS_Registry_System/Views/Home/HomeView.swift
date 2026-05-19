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

    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {

                        // MARK: Header

                        headerSection

                        emptyTapShield(height: AppSpacing.sectionGap)

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
                                    HStack(spacing: AppSpacing.md) {
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
            .task {
                await viewModel.loadHomeData()
            }
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
                
                Button(action: {}) {
                    Image(systemName: "bell")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.primaryDark)
                        .frame(width: 44, height: 44)
                        .background(AppColors.white)
                        .clipShape(Circle())
                        .softShadow()
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

                TextField("Search products...", text: .constant(""))
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.primaryText)
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
