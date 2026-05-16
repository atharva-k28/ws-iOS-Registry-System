//
//  FriendRegistryDetailView.swift
//  iOS_Registry_System
//
//  Registry detail screen — opened from Friends' Registries tab
//

import SwiftUI

// MARK: - Friend Registry Detail View

struct FriendRegistryDetailView: View {

    let event: Event
    @State private var viewModel: FriendRegistryDetailViewModel
    @Environment(\.dismiss) private var dismiss

    init(event: Event) {
        self.event = event
        self._viewModel = State(initialValue: FriendRegistryDetailViewModel(event: event))
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {

                // MARK: Hero Header

                heroHeader

                // MARK: Stats Row

                statsRow
                    .padding(.horizontal, AppSpacing.screenHorizontal)

                // MARK: Category Filters

                if !viewModel.categories.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppSpacing.xs) {
                            StatusChip(
                                title: "All",
                                isSelected: viewModel.selectedCategory == nil
                            ) {
                                viewModel.selectedCategory = nil
                            }

                            ForEach(viewModel.categories, id: \.self) { category in
                                StatusChip(
                                    title: category,
                                    isSelected: viewModel.selectedCategory == category
                                ) {
                                    viewModel.selectedCategory = category
                                }
                            }
                        }
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                    }
                }

                // MARK: Registry Items

                if viewModel.isLoading {
                    VStack(spacing: AppSpacing.md) {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(AppColors.primaryDark)
                        Text("Loading registry…")
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.secondaryGray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, AppSpacing.xxxl)
                } else if viewModel.filteredItems.isEmpty {
                    emptyState
                } else {
                    if viewModel.selectedCategory == nil {
                        // ALL VIEW - Two sections
                        VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                            
                            // COMPLETE THE SET
                            if !viewModel.completeTheSetItems.isEmpty {
                                VStack(alignment: .leading, spacing: AppSpacing.sectionHeaderGap) {
                                    sectionTitle("COMPLETE THE SET", icon: "square.grid.2x2")
                                    registryGrid(for: viewModel.completeTheSetItems)
                                }
                                .padding(.horizontal, AppSpacing.screenHorizontal)
                            }
                            
                            // OTHER ITEMS
                            if !viewModel.otherItems.isEmpty {
                                VStack(alignment: .leading, spacing: AppSpacing.sectionHeaderGap) {
                                    sectionTitle("OTHER ITEMS", icon: "gift")
                                    registryGrid(for: viewModel.otherItems)
                                }
                                .padding(.horizontal, AppSpacing.screenHorizontal)
                            }
                        }
                    } else {
                        // CATEGORY VIEW - Single filtered grid
                        VStack(alignment: .leading, spacing: AppSpacing.sectionHeaderGap) {
                            sectionTitle(viewModel.selectedCategory?.uppercased() ?? "", icon: "tag")
                            registryGrid(for: viewModel.filteredItems)
                        }
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                    }
                }

                // Bottom spacer for tab bar
                Color.clear.frame(height: AppSpacing.tabBarHeight + AppSpacing.xxl)
            }
        }
        .appBackground()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                GlassButton(icon: "chevron.left") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                GlassButton(icon: "cart") {
                    viewModel.showCart = true
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            await viewModel.loadRegistryData()
        }
        .sheet(item: $viewModel.selectedItem) { item in
            if let product = viewModel.product(for: item) {
                RegistryItemDetailView(item: item, product: product, eventName: viewModel.event.title)
            }
        }
        .navigationDestination(isPresented: $viewModel.showCart) {
            CartView()
        }
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            // Cover image
            AsyncImage(url: URL(string: coverImageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                AppColors.primaryDark
            }
            .frame(height: 260)
            .clipped()

            // Gradient overlay
            LinearGradient(
                colors: [.black.opacity(0.75), .clear],
                startPoint: .bottom,
                endPoint: .top
            )

            // Text content
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                // Event type + date
                Text("\(eventTypeDisplay) · \(eventDateDisplay)")
                    .font(AppTypography.caption1Medium)
                    .tracking(1.5)
                    .foregroundStyle(.white.opacity(0.85))

                // Event title
                Text(event.title)
                    .font(AppTypography.premiumTitle)
                    .foregroundStyle(.white)

                // Days until
                if let eventDate = event.eventDate {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "clock")
                            .font(.system(size: 11))
                        Text(eventDate.daysUntil)
                            .font(AppTypography.caption1Medium)
                    }
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xxs)
                    .background(.ultraThinMaterial.opacity(0.6))
                    .clipShape(Capsule())
                }
            }
            .padding(AppSpacing.lg)
        }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: AppSpacing.sm) {
            statCard(
                value: "\(viewModel.claimedItems)/\(viewModel.totalItems)",
                label: "Claimed",
                icon: "gift.fill"
            )
            statCard(
                value: CurrencyFormatter.formatCompact(viewModel.totalContributed),
                label: "Raised",
                icon: "wallet.pass"
            )
            statCard(
                value: PercentageFormatter.format(viewModel.overallProgress),
                label: "Funded",
                icon: "chart.bar.fill"
            )
        }
    }

    // MARK: - Section Components

    private func sectionTitle(_ title: String, icon: String) -> some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AppColors.secondaryGray)

            Text(title)
                .font(AppTypography.caption1Medium)
                .tracking(1.5)
                .foregroundStyle(AppColors.primaryText)

            Spacer()
        }
    }

    private func registryGrid(for items: [RegistryItem]) -> some View {
        HStack(alignment: .top, spacing: 8) {
            // Left Column
            VStack(spacing: 8) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    if index % 2 == 0 {
                        if let product = viewModel.product(for: item) {
                            registryCard(item: item, product: product)
                        }
                    }
                }
            }
            
            // Right Column
            VStack(spacing: 8) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    if index % 2 != 0 {
                        if let product = viewModel.product(for: item) {
                            registryCard(item: item, product: product)
                        }
                    }
                }
            }
        }
    }

    private func registryCard(item: RegistryItem, product: Product) -> some View {
        RegistryItemCard(
            product: product,
            registryItem: item,
            isGroupGifting: viewModel.isGroupGifting(for: item),
            onPurchase: {
                CartService.shared.addToCart(
                    product: product,
                    registryItem: item,
                    eventName: viewModel.event.title
                )
            },
            onContribute: {
                // Contribute action
            },
            onShare: {
                // Share action
            },
            onEnableGroupGifting: {
                viewModel.enableGroupGifting(for: item)
            },
            onTap: {
                viewModel.selectedItem = item
            }
        )
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(AppColors.secondaryGray.opacity(0.5))

            Text("No items in this category")
                .font(AppTypography.subheadline)
                .foregroundStyle(AppColors.secondaryGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppSpacing.xxxl)
    }

    // MARK: - Stat Card

    private func statCard(value: String, label: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppColors.secondaryGray)
                .padding(.bottom, AppSpacing.xs)

            Text(value)
                .font(AppTypography.title2)
                .foregroundStyle(AppColors.primaryText)

            Text(label)
                .font(AppTypography.caption1)
                .foregroundStyle(AppColors.secondaryGray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.md)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
        .softShadow()
    }

    // MARK: - Helpers

    private var eventTypeDisplay: String {
        event.eventType
            .replacingOccurrences(of: "_", with: " ")
            .uppercased()
    }

    private var eventDateDisplay: String {
        (event.eventDate ?? Date()).formattedLong.uppercased()
    }

    private var coverImageURL: String {
        let title = event.title
        if title.contains("Emma") { return "https://images.unsplash.com/photo-1555244162-803834f70033?w=800" }
        if title.contains("Maya") { return "https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=800" }
        if title.contains("Liam") { return "https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=800" }
        return "https://images.unsplash.com/photo-1556911220-e15024029581?w=800"
    }
}

// MARK: - Preview

#Preview("Friend Registry Detail") {
    NavigationStack {
        FriendRegistryDetailView(event: .mock)
    }
}
