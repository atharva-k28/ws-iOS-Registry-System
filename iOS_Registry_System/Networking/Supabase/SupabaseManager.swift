//
//  SupabaseManager.swift
//  iOS_Registry_System
//
//  Supabase client singleton
//

import Foundation
import Supabase

// MARK: - Supabase Manager

@MainActor
final class SupabaseManager {

    // MARK: Singleton

    static let shared = SupabaseManager()

    // MARK: Client

    let client: SupabaseClient

    // MARK: Init

    private init() {
        client = SupabaseClient(
            supabaseURL: SupabaseConfig.url,
            supabaseKey: SupabaseConfig.anonKey
        )
    }

    // MARK: - Health Check

    /// Verify Supabase connection is working
    func healthCheck() async -> Bool {
        // TODO: Implement actual health check
        print("🔌 Supabase health check — not yet connected")
        return false
    }
}
