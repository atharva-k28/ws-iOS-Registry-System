//
//  ProfileView.swift
//  iOS_Registry_System
//
//  Profile screen — starter layout
//

import SwiftUI

// MARK: - Profile View

struct ProfileView: View {

    @State private var viewModel = ProfileViewModel()
    @State private var showEditProfile = false

    var body: some View {
        Group {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppSpacing.sectionGap) {

                    // MARK: Profile Header
                    profileHeader
                        .padding(.top, 8)

                    // MARK: Wallet
                    NavigationLink(destination: WalletCreditsView()) {
                        WalletCard(
                            balance: viewModel.walletBalance
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, AppSpacing.screenHorizontal)

                    // MARK: Stats Row
                    statsRow

                    // MARK: Menu Sections
                    menuSection

                    // Bottom spacer for tab bar
                    Color.clear.frame(height: AppSpacing.tabBarHeight + AppSpacing.xxl)
                }
            }
            .appBackground()
            .transparentNavigationBar()
            .task {
                await viewModel.loadProfile()
            }
            .sheet(isPresented: $showEditProfile, onDismiss: {
                Task {
                    await viewModel.loadProfile()
                }
            }) {
                EditProfileView(user: viewModel.user, viewModel: viewModel)
            }
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: AppSpacing.md) {
            // Avatar
            Circle()
                .fill(AppColors.backgroundGray)
                .frame(width: 100, height: 100)
                .overlay {
                    if let avatarUrl = viewModel.user?.avatarUrl,
                       let url = URL(string: avatarUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            AppColors.backgroundGray
                        }
                        .clipShape(Circle())
                    } else {
                        Text(viewModel.initials)
                            .font(AppTypography.title2)
                            .foregroundStyle(AppColors.primaryText)
                            .clipShape(Circle())
                    }
                }
                .overlay(
                    Circle().strokeBorder(AppColors.white, lineWidth: 4)
                )
                .softShadow()

            VStack(spacing: AppSpacing.xxxs) {
                Text(viewModel.displayName)
                    .font(AppTypography.title2)
                    .foregroundStyle(AppColors.primaryText)

                if !viewModel.subtitle.isEmpty {
                    Text(viewModel.subtitle)
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.secondaryGray)
                        .multilineTextAlignment(.center)
                }
            }

            Button("Edit Profile") {
                showEditProfile = true
            }
            .font(AppTypography.caption1Medium)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(AppColors.primaryDark)
            .foregroundColor(AppColors.white)
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppSpacing.xxl)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: AppSpacing.sm) {
            statItem(value: viewModel.totalEventsText, label: "Events")
            statItem(value: viewModel.contributedText, label: "Contributed")
            statItem(value: viewModel.giftsText, label: "Gifts")
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: AppSpacing.xxs) {
            Text(value)
                .font(AppTypography.title2)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.primaryText)
            Text(label)
                .font(AppTypography.caption1)
                .foregroundStyle(AppColors.secondaryGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
        .softShadow()
    }

    // MARK: - Menu Section

    private var menuSection: some View {
        VStack(spacing: 0) {
            menuRow(icon: "gift", title: "Contribution history", destination: AnyView(ContributionHistoryView()))
            Divider().padding(.leading, 64)
            menuRow(icon: "calendar", title: "Event history", destination: AnyView(PostEventRecapView()))
            Divider().padding(.leading, 64)
            menuRow(icon: "heart", title: "Saved & wishlist", destination: AnyView(SavedWishlistView()))
            Divider().padding(.leading, 64)
            menuRow(icon: "sparkles", title: "AI personalization", destination: AnyView(AIRecommendationsView()))
            Divider().padding(.leading, 64)
            
            // Log Out Button
            Button {
                Task {
                    await AppState.shared.signOut()
                }
            } label: {
                HStack(spacing: AppSpacing.md) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 16))
                        .foregroundStyle(AppColors.accentRed)
                        .frame(width: 40, height: 40)
                        .background(AppColors.accentRed.opacity(0.1))
                        .clipShape(Circle())

                    Text("Log Out")
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.accentRed)

                    Spacer()
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)
            }
            .buttonStyle(.plain)
        }
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl, style: .continuous))
        .softShadow()
        .padding(.horizontal, AppSpacing.screenHorizontal)
    }

    private func menuRow(icon: String, title: String, destination: AnyView) -> some View {
        NavigationLink(destination: destination) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(AppColors.primaryDark)
                    .frame(width: 40, height: 40)
                    .background(AppColors.backgroundGray.opacity(0.8))
                    .clipShape(Circle())

                Text(title)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.secondaryGray.opacity(0.3))
            }
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.md)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Profile") {
    ProfileView()
}
