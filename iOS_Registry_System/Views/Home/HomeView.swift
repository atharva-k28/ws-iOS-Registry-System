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

                    // MARK: AI Picks

                    sectionHeader(title: "AI Gift Picks", subtitle: "Curated just for you", showBadge: true)

                    LazyVGrid(
                        columns: [.init(.flexible()), .init(.flexible())],
                        spacing: AppSpacing.cardGap
                    ) {
                        ForEach(viewModel.recommendedProducts) { product in
                            ProductCard(product: product)
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)

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
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text(viewModel.greeting)
                .font(AppTypography.subheadline)
                .foregroundStyle(AppColors.secondaryGray)

            Text("Registry Together")
                .font(AppTypography.largeTitle)
                .foregroundStyle(AppColors.primaryText)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
    }

    // MARK: - Section Header

    private func sectionHeader(title: String, subtitle: String? = nil, showBadge: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
            HStack(spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppTypography.title2)
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
