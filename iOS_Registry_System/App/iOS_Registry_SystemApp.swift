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
                } else if appState.currentUser != nil && appState.mfaRequired {
                    // Auth flow - MFA required but signed in with password
                    // You might want to switch between enrollment or verification here based on factors
                    MFAVerificationView()
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
