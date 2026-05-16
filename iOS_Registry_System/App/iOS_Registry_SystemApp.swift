//
//  iOS_Registry_SystemApp.swift
//  iOS_Registry_System
//
//  App entry point
//

import SwiftUI

@main
struct iOS_Registry_SystemApp: App {

    @State private var appState = AppState.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isLoading {
                    // Splash / Loading
                    LoadingView(message: "Setting things up...")
                } else if appState.isAuthenticated {
                    // Main app
                    AppRouter()
                } else {
                    // Auth flow
                    AuthLandingView()
                }
            }
            .task {
                await appState.initialize()
            }
        }
    }
}
