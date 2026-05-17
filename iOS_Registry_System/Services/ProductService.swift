//
//  ProductService.swift
//  iOS_Registry_System
//
//  Product catalog & search service
//

import Foundation
import Supabase

// MARK: - Product Service

@MainActor
final class ProductService {

    // MARK: Singleton

    static let shared = ProductService()
    private init() {}

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            // 1. Try ISO8601DateFormatter
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: dateStr) {
                return date
            }
            
            isoFormatter.formatOptions = [.withInternetDateTime]
            if let date = isoFormatter.date(from: dateStr) {
                return date
            }
            
            // 2. Try DateFormatter with fallback formats
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            
            let formats = [
                "yyyy-MM-dd HH:mm:ss.SSSX",
                "yyyy-MM-dd HH:mm:ss.SSSZZZZZ",
                "yyyy-MM-dd HH:mm:ss.SSSZ",
                "yyyy-MM-dd HH:mm:ss.SSSSSSX",
                "yyyy-MM-dd HH:mm:ss.SSSSSSZZZZZ",
                "yyyy-MM-dd HH:mm:ss.SSSSSSZ",
                "yyyy-MM-dd HH:mm:ssX",
                "yyyy-MM-dd HH:mm:ssZZZZZ",
                "yyyy-MM-dd HH:mm:ssZ",
                "yyyy-MM-dd'T'HH:mm:ss.SSSX",
                "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ",
                "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSX",
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ",
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ",
                "yyyy-MM-dd'T'HH:mm:ssX",
                "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
                "yyyy-MM-dd'T'HH:mm:ssZ",
                "yyyy-MM-dd"
            ]
            
            for format in formats {
                formatter.dateFormat = format
                if let date = formatter.date(from: dateStr) {
                    return date
                }
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateStr)")
        }
        return decoder
    }

    // MARK: - Methods

    /// Fetch trending/featured products
    func fetchFeaturedProducts() async throws -> [Product] {
        let response = try await SupabaseManager.shared.client
            .from("products")
            .select()
            .eq("is_active", value: true)
            .eq("is_best_seller", value: true)
            .limit(20)
            .execute()
        return try decoder.decode([Product].self, from: response.data)
    }

    /// Search products by query
    func searchProducts(query: String) async throws -> [Product] {
        let response = try await SupabaseManager.shared.client
            .from("products")
            .select()
            .ilike("name", value: "%\(query)%")
            .eq("is_active", value: true)
            .limit(50)
            .execute()
        return try decoder.decode([Product].self, from: response.data)
    }

    /// Fetch product details by ID
    func fetchProduct(id: UUID) async throws -> Product? {
        let response = try await SupabaseManager.shared.client
            .from("products")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
        return try decoder.decode(Product.self, from: response.data)
    }

    /// Fetch products by category
    func fetchProducts(category: String) async throws -> [Product] {
        let response = try await SupabaseManager.shared.client
            .from("products")
            .select()
            .eq("category", value: category)
            .eq("is_active", value: true)
            .execute()
        return try decoder.decode([Product].self, from: response.data)
    }

    /// Fetch products by a list of IDs
    func fetchProducts(ids: [UUID]) async throws -> [Product] {
        let idStrings = ids.map { $0.uuidString }
        let response = try await SupabaseManager.shared.client
            .from("products")
            .select()
            .in("id", values: idStrings)
            .execute()
        return try decoder.decode([Product].self, from: response.data)
    }

    /// Fetch all products for building registry
    func fetchAllProducts() async throws -> [Product] {
        let response = try await SupabaseManager.shared.client
            .from("products")
            .select()
            .eq("is_active", value: true)
            .limit(100)
            .execute()
        return try decoder.decode([Product].self, from: response.data)
    }
}
