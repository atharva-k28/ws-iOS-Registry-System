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
            RoundedRectangle(cornerRadius: AppCornerRadius.full, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.full, style: .continuous)
                        .strokeBorder(.white.opacity(0.3), lineWidth: 0.5)
                )
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
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                    .symbolEffect(.bounce, value: isSelected)

                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
            }
            .foregroundStyle(isSelected ? .white : AppColors.secondaryGray)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: AppCornerRadius.md, style: .continuous)
                        .fill(AppColors.primaryDark)
                        .matchedGeometryEffect(id: "activeTab", in: tabAnimation)
                }
            }
        }
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
