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
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(.regularMaterial)
                .environment(\.colorScheme, .light)
                .shadow(color: Color.black.opacity(0.08), radius: 12, y: 6)
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.8), lineWidth: 0.5)
                )
        )
        .padding(.horizontal, AppSpacing.lg)
        .padding(.bottom, AppSpacing.sm)
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
            VStack(spacing: 2) {
                Image(systemName: tab.icon)
                    .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.white : AppColors.primaryText)
                    .frame(width: 30, height: 30)
                    .background {
                        if isSelected {
                            Circle()
                                .fill(AppColors.accentRed)
                                .matchedGeometryEffect(id: "activeIcon", in: tabAnimation)
                        }
                    }
                    .symbolEffect(.bounce, value: isSelected)

                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .medium : .regular))
                    .foregroundStyle(isSelected ? AppColors.accentRed : AppColors.primaryText)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
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
