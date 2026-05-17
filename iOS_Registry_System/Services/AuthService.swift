//
//  AuthService.swift
//  iOS_Registry_System
//
//  Authentication service
//

import Foundation
import Supabase

// MARK: - Auth Service

@MainActor
final class AuthService {

    // MARK: Singleton

    static let shared = AuthService()
    private init() {}

    // MARK: State

    /// Currently authenticated user
    private(set) var currentUser: User?

    /// MFA required flag
    private(set) var mfaRequired: Bool = false

    /// Whether the user is authenticated (AAL satisfied)
    var isAuthenticated: Bool { currentUser != nil && !mfaRequired }

    // MARK: - Methods

    /// Sign in with email and password
    func signIn(email: String, password: String) async throws {
        let _ = try await SupabaseManager.shared.client.auth.signIn(
            email: email,
            password: password
        )
        await fetchCurrentUser()
    }

    /// Sign up with email and password
    func signUp(email: String, password: String, displayName: String) async throws {
        let _ = try await SupabaseManager.shared.client.auth.signUp(
            email: email,
            password: password,
            data: [
                "name": .string(displayName),
                "role": .string("user")
            ]
        )
        // Note: The database trigger will automatically create the user profile
    }

    /// Sign out current user
    func signOut() async throws {
        try await SupabaseManager.shared.client.auth.signOut()
        currentUser = nil
    }
    //Users/sdc-user/Downloads/ws-iOS-Registry-System/iOS_Registry_System/Services/AuthService.swift
    /// Check and restore existing session
    func restoreSession() async {
        do {
            let _ = try await SupabaseManager.shared.client.auth.session
            try await checkMFAState()
            await fetchCurrentUser()
        } catch {
            print("No active session found: \(error)")
        }
    }

    /// Check MFA state
    func checkMFAState() async throws {
        let aal = try await SupabaseManager.shared.client.auth.mfa.getAuthenticatorAssuranceLevel()
        mfaRequired = (aal.nextLevel == "aal2" && aal.currentLevel == "aal1")
    }

    /// Fetch current user from public.users table
    func fetchCurrentUser() async {
        do {
            let session = try await SupabaseManager.shared.client.auth.session
            let response = try await SupabaseManager.shared.client
                .from("users")
                .select()
                .eq("id", value: session.user.id.uuidString)
                .single()
                .execute()
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateStr = try container.decode(String.self)
                
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                if let date = formatter.date(from: dateStr) {
                    return date
                }
                
                formatter.formatOptions = [.withInternetDateTime]
                if let date = formatter.date(from: dateStr) {
                    return date
                }
                
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateStr)")
            }
            currentUser = try decoder.decode(User.self, from: response.data)
            try await checkMFAState()
        } catch {
            print("Failed to fetch current user profile: \(error)")
        }
    }

    // MARK: - MFA Methods

    func enrollMFA() async throws -> (factorId: String, qrCode: String) {
        let factor = try await SupabaseManager.shared.client.auth.mfa.enroll(
            params: .totp(issuer: "iOS_Registry_System", friendlyName: "My Authenticator")
        )
        return (factor.id, factor.totp?.qrCode ?? "")
    }

    func challengeMFA(factorId: String) async throws -> String {
        let challenge = try await SupabaseManager.shared.client.auth.mfa.challenge(
            params: MFAChallengeParams(factorId: factorId)
        )
        return challenge.id
    }

    func verifyMFA(factorId: String, challengeId: String, code: String) async throws {
        let _ = try await SupabaseManager.shared.client.auth.mfa.verify(
            params: MFAVerifyParams(factorId: factorId, challengeId: challengeId, code: code)
        )
        // After successful verification, AAL is now AAL2
        mfaRequired = false
        await fetchCurrentUser()
    }

    /// Sign in with Apple
    func signInWithApple() async throws {
        // Implement Sign in with Apple via Supabase
        print("🔐 Auth: signInWithApple called — not fully implemented, requires UI flow")
    }
}
