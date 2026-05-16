//
//  FriendsView.swift
//  iOS_Registry_System
//
//  Friends screen — starter layout
//

import SwiftUI

// MARK: - Friends View

struct FriendsView: View {

    @State private var viewModel = FriendsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {

                    // MARK: Header

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Discover")
                            .font(AppTypography.subheadline)
                            .foregroundStyle(AppColors.secondaryGray)

                        Text("Friends' Registries")
                            .font(AppTypography.largeTitleSerif)
                            .foregroundStyle(AppColors.primaryText)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)

                    // MARK: Search Bar & Filters

                    VStack(spacing: AppSpacing.md) {
                        HStack(spacing: AppSpacing.md) {
                            HStack(spacing: AppSpacing.xs) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 16))
                                    .foregroundStyle(AppColors.secondaryGray)

                                TextField("Search friends", text: $viewModel.searchText)
                                    .font(AppTypography.body)
                                    .foregroundStyle(AppColors.primaryText)
                            }
                            .padding(AppSpacing.md)
                            .background(AppColors.white)
                            .clipShape(Capsule())
                            .softShadow()
                            
                            Button(action: {
                                // Filter action
                            }) {
                                Image(systemName: "line.3.horizontal.decrease")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(AppColors.primaryDark)
                                    .clipShape(Circle())
                                    .softShadow()
                            }
                        }
                        .padding(.horizontal, AppSpacing.screenHorizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppSpacing.xs) {
                                StatusChip(title: "All", isSelected: true)
                                StatusChip(title: "Wedding")
                                StatusChip(title: "Baby")
                                StatusChip(title: "Housewarming")
                            }
                            .padding(.horizontal, AppSpacing.screenHorizontal)
                        }
                    }

                    // MARK: Active Events List

                    LazyVStack(spacing: AppSpacing.cardGap) {
                        ForEach(viewModel.filteredFriendEvents) { event in
                            FriendEventCard(event: event) {
                                // View action
                            }
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
                await viewModel.loadFriendEvents()
            }
        }
    }
}

// MARK: - Preview

#Preview("Friends") {
    FriendsView()
}
