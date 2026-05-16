//
//  ProductService.swift
//  iOS_Registry_System
//
//  Product catalog & search service
//

import Foundation

// MARK: - Product Service

@MainActor
final class ProductService {

    // MARK: Singleton

    static let shared = ProductService()
    private init() {}

    // MARK: - Methods

    /// Fetch trending/featured products
    func fetchFeaturedProducts() async throws -> [Product] {
        // TODO: Implement Supabase query
        print("🛍️ ProductService: fetchFeaturedProducts — returning mock data")
        return Product.mockList
    }

    /// Search products by query
    func searchProducts(query: String) async throws -> [Product] {
        // TODO: Implement Supabase full-text search
        print("🛍️ ProductService: searchProducts(\(query)) — not yet implemented")
        return Product.mockList
    }

    /// Fetch product details by ID
    func fetchProduct(id: UUID) async throws -> Product? {
        // TODO: Implement Supabase query
        print("🛍️ ProductService: fetchProduct(\(id)) — not yet implemented")
        return Product.mock
    }

    /// Fetch products by category
    func fetchProducts(category: String) async throws -> [Product] {
        // TODO: Implement Supabase query with category filter
        print("🛍️ ProductService: fetchProducts(category: \(category)) — not yet implemented")
        return Product.mockList
    }
}
