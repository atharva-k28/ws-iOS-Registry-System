////
////  MainTabBar.swift
////  iOS_Registry_System
////
////  Native iOS Floating Tab Bar
////
//
//import SwiftUI
//
//struct MainTabBar: View {
//
//    @Binding var selectedTab: AppConstants.Tab
//
//    @Namespace private var tabAnimation
//
//    var body: some View {
//
//        HStack(spacing: 0) {
//
//            ForEach(AppConstants.Tab.allCases, id: \.rawValue) { tab in
//                tabButton(for: tab)
//            }
//        }
//        .padding(.horizontal, 6)
//        .padding(.vertical, 6)
//        .background(
//            Capsule()
//                .fill(Color.white.opacity(0.94))
//                .shadow(
//                    color: .black.opacity(0.06),
//                    radius: 12,
//                    y: 4
//                )
//                .overlay(
//                    Capsule()
//                        .stroke(
//                            Color.white.opacity(0.7),
//                            lineWidth: 0.5
//                        )
//                )
//        )
//        .padding(.horizontal, 18)
//        .padding(.bottom, 8)
//    }
//
//    // MARK: - Tab Button
//
//    @ViewBuilder
//    private func tabButton(for tab: AppConstants.Tab) -> some View {
//
//        let isSelected = selectedTab == tab
//
//        Button {
//
//            withAnimation(.easeInOut(duration: 0.22)) {
//                selectedTab = tab
//            }
//
//        } label: {
//
//            VStack(spacing: 3) {
//
//                Image(systemName: tab.icon)
//                    .font(
//                        .system(
//                            size: 17,
//                            weight: .medium
//                        )
//                    )
//
//                Text(tab.title)
//                    .font(
//                        .system(
//                            size: 11,
//                            weight: isSelected ? .semibold : .medium
//                        )
//                    )
//            }
//            .foregroundStyle(
//                isSelected
//                ? Color(red: 0.96, green: 0.38, blue: 0.55)
//                : Color.black.opacity(0.82)
//            )
//            .frame(maxWidth: .infinity)
//            .padding(.vertical, 10)
//            .background {
//
//                if isSelected {
//
//                    RoundedRectangle(cornerRadius: 28)
//                        .fill(Color.black.opacity(0.06))
//                        .matchedGeometryEffect(
//                            id: "ACTIVE_TAB",
//                            in: tabAnimation
//                        )
//                        .padding(.vertical, 2)
//                }
//            }
//        }
//        .buttonStyle(.plain)
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//
//    struct PreviewWrapper: View {
//
//        @State var tab: AppConstants.Tab = .home
//
//        var body: some View {
//
//            ZStack(alignment: .bottom) {
//
//                Color(.systemGroupedBackground)
//                    .ignoresSafeArea()
//
//                MainTabBar(selectedTab: $tab)
//            }
//        }
//    }
//
//    return PreviewWrapper()
//}
//
//
//
//


//
//  MainTabBar.swift
//  iOS_Registry_System
//
//  Native iOS Floating Tab Bar
//

import SwiftUI

struct MainTabBar: View {

    @Binding var selectedTab: AppConstants.Tab

    @Namespace private var tabAnimation

    var body: some View {

        HStack(spacing: 0) {

            ForEach(AppConstants.Tab.allCases, id: \.rawValue) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.94))
                .shadow(
                    color: .black.opacity(0.06),
                    radius: 12,
                    y: 4
                )
                .overlay(
                    Capsule()
                        .stroke(
                            Color.white.opacity(0.7),
                            lineWidth: 0.5
                        )
                )
        )
        .padding(.horizontal, 18)
        .padding(.bottom, 0)
    }

    // MARK: - Tab Button

    @ViewBuilder
    private func tabButton(for tab: AppConstants.Tab) -> some View {

        let isSelected = selectedTab == tab

        Button {

            withAnimation(.easeInOut(duration: 0.22)) {
                selectedTab = tab
            }

        } label: {

            VStack(spacing: 3) {

                Image(systemName: tab.icon)
                    .font(
                        .system(
                            size: 22,
                            weight: .medium
                        )
                    )

                Text(tab.title)
                    .font(
                        .system(
                            size: 9,
                            weight: isSelected ? .semibold : .medium
                        )
                    )
            }
            .foregroundStyle(
                isSelected
                ? Color(red: 0.96, green: 0.38, blue: 0.55)
                : Color.black.opacity(0.82)
            )
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background {

                if isSelected {

                    RoundedRectangle(cornerRadius: 26)
                        .fill(Color.black.opacity(0.06))
                        .matchedGeometryEffect(
                            id: "ACTIVE_TAB",
                            in: tabAnimation
                        )
                        .padding(.vertical, 2)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {

    struct PreviewWrapper: View {

        @State var tab: AppConstants.Tab = .home

        var body: some View {

            ZStack(alignment: .bottom) {

                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                MainTabBar(selectedTab: $tab)
            }
        }
    }

    return PreviewWrapper()
}
