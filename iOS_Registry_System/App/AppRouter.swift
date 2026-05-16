//
//  AppRouter.swift
//  iOS_Registry_System
//
//  Root navigation — tab routing
//

import SwiftUI

// MARK: - App Router

struct AppRouter: View {

    @State private var appState = AppState.shared

    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: Tab Content

            Group {
                switch appState.selectedTab {
                case .home:
                    HomeView()
                case .events:
                    MyEventsView()
                case .friends:
                    FriendsView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // MARK: Floating Tab Bar

            MainTabBar(selectedTab: $appState.selectedTab)
        }
    }
}

// MARK: - Preview

#Preview("App Router") {
    AppRouter()
}
