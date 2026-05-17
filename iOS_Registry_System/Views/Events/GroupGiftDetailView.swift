//
//  GroupGiftDetailView.swift
//  iOS_Registry_System
//
//  Screen 2 in Priority Gifts flow.
//  Shows editorial product images, funding ring, contributor list,
//  amount picker, and CTAs — all styled as liquid glass 26.0.
//

import SwiftUI

// MARK: - Group Gift Detail View

struct GroupGiftDetailView: View {

    let gift: PriorityGiftItem

    // Navigation state
    @State private var showContributionSheet = false
    @State private var openCustomMode: Bool   = false
    @State private var showInviteSheet        = false
    @State private var showContributors       = false
    @State private var selectedAmount: Double = 50
    @State private var galleryIndex: Int = 0
    @Environment(\.dismiss) private var dismiss

    // Contribution amounts
    private let quickAmounts: [Double] = [25, 50, 100]

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    gallerySection
                    contentSection
                    Color.clear.frame(height: 160)
                }
            }
            .ignoresSafeArea(edges: .top)
            .appBackground()

            bottomCTABar
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                glassNavButton(systemImage: "chevron.left") { dismiss() }
            }
            ToolbarItem(placement: .principal) {
                Text("GROUP GIFT")
                    .font(AppTypography.caption1Medium)
                    .tracking(2)
                    .foregroundStyle(AppColors.primaryText)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                glassNavButton(systemImage: "square.and.arrow.up") { }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(isPresented: $showContributionSheet, onDismiss: { openCustomMode = false }) {
            ContributionSheetView(
                gift: gift,
                selectedAmount: $selectedAmount,
                startInCustomMode: openCustomMode,
                onContribute: { handleContribution() }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(32)
        }
        .sheet(isPresented: $showInviteSheet) {
            InviteCollaboratorsSheet(eventId: nil, giftTitle: gift.title)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
        .navigationDestination(isPresented: $showContributors) {
            ContributorsListView(gift: gift)
        }
    }

    // MARK: - Gallery Section

    private var gallerySection: some View {
        TabView(selection: $galleryIndex) {
            ForEach(gift.galleryURLs.indices, id: \.self) { idx in
                AsyncImage(url: URL(string: gift.galleryURLs[idx])) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(hex: "E8E2DC")
                }
                .frame(maxWidth: .infinity)
                .clipped()
                .tag(idx)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .frame(height: 340)
        .overlay(alignment: .top) {
            // shipping badge
            HStack {
                Text("FREE SHIPPING")
                    .font(AppTypography.caption2)
                    .tracking(1.5)
                    .foregroundStyle(AppColors.primaryDark)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.5), lineWidth: 0.5))
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, 56)
                Spacer()
            }
        }
    }

    // MARK: - Content Section

    private var contentSection: some View {
        VStack(alignment: .center, spacing: AppSpacing.xl) {

            // Collection label + title
            VStack(spacing: 6) {
                Text(gift.collectionLabel)
                    .font(AppTypography.caption2)
                    .tracking(2)
                    .foregroundStyle(AppColors.secondaryGray)

                Text(gift.title)
                    .font(AppTypography.largeTitleSerif)
                    .foregroundStyle(AppColors.primaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, AppSpacing.xl)

            // Funding ring
            fundingRing

            // Stat cards row
            statRow

            // AI editorial nudge
            if gift.isAIRecommended {
                aiNudgeBanner
            }

            // Friends who joined list
            friendsSection

            // Quick amount picker (above bottom bar)
            amountPicker
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
    }

    // MARK: - Funding Ring

    private var fundingRing: some View {
        ZStack {
            Circle()
                .stroke(AppColors.backgroundGray, lineWidth: 10)
                .frame(width: 140, height: 140)

            Circle()
                .trim(from: 0, to: CGFloat(gift.progress))
                .stroke(
                    AppColors.accentRed,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .frame(width: 140, height: 140)
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 1, dampingFraction: 0.7), value: gift.progress)

            VStack(spacing: 4) {
                Text("\(gift.percentFunded)%")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.primaryText)
                Text("funded")
                    .font(AppTypography.caption1)
                    .foregroundStyle(AppColors.secondaryGray)
            }
        }
    }

    // MARK: - Stat Row

    private var statRow: some View {
        HStack(spacing: AppSpacing.sm) {
            statCard(value: "$\(Int(gift.currentAmount))", label: "raised")
            statCard(value: "$\(Int(gift.amountToGo))", label: "to go")
            statCard(value: "\(gift.contributorCount)", label: "friends")
        }
    }

    private func statCard(value: String, label: String) -> some View {
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
        .cardStyle()
    }

    // MARK: - AI Nudge Banner

    private var aiNudgeBanner: some View {
        HStack(spacing: AppSpacing.sm) {
            Text(almostThereMessage)
                .font(.system(size: 15, weight: .regular, design: .serif))
                .italic()
                .foregroundStyle(AppColors.accentRed.opacity(0.85))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .frame(maxWidth: .infinity)
        .background(AppColors.accentRed.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md, style: .continuous))
    }

    private var almostThereMessage: String {
        let remaining = Int(gift.amountToGo)
        if remaining < 100 {
            return "Almost there — a final gift away from celebrating together."
        } else {
            return "You're making a real difference — every contribution counts."
        }
    }

    // MARK: - Friends Section

    private var friendsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sectionHeaderGap) {
            Text("FRIENDS WHO JOINED")
                .font(AppTypography.caption1Medium)
                .tracking(1.5)
                .foregroundStyle(AppColors.primaryText)

            VStack(spacing: 0) {
                ForEach(gift.contributors) { contributor in
                    ContributorRow(contributor: contributor)
                    if contributor.id != gift.contributors.last?.id {
                        Divider()
                            .padding(.leading, 56)
                    }
                }
            }
            .background(AppColors.white)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
            .softShadow()
        }
    }

    // MARK: - Amount Picker

    private var amountPicker: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                spacing: AppSpacing.sm
            ) {
                ForEach(quickAmounts, id: \.self) { amount in
                    amountChip(amount: amount)
                }
            }
            amountChip(amount: 0, isCustom: true)
                .frame(maxWidth: .infinity)
        }
    }

    private func amountChip(amount: Double, isCustom: Bool = false) -> some View {
        let isSelected = !isCustom && selectedAmount == amount
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                if isCustom {
                    // Open sheet in custom mode
                    openCustomMode = true
                    showContributionSheet = true
                } else {
                    openCustomMode = false
                    selectedAmount = amount
                }
            }
        } label: {
            Text(isCustom ? "Custom" : "$\(Int(amount))")
                .font(AppTypography.bodyMedium)
                .foregroundStyle(isSelected ? AppColors.white : AppColors.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.sm)
                .background(
                    Group {
                        if isSelected {
                            Capsule().fill(AppColors.primaryDark)
                        } else {
                            Capsule()
                                .fill(AppColors.white)
                                .overlay(Capsule().stroke(Color.black.opacity(0.12), lineWidth: 1))
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }

    private var bottomCTABar: some View {
        HStack(spacing: AppSpacing.sm) {

            // Invite button — outlined liquid glass
            Button {
                showInviteSheet = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 15, weight: .medium))
                    Text("Invite")
                        .font(AppTypography.buttonMedium)
                }
                .foregroundStyle(AppColors.primaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    Capsule()
                        .fill(AppColors.white)
                        .overlay(
                            Capsule()
                                .stroke(Color.black.opacity(0.12), lineWidth: 1)
                        )
                )
                .softShadow()
            }
            .buttonStyle(.plain)

            // Contribute button — accent red solid
            Button {
                openCustomMode = false
                showContributionSheet = true
            } label: {
                Text("Contribute $\(Int(selectedAmount))")
                    .font(AppTypography.buttonMedium)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(AppColors.accentRed)
                    .clipShape(Capsule())
                    .accentShadow()
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.bottom, AppSpacing.tabBarHeight + AppSpacing.md)
        .padding(.top, AppSpacing.sm)
        .background(
            Rectangle()
                .fill(AppColors.white.opacity(0.95))
                .ignoresSafeArea(edges: .bottom)
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundStyle(Color.black.opacity(0.08)),
                    alignment: .top
                )
        )
    }

    // MARK: - Helpers

    private func handleContribution() {
        showContributionSheet = false
    }

    @ViewBuilder
    private func glassNavButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(AppColors.primaryText)
                .frame(width: 38, height: 38)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                        .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 0.5))
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Contributor Row

struct ContributorRow: View {
    let contributor: Contributor

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            AsyncImage(url: URL(string: contributor.avatarURL ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle().fill(AppColors.backgroundGray)
                    .overlay(Text(String(contributor.name.prefix(1)))
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.secondaryGray))
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(contributor.name)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)
                Text(contributor.timeAgo)
                    .font(AppTypography.caption1)
                    .foregroundStyle(AppColors.secondaryGray)
            }

            Spacer()

            Text("+$\(Int(contributor.amount))")
                .font(AppTypography.bodyMedium)
                .foregroundStyle(AppColors.primaryText)
        }
        .padding(.vertical, AppSpacing.sm)
        .padding(.horizontal, AppSpacing.md)
    }
}

// MARK: - Preview

#Preview("Group Gift Detail") {
    NavigationStack {
        GroupGiftDetailView(gift: .espressoMachine)
    }
}
