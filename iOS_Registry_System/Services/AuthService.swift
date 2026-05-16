//
//  AuthService.swift
//  iOS_Registry_System
//
//  Authentication service
//

import Foundation

// MARK: - Auth Service

@MainActor
final class AuthService {

    // MARK: Singleton

    static let shared = AuthService()
    private init() {}

    // MARK: State

    /// Currently authenticated user
    private(set) var currentUser: User?

    /// Whether the user is authenticated
    var isAuthenticated: Bool { currentUser != nil }

    // MARK: - Methods

    /// Sign in with email and password
    func signIn(email: String, password: String) async throws {
        // TODO: Implement Supabase auth sign in
        // let session = try await SupabaseManager.shared.client.auth.signIn(
        //     email: email,
        //     password: password
        // )
        print("🔐 Auth: signIn called — not yet implemented")
    }

    /// Sign up with email and password
    func signUp(email: String, password: String, displayName: String) async throws {
        // TODO: Implement Supabase auth sign up
        print("🔐 Auth: signUp called — not yet implemented")
    }

    /// Sign out current user
    func signOut() async throws {
        // TODO: Implement Supabase auth sign out
        currentUser = nil
        print("🔐 Auth: signOut called — not yet implemented")
    }

    /// Check and restore existing session
    func restoreSession() async {
        // TODO: Implement session restoration
        print("🔐 Auth: restoreSession called — not yet implemented")
    }

    /// Sign in with Apple
    func signInWithApple() async throws {
        // TODO: Implement Sign in with Apple via Supabase
        print("🔐 Auth: signInWithApple called — not yet implemented")
    }
}
