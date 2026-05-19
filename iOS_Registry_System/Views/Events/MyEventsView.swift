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
    @State private var selectedEvent: Event? = nil

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

                    // MARK: Pending Collaborator Invites
                    if !viewModel.pendingCollaboratorInvites.isEmpty {
                        VStack(alignment: .leading, spacing: AppSpacing.sectionHeaderGap) {
                            Text("CO-HOST INVITATIONS")
                                .font(AppTypography.caption1Medium)
                                .tracking(1.5)
                                .foregroundColor(AppColors.primaryText)
                                .padding(.horizontal, AppSpacing.screenHorizontal)

                            ForEach(viewModel.pendingCollaboratorInvites) { event in
                                InviteCard(
                                    event: event,
                                    onAccept: {
                                        Task {
                                            await viewModel.acceptCollaboratorInvite(event)
                                            selectedEvent = event
                                        }
                                    },
                                    onDecline: {
                                        Task {
                                            await viewModel.declineCollaboratorInvite(event)
                                        }
                                    }
                                )
                                .padding(.horizontal, AppSpacing.screenHorizontal)
                            }
                        }
                    }

                    // MARK: Event Switcher Slider
                    if viewModel.filteredEvents.count > 1 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppSpacing.xs) {
                                ForEach(viewModel.filteredEvents) { event in
                                    let isSelected = (selectedEvent?.id ?? viewModel.filteredEvents.first?.id) == event.id
                                    Button {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                            selectedEvent = event
                                        }
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                                .font(.system(size: 12))
                                                .foregroundStyle(isSelected ? .white : AppColors.secondaryGray)
                                            
                                            Text(event.title)
                                                .font(AppTypography.caption1Medium)
                                                .foregroundStyle(isSelected ? .white : AppColors.primaryText)
                                        }
                                        .padding(.horizontal, AppSpacing.md)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(isSelected ? AppColors.accentRed : AppColors.white)
                                        )
                                        .softShadow()
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, AppSpacing.screenHorizontal)
                        }
                    }

                    // MARK: Primary Event Card

                    if let activeEvent = selectedEvent ?? viewModel.filteredEvents.first {
                        EventCard(
                            event: activeEvent,
                            onTap: { showCommandCenter = true },
                            onManageRegistry: { showCommandCenter = true },
                            onInvite: { showInviteSheet = true }
                        )
                        .padding(.horizontal, AppSpacing.screenHorizontal)

                        // MARK: Event Stats
                        HStack(spacing: AppSpacing.sm) {
                            let stats = viewModel.eventStats[activeEvent.id] ?? EventsViewModel.EventDashboardStats()
                            statCard(value: "\(stats.completePercentage)%", label: "Complete", icon: "arrow.up.right")
                            statCard(value: "$\(Int(stats.raisedAmount))", label: "Raised", icon: "wallet.pass")
                            statCard(value: "\(stats.guestsCount)", label: "Guests", icon: "person.2")
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
                                let recent = viewModel.eventStats[activeEvent.id]?.recentActivity ?? []
                                if recent.isEmpty {
                                    Text("No activity yet.")
                                        .font(AppTypography.bodyMedium)
                                        .foregroundStyle(AppColors.secondaryGray)
                                        .padding(.vertical, AppSpacing.sm)
                                } else {
                                    ForEach(recent.prefix(3)) { contributor in
                                        recentActivityRow(contributor: contributor)
                                    }
                                }
                            }
                            .padding(.horizontal, AppSpacing.screenHorizontal)
                        }
                    } else if !viewModel.isLoading {
                        EmptyStateView(
                            systemImageName: "calendar.badge.plus",
                            title: "No Events Yet",
                            description: "You haven't created any events. Start hosting your first registry today!",
                            actionTitle: "Create Event",
                            action: { showCreateEvent = true }
                        )
                        .padding(.horizontal, AppSpacing.screenHorizontal)
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
                if let activeEvent = selectedEvent ?? viewModel.filteredEvents.first {
                    EventCommandCenterView(event: activeEvent)
                }
            }
            .navigationDestination(isPresented: $showCreateEvent) {
                CreateEventView()
            }
            .sheet(isPresented: $showInviteSheet) {
                let event = selectedEvent ?? viewModel.filteredEvents.first
                InviteCollaboratorsSheet(eventId: event?.id, giftTitle: event?.title ?? "Event")
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(32)
            }
            .task {
                await viewModel.loadEvents()
                if selectedEvent == nil || !viewModel.filteredEvents.contains(where: { $0.id == selectedEvent?.id }) {
                    selectedEvent = viewModel.filteredEvents.first
                }
                if let active = selectedEvent {
                    await viewModel.loadStats(for: active)
                }
            }
            .onChange(of: selectedEvent) { oldValue, newValue in
                if let newEvent = newValue {
                    Task { await viewModel.loadStats(for: newEvent) }
                }
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
                    .overlay(Text(contributor.name.prefix(1)).font(AppTypography.caption1Medium))
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("\(contributor.name)")
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)
                if let itemName = contributor.itemName {
                    Text("contributed to \(itemName)")
                        .font(AppTypography.caption1)
                        .foregroundStyle(AppColors.secondaryGray)
                        .lineLimit(1)
                } else {
                    Text("contributed")
                        .font(AppTypography.caption1)
                        .foregroundStyle(AppColors.secondaryGray)
                        .lineLimit(1)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("+$\(Int(contributor.amount))")
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.accentRed)
                Text(contributor.timeAgo)
                    .font(AppTypography.caption2)
                    .foregroundStyle(AppColors.secondaryGray)
            }
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
