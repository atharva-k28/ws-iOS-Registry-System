//
//  SupabaseManager.swift
//  iOS_Registry_System
//
//  Supabase client singleton
//

import Foundation
// TODO: Uncomment after adding Supabase SPM package
// import Supabase

// MARK: - Supabase Manager

@MainActor
final class SupabaseManager {

    // MARK: Singleton

    static let shared = SupabaseManager()

    // MARK: Client

    // TODO: Uncomment after adding Supabase SPM package
    // let client: SupabaseClient

    // MARK: Init

    private init() {
        // TODO: Initialize Supabase client
        // client = SupabaseClient(
        //     supabaseURL: SupabaseConfig.url,
        //     supabaseKey: SupabaseConfig.anonKey
        // )
    }

    // MARK: - Health Check

    /// Verify Supabase connection is working
    func healthCheck() async -> Bool {
        // TODO: Implement actual health check
        print("🔌 Supabase health check — not yet connected")
        return false
    }
}
