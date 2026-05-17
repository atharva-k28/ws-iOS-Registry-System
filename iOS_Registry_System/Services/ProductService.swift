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
        return try JSONDecoder().decode([Product].self, from: response.data)
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
        return try JSONDecoder().decode([Product].self, from: response.data)
    }

    /// Fetch product details by ID
    func fetchProduct(id: UUID) async throws -> Product? {
        let response = try await SupabaseManager.shared.client
            .from("products")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
        return try JSONDecoder().decode(Product.self, from: response.data)
    }

    /// Fetch products by category
    func fetchProducts(category: String) async throws -> [Product] {
        let response = try await SupabaseManager.shared.client
            .from("products")
            .select()
            .eq("category", value: category)
            .eq("is_active", value: true)
            .execute()
        return try JSONDecoder().decode([Product].self, from: response.data)
    }
}
