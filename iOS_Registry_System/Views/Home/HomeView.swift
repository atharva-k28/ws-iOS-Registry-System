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
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // MARK: Header

                    headerSection

                    emptyTapShield(height: AppSpacing.sectionGap)

                    // MARK: Featured Events

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

                    // MARK: Curated Hero
                    QuietlyCuratedCard(
                        title: "A few essentials to\ncomplete your kitchen",
                        description: "",
                        actionTitle: ""
                    )
                    .contentShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl, style: .continuous))
                    .onTapGesture {
                        activeModal = .packagingReveal
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)

                    emptyTapShield(height: AppSpacing.sectionGap)
                    
                    // MARK: Collections List
                    VStack(spacing: 0) {
                        CollectionCard(
                            title: "Mix bright, bar-worthy cocktails",
                            category: "Margarita Season",
                            actionText: "Shop Bar",
                            imageSeed: "margarita",
                            onTap: {
                                activeModal = .product(Product(
                                    id: UUID(),
                                    name: "Mix bright, bar-worthy cocktails",
                                    description: "Everything you need to craft the perfect margarita at home.",
                                    brand: "Williams Sonoma",
                                    category: "Margarita Season",
                                    price: 150.0,
                                    imageUrl: CollectionCard.imageUrl(for: "margarita")
                                ))
                            }
                        )

                        emptyTapShield(height: AppSpacing.lg)

                        CollectionCard(
                            title: "Cook al fresco all summer",
                            category: "The Outdoor Kitchen",
                            actionText: "Shop Outdoor",
                            imageSeed: "grill",
                            onTap: {
                                activeModal = .product(Product(
                                    id: UUID(),
                                    name: "Cook al fresco all summer",
                                    description: "Premium outdoor grilling equipment for the perfect summer barbecue.",
                                    brand: "Williams Sonoma",
                                    category: "The Outdoor Kitchen",
                                    price: 850.0,
                                    imageUrl: CollectionCard.imageUrl(for: "grill")
                                ))
                            }
                        )

                        emptyTapShield(height: AppSpacing.lg)

                        CollectionCard(
                            title: "Heritage cast iron & stainless",
                            category: "Made in Cookware®",
                            actionText: "Shop Made In",
                            imageSeed: "pans",
                            onTap: {
                                activeModal = .product(Product(
                                    id: UUID(),
                                    name: "Heritage cast iron & stainless",
                                    description: "Heirloom-quality skillets, pre-seasoned and ready for everyday luxury. Tri-ply construction, lifetime guarantee.",
                                    brand: "Williams Sonoma",
                                    category: "Made in Cookware®",
                                    price: 320.0,
                                    imageUrl: CollectionCard.imageUrl(for: "pans")
                                ))
                            }
                        )

                        emptyTapShield(height: AppSpacing.lg)

                        CollectionCard(
                            title: "Chef-prepared gourmet meals",
                            category: "Ready To Serve",
                            actionText: "Shop Gourmet",
                            imageSeed: "food",
                            onTap: {
                                activeModal = .product(Product(
                                    id: UUID(),
                                    name: "Chef-prepared gourmet meals",
                                    description: "Ready-to-serve gourmet meals crafted by world-renowned chefs.",
                                    brand: "Williams Sonoma",
                                    category: "Ready To Serve",
                                    price: 120.0,
                                    imageUrl: CollectionCard.imageUrl(for: "food")
                                ))
                            }
                        )
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)

                    emptyTapShield(height: AppSpacing.sectionGap)
                    
                    // MARK: More to explore
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("More to explore")
                            .font(AppTypography.title3)
                            .foregroundStyle(AppColors.primaryText)
                            .padding(.horizontal, AppSpacing.screenHorizontal)
                            
                        HStack(spacing: 0) {
                            SmallCollectionCard(title: "Coffee HQ", imageSeed: "coffee", onTap: {
                                activeModal = .product(Product(
                                    id: UUID(),
                                    name: "Coffee HQ",
                                    description: "The finest espresso machines and accessories.",
                                    brand: "Williams Sonoma",
                                    category: "Morning Routine",
                                    price: 450.0,
                                    imageUrl: SmallCollectionCard.imageUrl(for: "coffee")
                                ))
                            })

                            emptyTapShield(width: AppSpacing.sm)

                            SmallCollectionCard(title: "Red White & Blue", imageSeed: "blue", onTap: {
                                activeModal = .product(Product(
                                    id: UUID(),
                                    name: "Red White & Blue",
                                    description: "Patriotic tableware for your next holiday gathering.",
                                    brand: "Williams Sonoma",
                                    category: "Holiday Collection",
                                    price: 85.0,
                                    imageUrl: SmallCollectionCard.imageUrl(for: "blue")
                                ))
                            })
                        }
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                    }

                    emptyTapShield(height: AppSpacing.sectionGap)
                    
                    // MARK: Registry Progress
                    RegistryProgressCard(
                        eventTitle: "Olivia & James",
                        progress: 0.68,
                        itemsClaimed: 42,
                        totalItems: 62,
                        contributors: 24
                    )
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.sm)

                    // Bottom spacer for tab bar
                    Color.clear.frame(height: AppSpacing.tabBarHeight + AppSpacing.xxl)
                }
                .padding(.top, AppSpacing.md)
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
                case .packagingReveal:
                    PackagingRevealView()
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
                Button(action: {}) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.primaryDark)
                        .frame(width: 44, height: 44)
                        .background(AppColors.white)
                        .clipShape(Circle())
                        .softShadow()
                }
                
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
            .padding(.horizontal, AppSpacing.screenHorizontal)
            
            // Greeting & Title
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(viewModel.greeting)
                    .font(AppTypography.subheadline)
                    .foregroundStyle(AppColors.secondaryGray)

                Text("Curated for your\nregistry.")
                    .font(AppTypography.largeTitleSerif)
                    .foregroundStyle(AppColors.primaryText)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            
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
            .padding(.horizontal, AppSpacing.screenHorizontal)
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
        .padding(.horizontal, AppSpacing.screenHorizontal)
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
    case packagingReveal

    var id: String {
        switch self {
        case .product(let product):
            return "product-\(product.id.uuidString)"
        case .packagingReveal:
            return "packaging-reveal"
        }
    }
}

// MARK: - Preview

#Preview("Home") {
    HomeView()
}
