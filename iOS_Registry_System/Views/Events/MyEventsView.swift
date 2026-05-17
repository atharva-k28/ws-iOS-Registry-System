//
//  MyEventsView.swift
//  iOS_Registry_System
//
//  My Events screen — lightweight event dashboard.
//  Preserves the original visual identity while adding
//  proper navigation to Command Center, Create Event, and AI flows.
//

import SwiftUI

// MARK: - My Events View

struct MyEventsView: View {

    @State private var viewModel = EventsViewModel()

    // Navigation state
    @State private var showAIRecommendations = false
    @State private var showCommandCenter     = false
    @State private var showCreateEvent       = false
    @State private var showInviteSheet       = false

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {

                    // MARK: Header

                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hosting")
                                .font(AppTypography.subheadline)
                                .foregroundStyle(AppColors.secondaryGray)

                            Text("My Events")
                                .font(AppTypography.largeTitleSerif)
                                .foregroundStyle(AppColors.primaryText)
                        }

                        Spacer()

                        Button {
                            showCreateEvent = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(AppColors.accentRed)
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
                                        )
                                )
                                .softShadow()
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)

                    // MARK: Primary Event Card

                    if let primaryEvent = viewModel.filteredEvents.first {
                        EventCard(
                            event: primaryEvent,
                            onTap: { showCommandCenter = true },
                            onManageRegistry: { showCommandCenter = true },
                            onInvite: { showInviteSheet = true }
                        )
                        .padding(.horizontal, AppSpacing.screenHorizontal)

                        // MARK: Event Stats
                        HStack(spacing: AppSpacing.sm) {
                            statCard(value: "68%", label: "Complete", icon: "arrow.up.right")
                            statCard(value: "$4.2k", label: "Raised", icon: "wallet.pass")
                            statCard(value: "24", label: "Guests", icon: "person.2")
                        }
                        .padding(.horizontal, AppSpacing.screenHorizontal)

                        // MARK: Quiet Suggestions
                        SuggestionCard(
                            title: "A few quiet suggestions",
                            subtitle: "5 thoughtful additions for your registry",
                            onTap: { showAIRecommendations = true }
                        )
                        .padding(.horizontal, AppSpacing.screenHorizontal)

                        // MARK: Recent Registry Activity
                        VStack(alignment: .leading, spacing: AppSpacing.sectionHeaderGap) {
                            Text("RECENT ACTIVITY")
                                .font(AppTypography.caption1Medium)
                                .tracking(1.5)
                                .foregroundColor(AppColors.primaryText)
                                .padding(.horizontal, AppSpacing.screenHorizontal)

                            VStack(spacing: AppSpacing.sm) {
                                ForEach(PriorityGiftItem.mockContributors.prefix(3)) { contributor in
                                    recentActivityRow(contributor: contributor)
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
            .navigationDestination(isPresented: $showAIRecommendations) {
                AIRecommendationsView()
            }
            .navigationDestination(isPresented: $showCommandCenter) {
                if let primaryEvent = viewModel.filteredEvents.first {
                    EventCommandCenterView(event: primaryEvent)
                }
            }
            .navigationDestination(isPresented: $showCreateEvent) {
                CreateEventView()
            }
            .sheet(isPresented: $showInviteSheet) {
                InviteCollaboratorsSheet(giftTitle: viewModel.filteredEvents.first?.title ?? "Event")
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(32)
            }
            .task {
                await viewModel.loadEvents()
            }
        }
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

    // MARK: - Recent Activity Row

    private func recentActivityRow(contributor: Contributor) -> some View {
        HStack(spacing: AppSpacing.sm) {
            AsyncImage(url: URL(string: contributor.avatarURL ?? "")) { img in
                img.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle().fill(AppColors.backgroundGray)
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("\(contributor.name) contributed")
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)
                Text(contributor.timeAgo)
                    .font(AppTypography.caption1)
                    .foregroundStyle(AppColors.secondaryGray)
            }
            Spacer()
            Text("+$\(Int(contributor.amount))")
                .font(AppTypography.bodyMedium)
                .foregroundStyle(AppColors.accentRed)
        }
        .padding(AppSpacing.sm)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
        .softShadow()
    }
}

// MARK: - Preview

#Preview("My Events") {
    MyEventsView()
}
