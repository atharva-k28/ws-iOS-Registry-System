//
//  AuthViewModel.swift
//  iOS_Registry_System
//
//  Auth view model
//

import SwiftUI

// MARK: - Auth View Model

@MainActor
@Observable
final class AuthViewModel {

    // MARK: State

    var email = ""
    var password = ""
    var displayName = ""
    var isLoading = false
    var errorMessage: String?
    var isAuthenticated = false

    // MARK: - Actions

    func signIn() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await AuthService.shared.signIn(email: email, password: password)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signUp() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await AuthService.shared.signUp(
                email: email,
                password: password,
                displayName: displayName
            )
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() async {
        do {
            try await AuthService.shared.signOut()
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func checkSession() async {
        await AuthService.shared.restoreSession()
        isAuthenticated = AuthService.shared.isAuthenticated
    }
}
