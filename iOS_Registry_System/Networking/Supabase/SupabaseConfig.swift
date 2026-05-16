//
//  SupabaseConfig.swift
//  iOS_Registry_System
//
//  Supabase configuration
//

import Foundation

// MARK: - Supabase Config

enum SupabaseConfig {

    /// Supabase project URL
    /// TODO: Replace with your actual Supabase project URL
    static let projectURL = "https://your-project-id.supabase.co"

    /// Supabase anonymous/public key
    /// TODO: Replace with your actual Supabase anon key
    static let anonKey = "your-anon-key-here"

    /// Full URL object
    static var url: URL {
        guard let url = URL(string: projectURL) else {
            fatalError("Invalid Supabase URL: \(projectURL)")
        }
        return url
    }
}
