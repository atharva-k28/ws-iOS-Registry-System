//
//  AppState.swift
//  iOS_Registry_System
//
//  Global app state
//

import SwiftUI

// MARK: - App State

@MainActor
@Observable
final class AppState {

    // MARK: Singleton

    static let shared = AppState()

    // MARK: State

    var isAuthenticated = false
    var isLoading = true
    var selectedTab: AppConstants.Tab = .home
    var currentUser: User?

    // MARK: Init

    private init() {}

    // MARK: - Actions

    /// Check authentication state on launch
    func initialize() async {
        isLoading = true
        defer { isLoading = false }

        await AuthService.shared.restoreSession()
        isAuthenticated = AuthService.shared.isAuthenticated
        currentUser = AuthService.shared.currentUser

        // TODO: For development, skip auth and go straight to main app
        // Remove this line when auth is implemented
        isAuthenticated = true
    }

    /// Handle sign out
    func signOut() async {
        do {
            try await AuthService.shared.signOut()
            isAuthenticated = false
            currentUser = nil
            selectedTab = .home
        } catch {
            print("❌ Sign out failed: \(error.localizedDescription)")
        }
    }
}
