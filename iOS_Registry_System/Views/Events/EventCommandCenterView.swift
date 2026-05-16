//
//  EventCommandCenterView.swift
//  iOS_Registry_System
//
//  Event Command Center — the central operating system for one event.
//  Segmented tabs: Overview · Registry · Guests · Timeline
//

import SwiftUI

// MARK: - Command Center Tab

enum EventCenterTab: String, CaseIterable, Identifiable {
    case overview = "Overview"
    case registry = "Registry"
    case guests   = "Guests"
    case timeline = "Timeline"

    var id: String { rawValue }
}

// MARK: - Event Command Center View

struct EventCommandCenterView: View {

    let event: Event
    @State private var selectedTab: EventCenterTab = .overview
    @State private var showInviteSheet = false
    @State private var showSettings = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Hero header
            heroHeader

            // Segmented tabs
            segmentedNav

            // Tab content
            TabView(selection: $selectedTab) {
                overviewTab.tag(EventCenterTab.overview)
                registryTab.tag(EventCenterTab.registry)
                guestsTab.tag(EventCenterTab.guests)
                timelineTab.tag(EventCenterTab.timeline)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.25), value: selectedTab)
        }
        .appBackground()
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(.ultraThinMaterial))
                }
                .buttonStyle(.plain)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 10) {
                    Button { showInviteSheet = true } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(.ultraThinMaterial))
                    }
                    .buttonStyle(.plain)

                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(.ultraThinMaterial))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .sheet(isPresented: $showInviteSheet) {
            InviteCollaboratorsSheet(giftTitle: event.title)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
        .sheet(isPresented: $showSettings) {
            eventSettingsSheet
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: imageUrl(for: event.eventType))) { img in
                img.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color(hex: "E8E2DC")
            }
            .frame(height: 240)
            .clipped()

            // Gradient overlay
            LinearGradient(
                colors: [.black.opacity(0.7), .black.opacity(0.0)],
                startPoint: .bottom,
                endPoint: .center
            )

            // Event info
            VStack(alignment: .leading, spacing: 6) {
                if let date = event.eventDate {
                    Text(date.daysUntil.uppercased())
                        .font(AppTypography.caption1Medium)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.primaryDark)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(.white))
                }

                Text("\(event.eventType.replacingOccurrences(of: "_", with: " ").uppercased()) · \((event.eventDate ?? Date()).formattedLong.uppercased())")
                    .font(AppTypography.caption2)
                    .tracking(1)
                    .foregroundStyle(.white.opacity(0.8))

                Text(event.title)
                    .font(.system(size: 28, weight: .regular, design: .serif))
                    .foregroundStyle(.white)
                    .lineLimit(2)
            }
            .padding(AppSpacing.lg)
        }
        .frame(height: 240)
    }

    // MARK: - Segmented Navigation

    private var segmentedNav: some View {
        HStack(spacing: 0) {
            ForEach(EventCenterTab.allCases) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 6) {
                        Text(tab.rawValue)
                            .font(AppTypography.footnoteSemibold)
                            .foregroundStyle(selectedTab == tab ? AppColors.primaryText : AppColors.secondaryGray)

                        Rectangle()
                            .fill(selectedTab == tab ? AppColors.accentRed : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.sm)
        .background(AppColors.white)
    }

    // MARK: - Overview Tab

    private var overviewTab: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: AppSpacing.lg) {
                // Registry Progress Card
                registryProgressCard

                // Countdown + Quick Stats
                countdownCard

                // Contribution Milestones
                milestonesStrip

                // Upcoming Tasks
                upcomingTasksSection

                // Recent Activity
                recentActivitySection

                Color.clear.frame(height: AppSpacing.tabBarHeight + AppSpacing.xxl)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.lg)
        }
    }

    private var registryProgressCard: some View {
        HStack(spacing: AppSpacing.lg) {
            // Progress ring
            ZStack {
                Circle()
                    .stroke(AppColors.backgroundGray, lineWidth: 7)
                    .frame(width: 76, height: 76)
                Circle()
                    .trim(from: 0, to: 0.68)
                    .stroke(AppColors.accentRed, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                    .frame(width: 76, height: 76)
                    .rotationEffect(.degrees(-90))
                Text("68%")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.primaryText)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("REGISTRY PROGRESS")
                    .font(AppTypography.caption1Medium)
                    .tracking(1.5)
                    .foregroundStyle(AppColors.secondaryGray)
                Text("$4,820 raised of\n$7,100")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.primaryText)
                Text("24 contributors · 58 gifts")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.secondaryGray)
            }
            Spacer()
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
        .softShadow()
    }

    // MARK: - Countdown Card

    private var countdownCard: some View {
        HStack(spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: 4) {
                Text("COUNTDOWN")
                    .font(AppTypography.caption1Medium)
                    .tracking(1.5)
                    .foregroundStyle(AppColors.secondaryGray)
                Text(event.eventDate?.daysUntil ?? "—")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.primaryText)
                Text("until the celebration")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.secondaryGray)
            }
            Spacer()
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 36))
                .foregroundStyle(AppColors.accentRed.opacity(0.7))
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
        .softShadow()
    }

    // MARK: - Milestones Strip

    private var milestonesStrip: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("MILESTONES")
                .font(AppTypography.caption1Medium)
                .tracking(1.5)
                .foregroundStyle(AppColors.secondaryGray)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    milestoneChip(emoji: "🎉", label: "First gift!", isComplete: true)
                    milestoneChip(emoji: "🔟", label: "10 contributions", isComplete: true)
                    milestoneChip(emoji: "💎", label: "50% funded", isComplete: true)
                    milestoneChip(emoji: "🏆", label: "Fully funded", isComplete: false)
                }
            }
        }
    }

    private func milestoneChip(emoji: String, label: String, isComplete: Bool) -> some View {
        HStack(spacing: 6) {
            Text(emoji)
                .font(.system(size: 16))
            Text(label)
                .font(AppTypography.caption1Medium)
                .foregroundStyle(isComplete ? AppColors.primaryText : AppColors.secondaryGray)
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(isComplete ? Color(hex: "34C759").opacity(0.1) : AppColors.backgroundGray)
        )
        .overlay(
            Capsule()
                .stroke(isComplete ? Color(hex: "34C759").opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }

    // MARK: - Upcoming Tasks

    private var upcomingTasksSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("TO DO")
                .font(AppTypography.caption1Medium)
                .tracking(1.5)
                .foregroundStyle(AppColors.secondaryGray)

            taskRow(icon: "envelope", title: "Send RSVP reminders", subtitle: "3 guests pending", priority: .medium)
            taskRow(icon: "shippingbox", title: "Set shipping address", subtitle: "Required before event", priority: .high)
            taskRow(icon: "heart.text.clipboard", title: "Write thank-you notes", subtitle: "After event day", priority: .low)
        }
    }

    private enum TaskPriority { case high, medium, low }

    private func taskRow(icon: String, title: String, subtitle: String, priority: TaskPriority) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(priority == .high ? AppColors.accentRed : AppColors.secondaryGray)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(priority == .high ? AppColors.accentRed.opacity(0.1) : AppColors.backgroundGray)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)
                Text(subtitle)
                    .font(AppTypography.caption1)
                    .foregroundStyle(AppColors.secondaryGray)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(AppColors.secondaryGray)
        }
        .padding(AppSpacing.sm)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
        .softShadow()
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("RECENT ACTIVITY")
                .font(AppTypography.caption1Medium)
                .tracking(1.5)
                .foregroundStyle(AppColors.secondaryGray)

            ForEach(PriorityGiftItem.mockContributors.prefix(3)) { contributor in
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
    }

    // MARK: - Registry Tab

    private var registryTab: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                // Registry categories
                registryCategoriesSection

                // Priority Gifts
                VStack(alignment: .leading, spacing: AppSpacing.sectionHeaderGap) {
                    HStack {
                        Text("PRIORITY GIFTS")
                            .font(AppTypography.caption1Medium)
                            .tracking(1.5)
                            .foregroundStyle(AppColors.primaryText)
                        Spacer()
                        NavigationLink(destination: PriorityGiftsListView()) {
                            Text("See all")
                                .font(AppTypography.subheadline)
                                .foregroundStyle(AppColors.secondaryGray)
                        }
                    }

                    ForEach(PriorityGiftItem.allMock) { gift in
                        PriorityGiftCard(gift: gift)
                    }
                }

                Color.clear.frame(height: AppSpacing.tabBarHeight + AppSpacing.xxl)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.lg)
        }
    }

    private var registryCategoriesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("REGISTRY CATEGORIES")
                .font(AppTypography.caption1Medium)
                .tracking(1.5)
                .foregroundStyle(AppColors.primaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    categoryCard(title: "Kitchen", subtitle: "12 items", imageUrl: "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&q=80")
                    categoryCard(title: "Dining", subtitle: "8 items", imageUrl: "https://images.unsplash.com/photo-1603199505524-3e4cdaef1f6a?w=300&q=80")
                    categoryCard(title: "Outdoor", subtitle: "5 items", imageUrl: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=300&q=80")
                }
            }
        }
    }

    private func categoryCard(title: String, subtitle: String, imageUrl: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: URL(string: imageUrl)) { img in
                img.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color(hex: "E8E2DC")
            }
            .frame(width: 150, height: 100)
            .clipped()

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)
                Text(subtitle)
                    .font(AppTypography.caption1)
                    .foregroundStyle(AppColors.secondaryGray)
            }
            .padding(.horizontal, AppSpacing.sm)
            .padding(.bottom, AppSpacing.sm)
        }
        .frame(width: 150)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
        .softShadow()
    }

    // MARK: - Guests Tab

    private var guestsTab: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // Stats
                HStack(spacing: AppSpacing.sm) {
                    guestStatCard(value: "24", label: "Invited")
                    guestStatCard(value: "18", label: "Attending")
                    guestStatCard(value: "3", label: "Pending")
                }

                // Guest list
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("GUEST LIST")
                        .font(AppTypography.caption1Medium)
                        .tracking(1.5)
                        .foregroundStyle(AppColors.secondaryGray)

                    ForEach(guestMockData, id: \.name) { guest in
                        HStack(spacing: AppSpacing.md) {
                            AsyncImage(url: URL(string: guest.avatar)) { img in
                                img.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Circle().fill(AppColors.backgroundGray)
                            }
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(guest.name)
                                    .font(AppTypography.bodyMedium)
                                    .foregroundStyle(AppColors.primaryText)
                                Text(guest.role)
                                    .font(AppTypography.caption1)
                                    .foregroundStyle(AppColors.secondaryGray)
                            }
                            Spacer()
                            rsvpBadge(status: guest.status)
                        }
                        .padding(AppSpacing.md)
                        .background(AppColors.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
                        .softShadow()
                    }
                }

                Color.clear.frame(height: AppSpacing.tabBarHeight + AppSpacing.xxl)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.lg)
        }
    }

    private func guestStatCard(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppTypography.title2)
                .foregroundStyle(AppColors.primaryText)
            Text(label)
                .font(AppTypography.caption1)
                .foregroundStyle(AppColors.secondaryGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
        .softShadow()
    }

    private func rsvpBadge(status: String) -> some View {
        Text(status)
            .font(AppTypography.caption1Medium)
            .foregroundStyle(status == "Attending" ? Color(hex: "34C759") : (status == "Pending" ? AppColors.secondaryGray : AppColors.accentRed))
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(status == "Attending" ? Color(hex: "34C759").opacity(0.1) : (status == "Pending" ? AppColors.backgroundGray : AppColors.accentRed.opacity(0.1)))
            )
    }

    // MARK: - Timeline Tab

    private var timelineTab: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(timelineMockData.indices, id: \.self) { index in
                    let item = timelineMockData[index]
                    HStack(alignment: .top, spacing: AppSpacing.md) {
                        // Timeline line + dot
                        VStack(spacing: 0) {
                            Circle()
                                .fill(item.isComplete ? AppColors.accentRed : AppColors.backgroundGray)
                                .frame(width: 12, height: 12)
                            if index < timelineMockData.count - 1 {
                                Rectangle()
                                    .fill(AppColors.backgroundGray)
                                    .frame(width: 2)
                                    .frame(maxHeight: .infinity)
                            }
                        }
                        .frame(width: 12)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.date)
                                .font(AppTypography.caption1)
                                .foregroundStyle(AppColors.secondaryGray)
                            Text(item.title)
                                .font(AppTypography.bodyMedium)
                                .foregroundStyle(AppColors.primaryText)
                            if let sub = item.subtitle {
                                Text(sub)
                                    .font(AppTypography.footnote)
                                    .foregroundStyle(AppColors.secondaryGray)
                            }
                        }
                        .padding(.bottom, AppSpacing.xl)

                        Spacer()
                    }
                }

                Color.clear.frame(height: AppSpacing.tabBarHeight + AppSpacing.xxl)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.lg)
        }
    }

    // MARK: - Settings Sheet

    private var eventSettingsSheet: some View {
        VStack(spacing: AppSpacing.lg) {
            Text("Event Settings")
                .font(AppTypography.title3)
                .foregroundStyle(AppColors.primaryText)
                .padding(.top, AppSpacing.lg)

            VStack(spacing: 0) {
                settingsRow(icon: "lock.shield", title: "Privacy", value: "Public")
                Divider()
                settingsRow(icon: "bell", title: "Notifications", value: "On")
                Divider()
                settingsRow(icon: "shippingbox", title: "Shipping", value: "Set up")
                Divider()
                settingsRow(icon: "archivebox", title: "Archive Event", value: "")
            }
            .background(AppColors.white)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
            .softShadow()
            .padding(.horizontal, AppSpacing.screenHorizontal)

            Spacer()
        }
        .appBackground()
    }

    private func settingsRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(AppColors.secondaryGray)
                .frame(width: 32)
            Text(title)
                .font(AppTypography.body)
                .foregroundStyle(AppColors.primaryText)
            Spacer()
            Text(value)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.secondaryGray)
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundStyle(AppColors.secondaryGray)
        }
        .padding(AppSpacing.md)
    }

    // MARK: - Helpers

    private func imageUrl(for type: String) -> String {
        let t = type.lowercased()
        if t.contains("wedding") { return "https://images.unsplash.com/photo-1555244162-803834f70033?w=800" }
        if t.contains("baby")    { return "https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=800" }
        if t.contains("house")   { return "https://images.unsplash.com/photo-1556911220-e15024029581?w=800" }
        return "https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=800"
    }

    // MARK: - Mock Data

    private var guestMockData: [(name: String, role: String, avatar: String, status: String)] {
        [
            ("Maya Chen", "Co-host", "https://i.pravatar.cc/150?img=5", "Attending"),
            ("Liam Carter", "Guest", "https://i.pravatar.cc/150?img=8", "Attending"),
            ("Sofia Rivera", "Family", "https://i.pravatar.cc/150?img=9", "Attending"),
            ("Ethan Brooks", "Guest", "https://i.pravatar.cc/150?img=11", "Pending"),
            ("Ava Martinez", "Guest", "https://i.pravatar.cc/150?img=16", "Pending"),
            ("Noah Wilson", "Guest", "https://i.pravatar.cc/150?img=12", "Declined"),
        ]
    }

    private var timelineMockData: [(date: String, title: String, subtitle: String?, isComplete: Bool)] {
        [
            ("May 1", "Registry Created", "58 items added", true),
            ("May 8", "Save the Date Sent", "24 guests notified", true),
            ("May 15", "First Contribution", "Maya contributed $50", true),
            ("Jun 1", "RSVP Deadline", "18 of 24 responded", false),
            ("Jun 10", "Shipping Begins", nil, false),
            ("Jun 14", "Event Day 🎉", "Olivia & James's Wedding", false),
            ("Jun 21", "Thank-you Reminders", nil, false),
        ]
    }
}

// MARK: - Preview

#Preview("Event Command Center") {
    NavigationStack {
        EventCommandCenterView(event: .mock)
    }
}
