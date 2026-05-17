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
    var mfaRequired = false
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
        mfaRequired = AuthService.shared.mfaRequired
        currentUser = AuthService.shared.currentUser
    }

    /// Handle sign out
    func signOut() async {
        do {
            try await AuthService.shared.signOut()
            isAuthenticated = false
            mfaRequired = false
            currentUser = nil
            selectedTab = .home
        } catch {
            print("❌ Sign out failed: \(error.localizedDescription)")
        }
    }
}
