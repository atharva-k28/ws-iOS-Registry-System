//
//  ProfileViewModel.swift
//  iOS_Registry_System
//
//  Profile screen view model
//

import SwiftUI

// MARK: - Profile View Model

@MainActor
@Observable
final class ProfileViewModel {

    // MARK: State

    var user: User?
    var totalContributions: Int = 0
    var eventsHosted: Int = 0
    var isLoading = false
    var errorMessage: String?

    // MARK: - Actions

    func loadProfile() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        // TODO: Fetch real user profile from Supabase
        user = User.mock
        totalContributions = 12
        eventsHosted = 3
    }

    func signOut() async {
        do {
            try await AuthService.shared.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
