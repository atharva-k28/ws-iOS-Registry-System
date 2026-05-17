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
    static let projectURL = "https://groxfqvymzoildwbrzvd.supabase.co"

    /// Supabase anonymous/public key
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdyb3hmcXZ5bXpvaWxkd2JyenZkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg4NjI4MDQsImV4cCI6MjA5NDQzODgwNH0.45Xi8PNlepAF0fp4hAedf1BO5zjJn65fDbEMMhOsoGM"

    /// Full URL object
    static var url: URL {
        guard let url = URL(string: projectURL) else {
            fatalError("Invalid Supabase URL: \(projectURL)")
        }
        return url
    }
}
