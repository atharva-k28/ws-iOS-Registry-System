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
            
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: dateStr) {
                return date
            }
            
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: dateStr) {
                return date
            }
            
            // Fallback for date-only strings (e.g. "2026-05-17")
            let simpleFormatter = DateFormatter()
            simpleFormatter.dateFormat = "yyyy-MM-dd"
            if let date = simpleFormatter.date(from: dateStr) {
                return date
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
}
