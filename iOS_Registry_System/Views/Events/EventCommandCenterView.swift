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

    struct ThankYouNoteItem: Identifiable, Hashable {
        let id: UUID
        let guestName: String
        let guestAvatar: String?
        let amount: Double
        let itemName: String
        let itemImage: String?
        let timeAgo: String
    }

    let event: Event
    @State private var registryViewModel: FriendRegistryDetailViewModel
    
    @State private var selectedTab: EventCenterTab = .overview
    @State private var showInviteSheet = false
    @State private var showSettings = false
    @State private var selectedGuestFilter = "All"
    
    struct GuestDisplayItem: Identifiable, Hashable {
        let id: UUID
        let name: String
        let email: String?
        let avatarUrl: String?
        let status: String  // "pending", "accepted", "declined"
        let joinedAt: Date?
    }

    @State private var thankYouNotes: [ThankYouNoteItem] = []
    @State private var selectedNoteIndex = 0
    @State private var isLoadingNotes = false
    @State private var guests: [GuestDisplayItem] = []
    @State private var isLoadingGuests = false
    
    // Co-hosts and owner state
    @State private var ownerUser: User? = nil
    @State private var coHosts: [(member: EventMember, user: User?)] = []
    @State private var isLoadingCoHosts = false

    // Task sheet state
    @State private var showRSVPReminder    = false
    @State private var showShippingAddress = false
    @State private var showThankYouNotes   = false
    @State private var showHealthAnalyzer   = false
    @State private var showModifyRegistry   = false
    @Environment(\.dismiss) private var dismiss

    init(event: Event) {
        self.event = event
        self._registryViewModel = State(initialValue: FriendRegistryDetailViewModel(event: event))
    }

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
        .task {
            await registryViewModel.loadRegistryData()
            await fetchThankYouNotes()
            await fetchInvitations()
            await fetchCoHostsAndOwner()
        }
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
                }
            }
        }
        .sheet(isPresented: $showInviteSheet) {
            InviteCollaboratorsSheet(eventId: event.id, giftTitle: event.title)
                .presentationDetents([.medium, .large])
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
            ThankYouNoteSheet(thankYouNotes: thankYouNotes, initialSelectedIndex: selectedNoteIndex)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
        .sheet(isPresented: $showHealthAnalyzer) {
            RegistryHealthSheet(items: PriorityGiftItem.allMock)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
        .sheet(isPresented: $showModifyRegistry) {
            NavigationStack {
                AddRegistryItemsView(event: event) {
                    showModifyRegistry = false
                }
            }
            .interactiveDismissDisabled()
        }
        .onChange(of: showModifyRegistry) { _, newValue in
            if !newValue {
                Task {
                    await registryViewModel.loadRegistryData()
                }
            }
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
                if let date = event.startDate {
                    Text(date.daysUntil.uppercased())
                        .font(AppTypography.caption1Medium)
                        .fontWeight(.bold)
                        .foregroundStyle(AppColors.primaryDark)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(.white))
                }

                Text("\(event.eventType.replacingOccurrences(of: "_", with: " ").uppercased()) · \((event.startDate ?? Date()).formattedLong.uppercased())")
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

                // Hosts & Collaborators (Co-hosts)
                hostsSection

                // Thank You Notes (Actual Activity)
                recentActivitySection

                Color.clear.frame(height: AppSpacing.tabBarHeight + AppSpacing.xxl)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.lg)
        }
    }

    private var hostsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sectionHeaderGap) {
            Text("HOSTS & COLLABORATORS")
                .font(AppTypography.caption1Medium)
                .tracking(1.5)
                .foregroundStyle(AppColors.secondaryGray)

            VStack(spacing: 0) {
                // 1. Owner/Creator
                if let owner = ownerUser {
                    HStack(spacing: AppSpacing.md) {
                        AsyncImage(url: URL(string: owner.avatarUrl ?? "")) { img in
                            img.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle().fill(AppColors.backgroundGray)
                                .overlay(
                                    Text(String(owner.fullName.prefix(1)))
                                        .font(AppTypography.bodyMedium)
                                        .foregroundStyle(AppColors.secondaryGray)
                                )
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(owner.fullName)
                                .font(AppTypography.bodyMedium)
                                .foregroundStyle(AppColors.primaryText)
                            Text("Host / Creator")
                                .font(AppTypography.caption1)
                                .foregroundStyle(AppColors.secondaryGray)
                        }
                        Spacer()
                    }
                    .padding(AppSpacing.md)
                } else {
                    // Fallback using event creator info if profile is still loading
                    HStack(spacing: AppSpacing.md) {
                        Circle().fill(AppColors.backgroundGray)
                            .frame(width: 40, height: 40)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(0.8)
                            )
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Loading Host...")
                                .font(AppTypography.bodyMedium)
                                .foregroundStyle(AppColors.primaryText)
                        }
                        Spacer()
                    }
                    .padding(AppSpacing.md)
                }

                // 2. Collaborators/Co-hosts
                ForEach(coHosts, id: \.member.id) { pair in
                    Divider().padding(.horizontal, AppSpacing.md)
                    
                    HStack(spacing: AppSpacing.md) {
                        if let user = pair.user {
                            AsyncImage(url: URL(string: user.avatarUrl ?? "")) { img in
                                img.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Circle().fill(AppColors.backgroundGray)
                                    .overlay(
                                        Text(String(user.fullName.prefix(1)))
                                            .font(AppTypography.bodyMedium)
                                            .foregroundStyle(AppColors.secondaryGray)
                                    )
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text(user.fullName)
                                    .font(AppTypography.bodyMedium)
                                    .foregroundStyle(AppColors.primaryText)
                                Text("Co-Host")
                                    .font(AppTypography.caption1)
                                    .foregroundStyle(AppColors.secondaryGray)
                            }
                        } else {
                            Circle().fill(AppColors.backgroundGray)
                                .frame(width: 40, height: 40)
                            Text("Invited Collaborator")
                                .font(AppTypography.bodyMedium)
                                .foregroundStyle(AppColors.primaryText)
                        }

                        Spacer()

                        let isPending = pair.member.status?.lowercased() == "pending"
                        Text(isPending ? "Pending" : "Active")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.5)
                            .foregroundStyle(isPending ? AppColors.accentRed : Color(hex: "34C759"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(isPending ? AppColors.accentRed.opacity(0.1) : Color(hex: "34C759").opacity(0.1))
                            .clipShape(Capsule())
                    }
                    .padding(AppSpacing.md)
                }
            }
            .background(AppColors.white)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
            .softShadow()
        }
    }

    private var totalTargetAmount: Double {
        registryViewModel.registryItems.reduce(0.0) { result, item in
            result + (item.price * Double(item.quantityNeeded ?? 1))
        }
    }
    
    private var totalRaisedAmount: Double {
        registryViewModel.registryItems.reduce(0.0) { result, item in
            if let funded = item.fundedAmount, funded > 0 {
                return result + funded
            } else {
                return result + (item.price * Double(item.quantityPurchased ?? 0))
            }
        }
    }
    
    private var registryProgressPercentage: Double {
        guard totalTargetAmount > 0 else { return 0 }
        return min(totalRaisedAmount / totalTargetAmount, 1.0)
    }

    private var registryProgressCard: some View {
        HStack(spacing: AppSpacing.lg) {
            // Progress ring
            ZStack {
                Circle()
                    .stroke(AppColors.backgroundGray, lineWidth: 7)
                    .frame(width: 76, height: 76)
                Circle()
                    .trim(from: 0, to: registryProgressPercentage)
                    .stroke(AppColors.accentRed, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                    .frame(width: 76, height: 76)
                    .rotationEffect(.degrees(-90))
                Text("\(Int(registryProgressPercentage * 100))%")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.primaryText)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("REGISTRY PROGRESS")
                    .font(AppTypography.caption1Medium)
                    .tracking(1.5)
                    .foregroundStyle(AppColors.secondaryGray)
                Text("$\(Int(totalRaisedAmount)) raised of\n$\(Int(totalTargetAmount))")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.primaryText)
                
                // For now, show item count instead of contributor count if contributor count is not yet fetched
                Text("\(registryViewModel.registryItems.count) gifts added")
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
                Text(event.startDate?.daysUntil ?? "—")
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

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("THANK YOU NOTES")
                .font(AppTypography.caption1Medium)
                .tracking(1.5)
                .foregroundStyle(AppColors.secondaryGray)

            if isLoadingNotes {
                ProgressView().padding(.vertical, AppSpacing.md)
            } else if thankYouNotes.isEmpty {
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(AppColors.backgroundGray)
                    Text("No contributions yet.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryGray)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.xl)
            } else {
                ForEach(thankYouNotes) { note in
                    Button {
                        if let index = thankYouNotes.firstIndex(where: { $0.id == note.id }) {
                            selectedNoteIndex = index
                            showThankYouNotes = true
                        }
                    } label: {
                        HStack(spacing: AppSpacing.sm) {
                            AsyncImage(url: URL(string: note.guestAvatar ?? "")) { img in
                                img.resizable().aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Circle().fill(AppColors.backgroundGray)
                                    .overlay(Text(note.guestName.prefix(1)).font(AppTypography.caption1Medium))
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(note.guestName)")
                                    .font(AppTypography.bodyMedium)
                                    .foregroundStyle(AppColors.primaryText)
                                Text("contributed to \(note.itemName)")
                                    .font(AppTypography.caption1)
                                    .foregroundStyle(AppColors.secondaryGray)
                                    .lineLimit(1)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("+$\(Int(note.amount))")
                                    .font(AppTypography.bodyMedium)
                                    .foregroundStyle(AppColors.accentRed)
                                Text(note.timeAgo)
                                    .font(AppTypography.caption2)
                                    .foregroundStyle(AppColors.secondaryGray)
                            }
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(AppColors.secondaryGray)
                                .padding(.leading, 4)
                        }
                        .padding(AppSpacing.sm)
                        .background(AppColors.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
                        .softShadow()
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private func fetchThankYouNotes() async {
        isLoadingNotes = true
        defer { isLoadingNotes = false }
        
        do {
            let itemIds = registryViewModel.registryItems.map { $0.id }
            guard !itemIds.isEmpty else { return }
            
            // Fetch event guests (for guest count context only)
            let membersWithUsers = try await EventService.shared.fetchEventMembersWithUsers(eventId: event.id)
            
            // 1. Fetch All Reservations
            let allReservations = try await EventService.shared.fetchAllReservationsForRegistryItems(itemIds: itemIds)
            
            // 2. Fetch Contributions
            let contributions = try await EventService.shared.fetchContributionsForRegistryItems(itemIds: itemIds)
            
            let contributionResIds = Set(contributions.map { $0.reservationId })
            let purchases = allReservations.filter { $0.isPurchased == true && !contributionResIds.contains($0.id) }
            
            var userIds: [UUID] = []
            purchases.forEach { if let u = $0.reservedBy { userIds.append(u) } }
            contributions.forEach { if let u = $0.contributorBy { userIds.append(u) } }
            
            // 3. Fetch Users
            let users = try await EventService.shared.fetchUsers(ids: userIds)
            let userMap = Dictionary(uniqueKeysWithValues: users.map { ($0.id, $0) })
            
            var notes: [ThankYouNoteItem] = []
            let itemMap = Dictionary(uniqueKeysWithValues: registryViewModel.registryItems.map { ($0.id, $0) })
            
            // Map purchases
            for purchase in purchases {
                guard let userId = purchase.reservedBy, let user = userMap[userId] else { continue }
                guard let item = itemMap[purchase.registryItemId] else { continue }
                
                let amount = item.price * Double(purchase.quantity ?? 1)
                notes.append(ThankYouNoteItem(
                    id: purchase.id,
                    guestName: user.fullName,
                    guestAvatar: user.avatarUrl,
                    amount: amount,
                    itemName: item.itemName,
                    itemImage: item.imageUrl,
                    timeAgo: purchase.createdAt?.daysUntil ?? "Recently"
                ))
            }
            
            // Map reservationId to registryItemId
            let reservationToItemMap = Dictionary(uniqueKeysWithValues: allReservations.map { ($0.id, $0.registryItemId) })
            
            // Map contributions
            for contribution in contributions {
                guard let userId = contribution.contributorBy, let user = userMap[userId] else { continue }
                var resolvedItemName = "Group Gift"
                var resolvedItemImage: String? = nil
                if let itemId = reservationToItemMap[contribution.reservationId], let item = itemMap[itemId] {
                    resolvedItemName = item.itemName
                    resolvedItemImage = item.imageUrl
                }
                notes.append(ThankYouNoteItem(
                    id: contribution.id,
                    guestName: user.fullName,
                    guestAvatar: user.avatarUrl,
                    amount: contribution.amount,
                    itemName: resolvedItemName,
                    itemImage: resolvedItemImage,
                    timeAgo: contribution.createdAt?.daysUntil ?? "Recently"
                ))
            }
            
            await MainActor.run {
                self.thankYouNotes = notes
            }
        } catch {
            print("❌ Failed to fetch thank you notes: \(error)")
        }
    }

    // MARK: - Registry Tab

    private let gridColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var registryTab: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                
                let isEventOver = (event.endDate ?? event.startDate ?? Date.distantFuture) < Date()
                if !isEventOver {
                    Button {
                        showModifyRegistry = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Modify Registry")
                                .font(AppTypography.buttonMedium)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(AppColors.secondaryGray)
                        }
                        .foregroundStyle(AppColors.primaryDark)
                        .padding()
                        .background(AppColors.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
                        .softShadow()
                    }
                    .buttonStyle(.plain)
                }

                // Dynamic Categories Filter
                if !registryViewModel.categories.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppSpacing.xs) {
                            StatusChip(
                                title: "All",
                                isSelected: registryViewModel.selectedCategory == nil
                            ) {
                                registryViewModel.selectedCategory = nil
                            }
                            
                            ForEach(registryViewModel.categories, id: \.self) { category in
                                StatusChip(
                                    title: category,
                                    isSelected: registryViewModel.selectedCategory == category
                                ) {
                                    registryViewModel.selectedCategory = category
                                }
                            }
                        }
                    }
                }

                // AI Registry Health Card
                registryHealthAnalyzerCard

                // Dynamic Registry Items Grid
                if registryViewModel.isLoading {
                    ProgressView().padding(.vertical, AppSpacing.xl)
                } else if registryViewModel.filteredItems.isEmpty {
                    Text("No items added yet.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryGray)
                        .padding(.vertical, AppSpacing.xl)
                } else {
                    LazyVGrid(columns: gridColumns, spacing: 12) {
                        ForEach(registryViewModel.filteredItems) { item in
                            if let product = registryViewModel.product(for: item) {
                                RegistryItemCard(
                                    product: product,
                                    registryItem: item,
                                    isGroupGifting: registryViewModel.isGroupGifting(for: item),
                                    isHostView: true,
                                    isEventOver: (event.endDate ?? event.startDate ?? Date.distantFuture) < Date(),
                                    onTap: {
                                        registryViewModel.selectedItem = item
                                    }
                                )
                            }
                        }
                    }
                }

                Color.clear.frame(height: AppSpacing.tabBarHeight + AppSpacing.xxl)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.lg)
        }
        .sheet(item: $registryViewModel.selectedItem) { item in
            if let product = registryViewModel.product(for: item) {
                RegistryItemDetailView(
                    item: item,
                    product: product,
                    eventName: event.title,
                    isGroupGifting: registryViewModel.isGroupGifting(for: item),
                    isHostView: true
                )
            }
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

    private var registryHealthAnalyzerCard: some View {
        HStack(spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColors.accentRed)
                    Text("AI REGISTRY ANALYZER")
                        .font(AppTypography.caption1Medium)
                        .tracking(1.5)
                        .foregroundStyle(AppColors.accentRed)
                }
                
                Text("Analyze your registry health")
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)
                
                Text("Ensure a perfect blend of categories and price ranges for guest satisfaction.")
                    .font(AppTypography.caption1)
                    .foregroundStyle(AppColors.secondaryGray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Button {
                showHealthAnalyzer = true
            } label: {
                Text("Check")
                    .font(AppTypography.buttonSmall)
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, 8)
                    .background(AppColors.accentRed)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(AppSpacing.md)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
        .softShadow()
    }

    // MARK: - Guests Tab

    private let guestFilters = ["All", "Accepted", "Pending", "Declined"]

    private var filteredGuests: [GuestDisplayItem] {
        if selectedGuestFilter == "All" { return guests }
        let statusKey = selectedGuestFilter.lowercased()
        return guests.filter { $0.status == statusKey }
    }

    private func guestCount(for filter: String) -> Int {
        if filter == "All" { return guests.count }
        let key = filter.lowercased()
        return guests.filter { $0.status == key }.count
    }

    private func displayStatus(for guest: GuestDisplayItem) -> String {
        switch guest.status {
        case "accepted": return "Accepted"
        case "declined": return "Declined"
        default: return "Pending"
        }
    }

    private var guestsTab: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // Stats row
                HStack(spacing: AppSpacing.sm) {
                    guestStatCard(value: "\(guests.count)", label: "Total", icon: "person.2", color: AppColors.primaryText)
                    guestStatCard(value: "\(guestCount(for: "Accepted"))", label: "Accepted", icon: "checkmark.circle", color: Color(hex: "34C759"))
                    guestStatCard(value: "\(guestCount(for: "Pending"))", label: "Pending", icon: "clock", color: Color(hex: "FF9500"))
                }

                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.xs) {
                        ForEach(guestFilters, id: \.self) { filter in
                            let count = guestCount(for: filter)
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

                    if isLoadingGuests {
                        ProgressView().padding(.vertical, AppSpacing.xl)
                    } else if filteredGuests.isEmpty {
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
                        ForEach(filteredGuests) { guest in
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

    private func guestRow(guest: GuestDisplayItem) -> some View {
        HStack(spacing: AppSpacing.md) {
            if let avatarUrl = guest.avatarUrl, !avatarUrl.isEmpty {
                AsyncImage(url: URL(string: avatarUrl)) { img in
                    img.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle().fill(AppColors.backgroundGray)
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())
            } else {
                Circle().fill(AppColors.backgroundGray)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Text(guest.name.prefix(1).uppercased())
                            .font(AppTypography.bodyMedium)
                            .foregroundStyle(AppColors.secondaryGray)
                    )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(guest.name)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)
                HStack(spacing: 6) {
                    if let email = guest.email {
                        Text(email)
                            .font(AppTypography.caption1)
                            .foregroundStyle(AppColors.secondaryGray)
                            .lineLimit(1)
                    }
                    if let joinedAt = guest.joinedAt {
                        Text("·")
                            .foregroundStyle(AppColors.secondaryGray)
                        Text(joinedAt.formatted(.dateTime.month(.abbreviated).day()))
                            .font(AppTypography.caption1)
                            .foregroundStyle(AppColors.secondaryGray)
                    }
                }
            }
            Spacer()
            rsvpBadge(status: displayStatus(for: guest))
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
            case "Accepted":  return (Color(hex: "34C759"), Color(hex: "34C759").opacity(0.1))
            case "Pending":   return (Color(hex: "FF9500"), Color(hex: "FF9500").opacity(0.1))
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
        timelineData.firstIndex(where: { !$0.isComplete }) ?? timelineData.count - 1
    }

    private var timelineTab: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {

                // Journey progress header
                journeyProgressHeader

                // Journey steps
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(timelineData.indices, id: \.self) { index in
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
                    Text("Step \(currentStepIndex + 1) of \(timelineData.count)")
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
                        .trim(from: 0, to: Double(timelineData.filter { $0.isComplete }.count) / Double(timelineData.count))
                        .stroke(AppColors.accentRed, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 52, height: 52)
                        .rotationEffect(.degrees(-90))
                    Text("\(Int(Double(timelineData.filter { $0.isComplete }.count) / Double(timelineData.count) * 100))%")
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
                        .frame(width: geo.size.width * Double(timelineData.filter { $0.isComplete }.count) / Double(timelineData.count), height: 6)
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
        let step = timelineData[index]
        let isCurrent = index == currentStepIndex
        let isLast = index == timelineData.count - 1

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
                    let isUpcoming = step.title == "Event Day"
                    Text(isUpcoming ? "UPCOMING" : "IN PROGRESS")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.5)
                        .foregroundStyle(isUpcoming ? AppColors.secondaryGray : AppColors.accentRed)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(isUpcoming ? AppColors.backgroundGray : AppColors.accentRed.opacity(0.1))
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

    private var timelineData: [(date: String, title: String, subtitle: String?, icon: String, isComplete: Bool)] {
        var steps: [(date: String, title: String, subtitle: String?, icon: String, isComplete: Bool)] = []

        // 1. Registry Created
        let createdDate = event.createdAt?.formatted(.dateTime.month(.abbreviated).day()) ?? "—"
        steps.append((createdDate, "Registry Created", "\(registryViewModel.registryItems.count) items curated", "sparkles", true))

        // 2. First Contribution / Purchase
        if let firstNote = thankYouNotes.first {
            steps.append((firstNote.timeAgo, "First Contribution", "\(firstNote.guestName) contributed to \(firstNote.itemName) 🎉", "gift.fill", true))
        } else {
            steps.append(("—", "First Contribution", "No contributions yet", "gift.fill", false))
        }

        // 3. Event Day
        let eventDate = event.startDate?.formatted(.dateTime.month(.abbreviated).day()) ?? "TBD"
        let eventPassed = (event.startDate ?? Date.distantFuture) < Date()
        steps.append((eventDate, "Event Day", "\(event.title) 🎉", "heart.fill", eventPassed))

        return steps
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

    private func fetchInvitations() async {
        isLoadingGuests = true
        defer { isLoadingGuests = false }
        do {
            let membersWithUsers = try await EventService.shared.fetchEventMembersWithUsers(eventId: event.id)
            let guestMembers = membersWithUsers.filter { $0.member.membershipType == "guest" }
            let items = guestMembers.map { pair in
                GuestDisplayItem(
                    id: pair.member.id,
                    name: pair.user?.fullName ?? "Unknown Guest",
                    email: pair.user?.email,
                    avatarUrl: pair.user?.avatarUrl,
                    status: (pair.member.status ?? "pending").lowercased(),
                    joinedAt: pair.member.joinedAt
                )
            }
            await MainActor.run {
                self.guests = items
            }
        } catch {
            print("❌ Failed to fetch guests: \(error)")
        }
    }

    private func fetchCoHostsAndOwner() async {
        isLoadingCoHosts = true
        defer { isLoadingCoHosts = false }
        do {
            let fetchedOwner = try await EventService.shared.fetchUsers(ids: [event.ownerUserId]).first
            let fetchedCoHosts = try await EventService.shared.fetchCollaboratorsWithUsers(eventId: event.id)
            
            await MainActor.run {
                self.ownerUser = fetchedOwner
                self.coHosts = fetchedCoHosts
            }
        } catch {
            print("❌ Failed to fetch co-hosts and owner: \(error)")
        }
    }

}

