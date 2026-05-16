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

                    // MARK: Wallet
                    WalletCard(balance: 248.50)
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
            .overlay(alignment: .topTrailing) {
                Button(action: {}) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.primaryDark)
                        .frame(width: 44, height: 44)
                        .background(AppColors.white)
                        .clipShape(Circle())
                        .softShadow()
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
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
                    AsyncImage(url: URL(string: "https://i.pravatar.cc/300?img=5")) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .clipShape(Circle())
                }
                .overlay(
                    Circle().strokeBorder(AppColors.white, lineWidth: 4)
                )
                .softShadow()

            VStack(spacing: AppSpacing.xxxs) {
                Text(viewModel.user?.displayName ?? "Olivia Bennett")
                    .font(AppTypography.title2)
                    .foregroundStyle(AppColors.primaryText)

                Text("@olivia · Joined Mar 2026")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.secondaryGray)
            }

            // Action Chips
            HStack(spacing: AppSpacing.sm) {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12))
                    Text("Tastemaker")
                }
                .font(AppTypography.caption1Medium)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                .background(AppColors.backgroundGray)
                .foregroundColor(AppColors.primaryDark)
                .clipShape(Capsule())

                Button("Edit Profile") {
                    // Action
                }
                .font(AppTypography.caption1Medium)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                .background(AppColors.primaryDark)
                .foregroundColor(AppColors.white)
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppSpacing.xxl)
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: AppSpacing.sm) {
            statItem(value: "12", label: "Events")
            statItem(value: "$1.8k", label: "Contributed")
            statItem(value: "48", label: "Gifts")
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
            menuRow(icon: "gift", title: "Contribution history")
            Divider().padding(.leading, 64)
            menuRow(icon: "calendar", title: "Event history")
            Divider().padding(.leading, 64)
            menuRow(icon: "heart", title: "Saved & wishlist")
            Divider().padding(.leading, 64)
            menuRow(icon: "sparkles", title: "AI personalization")
        }
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl, style: .continuous))
        .softShadow()
        .padding(.horizontal, AppSpacing.screenHorizontal)
    }

    private func menuRow(icon: String, title: String) -> some View {
        Button {
            // TODO: Navigate to setting
        } label: {
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
