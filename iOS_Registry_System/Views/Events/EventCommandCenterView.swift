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
    @State private var selectedGuestFilter = "All"
    // Task sheet state
    @State private var showRSVPReminder    = false
    @State private var showShippingAddress = false
    @State private var showThankYouNotes   = false
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
                        .foregroundStyle(AppColors.primaryText)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(.regularMaterial)
                                .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 0.5))
                        )
                }
                .buttonStyle(.plain)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 10) {
                    Button { showInviteSheet = true } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AppColors.primaryText)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(.regularMaterial)
                                    .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 0.5))
                            )
                    }
                    .buttonStyle(.plain)

                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AppColors.primaryText)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(.regularMaterial)
                                    .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 0.5))
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .sheet(isPresented: $showInviteSheet) {
            InviteCollaboratorsSheet(giftTitle: event.title)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
        .sheet(isPresented: $showSettings) {
            eventSettingsSheet
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
        .sheet(isPresented: $showRSVPReminder) {
            RSVPReminderSheet()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
        .sheet(isPresented: $showShippingAddress) {
            ShippingAddressSheet()
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
        .sheet(isPresented: $showThankYouNotes) {
            ThankYouNoteSheet()
                .presentationDetents([.large])
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

            Button { showRSVPReminder    = true } label: { taskRow(icon: "envelope",            title: "Send RSVP reminders",  subtitle: "3 guests pending",    priority: .medium) }.buttonStyle(.plain)
            Button { showShippingAddress = true } label: { taskRow(icon: "shippingbox",          title: "Set shipping address",   subtitle: "Required before event", priority: .high) }.buttonStyle(.plain)
            Button { showThankYouNotes   = true } label: { taskRow(icon: "heart.text.clipboard", title: "Write thank-you notes",  subtitle: "After event day",      priority: .low) }.buttonStyle(.plain)
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
                    NavigationLink(destination: RegistryCategoryDetailView(categoryTitle: "Kitchen")) {
                        categoryCard(title: "Kitchen", subtitle: "12 items", imageUrl: "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&q=80")
                    }.buttonStyle(.plain)
                    
                    NavigationLink(destination: RegistryCategoryDetailView(categoryTitle: "Dining")) {
                        categoryCard(title: "Dining", subtitle: "8 items", imageUrl: "https://images.unsplash.com/photo-1603199505524-3e4cdaef1f6a?w=300&q=80")
                    }.buttonStyle(.plain)
                    
                    NavigationLink(destination: RegistryCategoryDetailView(categoryTitle: "Outdoor")) {
                        categoryCard(title: "Outdoor", subtitle: "5 items", imageUrl: "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=300&q=80")
                    }.buttonStyle(.plain)
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

    private let guestFilters = ["All", "Attending", "RSVP'd", "Invited", "No Response", "Declined"]

    private var filteredGuests: [(name: String, role: String, avatar: String, status: String, invitedDate: String)] {
        if selectedGuestFilter == "All" { return guestMockData }
        return guestMockData.filter { $0.status == selectedGuestFilter }
    }

    private var guestsTab: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // Stats row
                HStack(spacing: AppSpacing.sm) {
                    guestStatCard(value: "\(guestMockData.count)", label: "Total", icon: "person.2", color: AppColors.primaryText)
                    guestStatCard(value: "\(guestMockData.filter { $0.status == "Attending" }.count)", label: "Attending", icon: "checkmark.circle", color: Color(hex: "34C759"))
                    guestStatCard(value: "\(guestMockData.filter { $0.status == "No Response" || $0.status == "Invited" }.count)", label: "Pending", icon: "clock", color: Color(hex: "FF9500"))
                }

                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.xs) {
                        ForEach(guestFilters, id: \.self) { filter in
                            let count = filter == "All" ? guestMockData.count : guestMockData.filter { $0.status == filter }.count
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    selectedGuestFilter = filter
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(filter)
                                        .font(AppTypography.caption1Medium)
                                    Text("\(count)")
                                        .font(AppTypography.caption1)
                                        .foregroundStyle(selectedGuestFilter == filter ? .white.opacity(0.7) : AppColors.secondaryGray)
                                }
                                .foregroundStyle(selectedGuestFilter == filter ? .white : AppColors.primaryText)
                                .padding(.horizontal, AppSpacing.sm)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(selectedGuestFilter == filter ? AppColors.primaryText : AppColors.white)
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(selectedGuestFilter == filter ? Color.clear : Color.black.opacity(0.08), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Guest list
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack {
                        Text("GUEST LIST")
                            .font(AppTypography.caption1Medium)
                            .tracking(1.5)
                            .foregroundStyle(AppColors.secondaryGray)
                        Spacer()
                        Text("\(filteredGuests.count) guests")
                            .font(AppTypography.caption1)
                            .foregroundStyle(AppColors.secondaryGray)
                    }

                    if filteredGuests.isEmpty {
                        VStack(spacing: AppSpacing.sm) {
                            Image(systemName: "person.slash")
                                .font(.system(size: 32))
                                .foregroundStyle(AppColors.secondaryGray)
                            Text("No guests with this status")
                                .font(AppTypography.body)
                                .foregroundStyle(AppColors.secondaryGray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.xxl)
                    } else {
                        ForEach(filteredGuests, id: \.name) { guest in
                            guestRow(guest: guest)
                        }
                    }
                }

                Color.clear.frame(height: AppSpacing.tabBarHeight + AppSpacing.xxl)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.lg)
        }
    }

    private func guestRow(guest: (name: String, role: String, avatar: String, status: String, invitedDate: String)) -> some View {
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
                HStack(spacing: 6) {
                    Text(guest.role)
                        .font(AppTypography.caption1)
                        .foregroundStyle(AppColors.secondaryGray)
                    Text("·")
                        .foregroundStyle(AppColors.secondaryGray)
                    Text(guest.invitedDate)
                        .font(AppTypography.caption1)
                        .foregroundStyle(AppColors.secondaryGray)
                }
            }
            Spacer()
            rsvpBadge(status: guest.status)
        }
        .padding(AppSpacing.md)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
        .softShadow()
    }

    private func guestStatCard(value: String, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(color)
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
        let config: (Color, Color) = {
            switch status {
            case "Attending": return (Color(hex: "34C759"), Color(hex: "34C759").opacity(0.1))
            case "RSVP'd":    return (Color(hex: "007AFF"), Color(hex: "007AFF").opacity(0.1))
            case "Invited":   return (Color(hex: "FF9500"), Color(hex: "FF9500").opacity(0.1))
            case "No Response": return (AppColors.secondaryGray, AppColors.backgroundGray)
            case "Declined":  return (AppColors.accentRed, AppColors.accentRed.opacity(0.1))
            default:          return (AppColors.secondaryGray, AppColors.backgroundGray)
            }
        }()

        return Text(status)
            .font(AppTypography.caption1Medium)
            .foregroundStyle(config.0)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(Capsule().fill(config.1))
    }

    // MARK: - Timeline Tab

    private var currentStepIndex: Int {
        // Find the first incomplete step — that's "current"
        timelineMockData.firstIndex(where: { !$0.isComplete }) ?? timelineMockData.count - 1
    }

    private var timelineTab: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {

                // Journey progress header
                journeyProgressHeader

                // Journey steps
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(timelineMockData.indices, id: \.self) { index in
                        journeyStep(index: index)
                    }
                }

                Color.clear.frame(height: AppSpacing.tabBarHeight + AppSpacing.xxl)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.lg)
        }
    }

    // MARK: Journey Progress Header

    private var journeyProgressHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("YOUR JOURNEY")
                        .font(AppTypography.caption1Medium)
                        .tracking(1.5)
                        .foregroundStyle(AppColors.secondaryGray)
                    Text("Step \(currentStepIndex + 1) of \(timelineMockData.count)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.primaryText)
                }
                Spacer()
                // Circular progress
                ZStack {
                    Circle()
                        .stroke(AppColors.backgroundGray, lineWidth: 5)
                        .frame(width: 52, height: 52)
                    Circle()
                        .trim(from: 0, to: Double(timelineMockData.filter { $0.isComplete }.count) / Double(timelineMockData.count))
                        .stroke(AppColors.accentRed, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 52, height: 52)
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(Double(timelineMockData.filter { $0.isComplete }.count) / Double(timelineMockData.count) * 100))%")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.primaryText)
                }
            }

            // Completion bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppColors.backgroundGray)
                        .frame(height: 6)
                    Capsule()
                        .fill(AppColors.accentGradient)
                        .frame(width: geo.size.width * Double(timelineMockData.filter { $0.isComplete }.count) / Double(timelineMockData.count), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(AppSpacing.lg)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
        .softShadow()
    }

    // MARK: Journey Step

    private func journeyStep(index: Int) -> some View {
        let step = timelineMockData[index]
        let isCurrent = index == currentStepIndex
        let isLast = index == timelineMockData.count - 1

        return HStack(alignment: .top, spacing: AppSpacing.md) {

            // MARK: Rail + Node
            VStack(spacing: 0) {
                // Top connector (except first)
                if index > 0 {
                    Rectangle()
                        .fill(step.isComplete ? AppColors.accentRed : AppColors.backgroundGray)
                        .frame(width: 3, height: 20)
                } else {
                    Color.clear.frame(width: 3, height: 20)
                }

                // Node
                ZStack {
                    if step.isComplete {
                        // Completed — filled circle with checkmark
                        Circle()
                            .fill(AppColors.accentRed)
                            .frame(width: 32, height: 32)
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                    } else if isCurrent {
                        // Current — pulsing ring
                        Circle()
                            .fill(AppColors.accentRed.opacity(0.15))
                            .frame(width: 40, height: 40)
                        Circle()
                            .fill(AppColors.accentRed.opacity(0.3))
                            .frame(width: 32, height: 32)
                        Circle()
                            .fill(AppColors.accentRed)
                            .frame(width: 16, height: 16)
                    } else {
                        // Upcoming — empty ring
                        Circle()
                            .stroke(AppColors.backgroundGray, lineWidth: 2.5)
                            .frame(width: 32, height: 32)
                        Circle()
                            .fill(AppColors.backgroundGray)
                            .frame(width: 10, height: 10)
                    }
                }

                // Bottom connector (except last)
                if !isLast {
                    Rectangle()
                        .fill(step.isComplete ? AppColors.accentRed : AppColors.backgroundGray)
                        .frame(width: 3)
                        .frame(maxHeight: .infinity)
                } else {
                    Spacer(minLength: 0)
                }
            }
            .frame(width: 40)

            // MARK: Step Card
            VStack(alignment: .leading, spacing: 6) {
                // Date chip
                Text(step.date.uppercased())
                    .font(AppTypography.caption1Medium)
                    .tracking(1)
                    .foregroundStyle(isCurrent ? AppColors.accentRed : AppColors.secondaryGray)

                HStack(spacing: 8) {
                    Image(systemName: step.icon)
                        .font(.system(size: 16))
                        .foregroundStyle(step.isComplete ? AppColors.accentRed : (isCurrent ? AppColors.primaryText : AppColors.secondaryGray))
                    Text(step.title)
                        .font(isCurrent ? AppTypography.headline : AppTypography.bodyMedium)
                        .foregroundStyle(step.isComplete || isCurrent ? AppColors.primaryText : AppColors.secondaryGray)
                }

                if let sub = step.subtitle {
                    Text(sub)
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.secondaryGray)
                }

                if isCurrent {
                    Text("IN PROGRESS")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.5)
                        .foregroundStyle(AppColors.accentRed)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(AppColors.accentRed.opacity(0.1))
                        )
                        .padding(.top, 2)
                }
            }
            .padding(AppSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .fill(isCurrent ? AppColors.white : (step.isComplete ? AppColors.white.opacity(0.7) : AppColors.backgroundGray.opacity(0.5)))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .stroke(isCurrent ? AppColors.accentRed.opacity(0.3) : Color.clear, lineWidth: 1.5)
            )
            .shadow(color: isCurrent ? AppColors.accentRed.opacity(0.08) : .clear, radius: 8, y: 4)
            .padding(.vertical, 4)
        }
    }

    // MARK: - Timeline Mock Data

    private var timelineMockData: [(date: String, title: String, subtitle: String?, icon: String, isComplete: Bool)] {
        [
            ("May 1", "Registry Created", "58 items curated", "sparkles", true),
            ("May 8", "Save the Date", "24 guests notified via email", "envelope.fill", true),
            ("May 15", "First Contribution", "Maya contributed $50 🎉", "gift.fill", true),
            ("Jun 1", "RSVP Deadline", "18 of 24 responded", "calendar.badge.clock", false),
            ("Jun 10", "Shipping Begins", "Items ship to your address", "shippingbox.fill", false),
            ("Jun 14", "Event Day", "Sarah & James's Wedding 💍", "heart.fill", false),
            ("Jun 21", "Thank-You Notes", "Send gratitude to contributors", "heart.text.square.fill", false),
        ]
    }

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

    private var guestMockData: [(name: String, role: String, avatar: String, status: String, invitedDate: String)] {
        [
            ("Maya Chen", "Co-host", "https://i.pravatar.cc/150?img=5", "Attending", "May 2"),
            ("Liam Carter", "Guest", "https://i.pravatar.cc/150?img=8", "Attending", "May 3"),
            ("Sofia Rivera", "Family", "https://i.pravatar.cc/150?img=9", "Attending", "May 2"),
            ("James Park", "Friend", "https://i.pravatar.cc/150?img=14", "RSVP'd", "May 5"),
            ("Olivia Turner", "Family", "https://i.pravatar.cc/150?img=20", "RSVP'd", "May 4"),
            ("Ethan Brooks", "Guest", "https://i.pravatar.cc/150?img=11", "Invited", "May 8"),
            ("Ava Martinez", "Guest", "https://i.pravatar.cc/150?img=16", "Invited", "May 10"),
            ("Mia Johnson", "Friend", "https://i.pravatar.cc/150?img=23", "No Response", "May 6"),
            ("Lucas Kim", "Colleague", "https://i.pravatar.cc/150?img=33", "No Response", "May 7"),
            ("Noah Wilson", "Guest", "https://i.pravatar.cc/150?img=12", "Declined", "May 3"),
        ]
    }

}

// MARK: - Preview

#Preview("Event Command Center") {
    NavigationStack {
        EventCommandCenterView(event: .mock)
    }
}
