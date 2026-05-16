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

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {

                    // MARK: Header

                    headerSection

                    // MARK: Featured Events

                    sectionHeader(title: "Upcoming Events", subtitle: "Registries you're part of")

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppSpacing.cardGap) {
                            ForEach(viewModel.featuredEvents) { event in
                                EventCard(event: event)
                                    .frame(width: 300)
                            }
                        }
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                    }

                    // MARK: Curated Hero
                    QuietlyCuratedCard(
                        title: "A few essentials to\ncomplete your kitchen",
                        description: "",
                        actionTitle: ""
                    )
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    
                    // MARK: Collections List
                    VStack(spacing: AppSpacing.lg) {
                        CollectionCard(
                            title: "Mix bright, bar-worthy cocktails",
                            category: "Margarita Season",
                            actionText: "Shop Bar",
                            imageSeed: "margarita"
                        )
                        CollectionCard(
                            title: "Cook al fresco all summer",
                            category: "The Outdoor Kitchen",
                            actionText: "Shop Outdoor",
                            imageSeed: "grill"
                        )
                        CollectionCard(
                            title: "Heritage cast iron & stainless",
                            category: "Made in Cookware®",
                            actionText: "Shop Made In",
                            imageSeed: "pans"
                        )
                        CollectionCard(
                            title: "Chef-prepared gourmet meals",
                            category: "Ready To Serve",
                            actionText: "Shop Gourmet",
                            imageSeed: "food"
                        )
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    
                    // MARK: More to explore
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text("More to explore")
                            .font(AppTypography.title3)
                            .foregroundStyle(AppColors.primaryText)
                            .padding(.horizontal, AppSpacing.screenHorizontal)
                            
                        HStack(spacing: AppSpacing.sm) {
                            SmallCollectionCard(title: "Coffee HQ", imageSeed: "coffee")
                            SmallCollectionCard(title: "Red White & Blue", imageSeed: "blue")
                        }
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                    }
                    
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
}

// MARK: - Preview

#Preview("Home") {
    HomeView()
}
