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

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppSpacing.sectionGap) {

                    // MARK: Profile Header

                    profileHeader

                    // MARK: Stats Row

                    statsRow

                    // MARK: Menu Sections

                    menuSection

                    // MARK: Sign Out

                    PrimaryButton(title: "Sign Out", icon: "rectangle.portrait.and.arrow.right", style: .outline) {
                        Task { await viewModel.signOut() }
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
                await viewModel.loadProfile()
            }
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: AppSpacing.md) {
            // Avatar
            Circle()
                .fill(AppColors.primaryDark)
                .frame(width: 80, height: 80)
                .overlay {
                    Text(viewModel.user?.displayName.prefix(1).uppercased() ?? "?")
                        .font(AppTypography.title1)
                        .foregroundStyle(.white)
                }

            VStack(spacing: AppSpacing.xxs) {
                Text(viewModel.user?.displayName ?? "Your Name")
                    .font(AppTypography.title2)
                    .foregroundStyle(AppColors.primaryText)

                Text(viewModel.user?.email ?? "email@example.com")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.secondaryGray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(value: "\(viewModel.eventsHosted)", label: "Events")
            divider
            statItem(value: "\(viewModel.totalContributions)", label: "Contributions")
            divider
            statItem(value: "$2.4k", label: "Total Given")
        }
        .padding(AppSpacing.lg)
        .cardStyle()
        .padding(.horizontal, AppSpacing.screenHorizontal)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: AppSpacing.xxs) {
            Text(value)
                .font(AppTypography.title2)
                .foregroundStyle(AppColors.primaryText)
            Text(label)
                .font(AppTypography.caption1)
                .foregroundStyle(AppColors.secondaryGray)
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(AppColors.backgroundGray)
            .frame(width: 1, height: 40)
    }

    // MARK: - Menu Section

    private var menuSection: some View {
        VStack(spacing: AppSpacing.xxxs) {
            menuRow(icon: "person.fill", title: "Edit Profile")
            menuRow(icon: "bell.fill", title: "Notifications")
            menuRow(icon: "lock.fill", title: "Privacy")
            menuRow(icon: "questionmark.circle.fill", title: "Help & Support")
            menuRow(icon: "info.circle.fill", title: "About")
        }
        .cardStyle()
        .padding(.horizontal, AppSpacing.screenHorizontal)
    }

    private func menuRow(icon: String, title: String) -> some View {
        Button {
            // TODO: Navigate to setting
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(AppColors.secondaryGray)
                    .frame(width: 24)

                Text(title)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.primaryText)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppColors.secondaryGray.opacity(0.5))
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Profile") {
    ProfileView()
}
