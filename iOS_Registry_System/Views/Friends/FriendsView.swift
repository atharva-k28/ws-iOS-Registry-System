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

                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text("Friends")
                            .font(AppTypography.largeTitle)
                            .foregroundStyle(AppColors.primaryText)

                        Text("Celebrate together")
                            .font(AppTypography.subheadline)
                            .foregroundStyle(AppColors.secondaryGray)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)

                    // MARK: Search Bar

                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16))
                            .foregroundStyle(AppColors.secondaryGray)

                        TextField("Search friends & events...", text: $viewModel.searchText)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.primaryText)
                    }
                    .padding(AppSpacing.sm)
                    .background(AppColors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm, style: .continuous))
                    .softShadow()
                    .padding(.horizontal, AppSpacing.screenHorizontal)

                    // MARK: Active Events Section

                    VStack(alignment: .leading, spacing: AppSpacing.sectionHeaderGap) {
                        Text("Active Registries")
                            .font(AppTypography.title2)
                            .foregroundStyle(AppColors.primaryText)
                            .padding(.horizontal, AppSpacing.screenHorizontal)

                        LazyVStack(spacing: AppSpacing.cardGap) {
                            ForEach(viewModel.filteredFriendEvents) { event in
                                EventCard(event: event)
                            }
                        }
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                    }

                    // MARK: Invite CTA

                    VStack(spacing: AppSpacing.md) {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 36))
                            .foregroundStyle(AppColors.secondaryGray.opacity(0.5))

                        Text("Invite friends to join your registries")
                            .font(AppTypography.subheadline)
                            .foregroundStyle(AppColors.secondaryGray)
                            .multilineTextAlignment(.center)

                        PrimaryButton(title: "Invite Friends", icon: "square.and.arrow.up", style: .outline, isFullWidth: false) {
                            // TODO: Share sheet
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(AppSpacing.xxl)
                    .cardStyle()
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
