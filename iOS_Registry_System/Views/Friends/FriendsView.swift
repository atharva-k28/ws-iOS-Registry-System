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
    @State private var selectedEvent: Event?
    @State private var showDeclineAlert = false
    @State private var eventToDecline: Event?

    var body: some View {
        Group {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {

                    // MARK: Header Section
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Discover")
                            .font(AppTypography.subheadline)
                            .foregroundStyle(AppColors.secondaryGray)

                        Text("Friends' Registries")
                            .font(AppTypography.largeTitleSerif)
                            .foregroundStyle(AppColors.primaryText)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, 8)

                    // MARK: Search Bar & Filters

                    VStack(spacing: AppSpacing.md) {
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
                        .padding(.horizontal, AppSpacing.screenHorizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppSpacing.xs) {
                                ForEach(FriendsViewModel.FriendCategory.allCases) { category in
                                    StatusChip(
                                        title: category.rawValue,
                                        isSelected: viewModel.selectedCategory == category
                                    ) {
                                        viewModel.selectedCategory = category
                                    }
                                }
                            }
                            .padding(.horizontal, AppSpacing.screenHorizontal)
                        }
                    }

                    // MARK: Pending Invites

                    if !viewModel.pendingInvites.isEmpty {
                        VStack(alignment: .leading, spacing: AppSpacing.sectionHeaderGap) {
                            HStack(spacing: 6) {
                                Image(systemName: "envelope.badge")
                                    .font(.system(size: 14))
                                    .foregroundStyle(AppColors.accentRed)
                                Text("PENDING INVITES")
                                    .font(AppTypography.caption1Medium)
                                    .tracking(1.5)
                                    .foregroundStyle(AppColors.accentRed)

                                Spacer()

                                Text("\(viewModel.pendingInvites.count)")
                                    .font(AppTypography.footnoteSemibold)
                                    .foregroundStyle(.white)
                                    .frame(width: 24, height: 24)
                                    .background(AppColors.accentRed)
                                    .clipShape(Circle())
                            }
                            .padding(.horizontal, AppSpacing.screenHorizontal)

                            LazyVStack(spacing: AppSpacing.cardGap) {
                                ForEach(viewModel.pendingInvites) { event in
                                    InviteCard(
                                        event: event,
                                        onAccept: {
                                            Task {
                                                await viewModel.acceptInvite(event: event)
                                            }
                                        },
                                        onDecline: {
                                            eventToDecline = event
                                            showDeclineAlert = true
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, AppSpacing.screenHorizontal)
                        }
                    }

                    // MARK: Active Events List

                    if viewModel.filteredFriendEvents.isEmpty {
                        if !viewModel.isLoading && viewModel.pendingInvites.isEmpty {
                            EmptyStateView(
                                systemImageName: "person.2",
                                title: "No Registries Yet",
                                description: "You are not collaborating on any friends' registries. Search or invite friends to get started!",
                                actionTitle: nil,
                                action: nil
                            )
                            .padding(.horizontal, AppSpacing.screenHorizontal)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: AppSpacing.sectionHeaderGap) {
                            Text("FRIENDS' REGISTRIES")
                                .font(AppTypography.caption1Medium)
                                .tracking(1.5)
                                .foregroundStyle(AppColors.primaryText)
                                .padding(.horizontal, AppSpacing.screenHorizontal)

                            LazyVStack(spacing: AppSpacing.cardGap) {
                                ForEach(viewModel.filteredFriendEvents) { event in
                                    FriendEventCard(
                                        event: event,
                                        progress: viewModel.eventProgresses[event.id] ?? 0.0
                                    ) {
                                        selectedEvent = event
                                    }
                                }
                            }
                            .padding(.horizontal, AppSpacing.screenHorizontal)
                        }
                    }

                    // Bottom spacer for tab bar
                    Color.clear.frame(height: AppSpacing.tabBarHeight + AppSpacing.xxl)
                }
                .padding(.top, AppSpacing.md)
            }
            .appBackground()
            .transparentNavigationBar()
            .navigationDestination(item: $selectedEvent) { event in
                FriendRegistryDetailView(event: event)
            }
            .task {
                await viewModel.loadFriendEvents()
            }
            .alert("Decline Invite?", isPresented: $showDeclineAlert) {
                Button("Cancel", role: .cancel) {
                    eventToDecline = nil
                }
                Button("Decline", role: .destructive) {
                    if let event = eventToDecline {
                        Task {
                            await viewModel.declineInvite(event: event)
                        }
                    }
                    eventToDecline = nil
                }
            } message: {
                Text("Are you sure you want to decline this registry invite? This action cannot be undone.")
            }
        }
    }
}

// MARK: - Preview

#Preview("Friends") {
    FriendsView()
}
