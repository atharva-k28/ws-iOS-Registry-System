//
//  MainTabBar.swift
//  iOS_Registry_System
//
//  Floating premium tab bar
//

import SwiftUI

// MARK: - Main Tab Bar

struct MainTabBar: View {

    @Binding var selectedTab: AppConstants.Tab

    // Animation namespace
    @Namespace private var tabAnimation

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppConstants.Tab.allCases, id: \.rawValue) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, AppSpacing.xs)
        .padding(.vertical, AppSpacing.xs)
        .background(
            Capsule()
                .fill(AppColors.white)
        )
        .floatingShadow()
        .padding(.horizontal, AppSpacing.xl)
        .padding(.bottom, AppSpacing.xs)
    }

    // MARK: - Tab Button

    @ViewBuilder
    private func tabButton(for tab: AppConstants.Tab) -> some View {
        let isSelected = selectedTab == tab

        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                    .symbolEffect(.bounce, value: isSelected)

                if isSelected {
                    Text(tab.title)
                        .font(AppTypography.caption1Medium)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, isSelected ? AppSpacing.md : AppSpacing.sm)
            .frame(height: 48)
            .foregroundStyle(isSelected ? AppColors.white : AppColors.secondaryGray)
            .background {
                if isSelected {
                    Capsule()
                        .fill(AppColors.primaryDark)
                        .matchedGeometryEffect(id: "activeTab", in: tabAnimation)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Tab Bar") {
    struct PreviewWrapper: View {
        @State var tab: AppConstants.Tab = .home
        var body: some View {
            ZStack(alignment: .bottom) {
                AppColors.background.ignoresSafeArea()

                Text("Selected: \(tab.title)")
                    .font(AppTypography.title2)
                    .frame(maxHeight: .infinity)

                MainTabBar(selectedTab: $tab)
            }
        }
    }
    return PreviewWrapper()
}
