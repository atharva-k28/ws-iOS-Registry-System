//
//  AIService.swift
//  iOS_Registry_System
//
//  AI recommendation & smart features service
//

import Foundation
import Functions
import Supabase

// MARK: - AI Service

@MainActor
final class AIService {

    // MARK: Singleton

    static let shared = AIService()
    private init() {}

    // MARK: - Gift Recommendations

    /// Get AI-powered gift recommendations for an event
    func getRecommendations(for eventType: String, budget: Double? = nil) async throws -> [Product] {
        // TODO: Implement AI recommendation engine (OpenAI / custom ML)
        print("🤖 AIService: getRecommendations — not yet implemented")
        return []
    }

    /// Get personalized recommendations based on user preferences
    func getPersonalizedRecommendations(userID: UUID) async throws -> [Product] {
        // TODO: Implement personalized AI recommendations
        print("🤖 AIService: getPersonalizedRecommendations — not yet implemented")
        return []
    }

    // MARK: - Smart Features

    /// Generate a smart registry based on event type and preferences
    func generateSmartRegistry(eventType: String, preferences: [String]) async throws -> [Product] {
        struct RequestBody: Encodable {
            let eventType: String
            let preferences: [String]
        }
        
        struct ResponseData: Codable {
            let productIds: [UUID]
            enum CodingKeys: String, CodingKey {
                case productIds = "product_ids"
            }
        }
        
        let responseData: ResponseData = try await SupabaseManager.shared.client.functions.invoke(
            "generate-smart-registry",
            options: FunctionInvokeOptions(
                body: RequestBody(eventType: eventType, preferences: preferences)
            )
        )
        
        return try await ProductService.shared.fetchProducts(ids: responseData.productIds)
    }

    /// Get similar products based on a target product using the similar-products Edge Function
    func fetchSimilarProducts(targetProductId: UUID, targetProductName: String, targetCategory: String) async -> [Product] {
        struct RequestBody: Encodable {
            let targetProductId: String
            let targetProductName: String
            let targetCategory: String
        }
        
        struct ResponseData: Codable {
            let productIds: [UUID]
            enum CodingKeys: String, CodingKey {
                case productIds = "product_ids"
            }
        }
        
        do {
            let responseData: ResponseData = try await SupabaseManager.shared.client.functions.invoke(
                "similar-products",
                options: FunctionInvokeOptions(
                    body: RequestBody(
                        targetProductId: targetProductId.uuidString.lowercased(),
                        targetProductName: targetProductName,
                        targetCategory: targetCategory
                    )
                )
            )
            return try await ProductService.shared.fetchProducts(ids: responseData.productIds)
        } catch {
            print("⚠️ AIService: fetchSimilarProducts failed: \(error). Falling back to category products.")
            do {
                let categoryProducts = try await ProductService.shared.fetchProducts(category: targetCategory)
                return categoryProducts.filter { $0.id != targetProductId }
            } catch {
                print("❌ AIService: Fallback also failed: \(error)")
                return []
            }
        }
    }

    // MARK: - Registry Health Analyzer
    
    struct RegistryHealthResult: Codable, Identifiable {
        var id: UUID { UUID() }
        let score: Int
        let strengths: [String]
        let weaknesses: [String]
        let suggestions: [String]
    }
    
    func analyzeRegistry(items: [PriorityGiftItem]) async -> RegistryHealthResult {
        struct ItemPayload: Encodable {
            let title: String
            let price: Double
            let category: String
        }
        struct RequestBody: Encodable {
            let registryItems: [ItemPayload]
        }
        
        let payloads = items.map { ItemPayload(title: $0.title, price: $0.goalAmount, category: $0.collectionLabel) }
        
        do {
            let result: RegistryHealthResult = try await SupabaseManager.shared.client.functions.invoke(
                "registry-health-analyzer",
                options: FunctionInvokeOptions(
                    body: RequestBody(registryItems: payloads)
                )
            )
            return result
        } catch {
            print("⚠️ AIService: analyzeRegistry failed: \(error). Using robust fallback analysis.")
            // Premium Fallback: Calculate direct metrics
            let totalVal = items.reduce(0) { $0 + $1.goalAmount }
            let count = items.count
            
            var strengths = ["Good collection of premium priority items."]
            var weaknesses = [String]()
            var suggestions = [String]()
            
            if count < 5 {
                weaknesses.append("Too few items in the registry.")
                suggestions.append("Add at least 5-10 items across different price ranges.")
            } else {
                strengths.append("Registry contains a diverse list of choices.")
            }
            
            let highPriceItems = items.filter { $0.goalAmount > 300 }
            if Double(highPriceItems.count) / Double(max(count, 1)) > 0.5 {
                weaknesses.append("High price bias: Too many items cost >$300.")
                suggestions.append("Add smaller gifts (under $50) for cost-conscious guests.")
            } else {
                strengths.append("Great distribution of budget-friendly and premium options!")
            }
            
            if weaknesses.isEmpty {
                weaknesses.append("No critical weaknesses found.")
            }
            if suggestions.isEmpty {
                suggestions.append("Consider adding dynamic group gifts for more flexibility.")
            }
            
            let score = max(100 - (weaknesses.count * 15), 50)
            
            return RegistryHealthResult(
                score: score,
                strengths: strengths,
                weaknesses: weaknesses,
                suggestions: suggestions
            )
        }
    }

    // MARK: - Gift Concierge
    
    struct GiftConciergeResponse: Codable {
        let recommendedProductId: UUID?
        let chatResponse: String
        
        enum CodingKeys: String, CodingKey {
            case recommendedProductId = "recommended_product_id"
            case chatResponse = "chat_response"
        }
    }
    
    func askConcierge(guestPrompt: String, registryItems: [RegistryItem], products: [UUID: Product]) async -> GiftConciergeResponse {
        struct ItemPayload: Encodable {
            let id: String
            let title: String
            let price: Double
            let category: String
        }
        
        struct RequestBody: Encodable {
            let guestPrompt: String
            let registryItems: [ItemPayload]
        }
        
        let payloads = registryItems.compactMap { item -> ItemPayload? in
            guard let productId = item.productId,
                  let product = products[productId] else {
                return nil
            }
            return ItemPayload(
                id: product.id.uuidString.lowercased(),
                title: product.name,
                price: product.price,
                category: product.category ?? "Gifts"
            )
        }
        
        do {
            let response: GiftConciergeResponse = try await SupabaseManager.shared.client.functions.invoke(
                "gift-chat-concierge",
                options: FunctionInvokeOptions(
                    body: RequestBody(guestPrompt: guestPrompt, registryItems: payloads)
                )
            )
            return response
        } catch {
            print("⚠️ AIService: askConcierge failed: \(error). Using premium fallback recommender.")
            // High-fidelity fallback logic
            let promptLower = guestPrompt.lowercased()
            
            // Filter products that are in our registry
            let availableProducts = payloads.compactMap { payload -> Product? in
                guard let uuid = UUID(uuidString: payload.id) else { return nil }
                return products[uuid]
            }
            
            guard !availableProducts.isEmpty else {
                return GiftConciergeResponse(
                    recommendedProductId: nil,
                    chatResponse: "I'd love to help you find a gift! It looks like there are no items in this registry yet. Please let me know if you need any general suggestions!"
                )
            }
            
            // Let's do a keyword-based matching fallback
            var bestProduct: Product = availableProducts.first!
            var reason = "This is a wonderful, highly-rated selection from their registry that makes a perfect gift."
            
            if promptLower.contains("cheap") || promptLower.contains("budget") || promptLower.contains("under 50") || promptLower.contains("under $50") {
                let cheapItems = availableProducts.sorted { $0.price < $1.price }
                bestProduct = cheapItems.first!
                reason = "Based on your budget, I highly recommend the \(bestProduct.name) for \(CurrencyFormatter.formatCompact(bestProduct.price)). It is a thoughtful, useful item that fits your price preference perfectly!"
            } else if promptLower.contains("kitchen") || promptLower.contains("cook") || promptLower.contains("chef") {
                if let kitchen = availableProducts.first(where: { ($0.category ?? "").lowercased().contains("kitchen") || ($0.category ?? "").lowercased().contains("cook") }) {
                    bestProduct = kitchen
                    reason = "For someone who loves spending time in the kitchen, the \(bestProduct.name) is an incredible choice! It's one of their featured culinary items."
                }
            } else if promptLower.contains("coffee") || promptLower.contains("morning") || promptLower.contains("espresso") {
                if let coffee = availableProducts.first(where: { $0.name.lowercased().contains("coffee") || $0.name.lowercased().contains("espresso") }) {
                    bestProduct = coffee
                    reason = "Since they enjoy great coffee, the \(bestProduct.name) is a premium addition to their morning routine that they will cherish every day."
                }
            } else if promptLower.contains("outdoor") || promptLower.contains("barbecue") || promptLower.contains("bbq") || promptLower.contains("summer") {
                if let outdoor = availableProducts.first(where: { ($0.category ?? "").lowercased().contains("outdoor") }) {
                    bestProduct = outdoor
                    reason = "If they enjoy hosting outdoors, the \(bestProduct.name) will be an absolute hit! It is perfect for summer barbecues."
                }
            } else {
                // Return the most premium or highly prioritised item
                let expensiveItems = availableProducts.sorted { $0.price > $1.price }
                bestProduct = expensiveItems.first!
                reason = "I highly recommend the \(bestProduct.name). It is a top-tier centerpiece of their registry that represents a major milestone contribution!"
            }
            
            return GiftConciergeResponse(
                recommendedProductId: bestProduct.id,
                chatResponse: reason
            )
        }
    }

    /// Get gift message suggestions
    func suggestGiftMessage(for productName: String, eventType: String) async throws -> String {
        // TODO: Implement AI message generation
        print("🤖 AIService: suggestGiftMessage — not yet implemented")
        return "Wishing you all the best! 🎁"
    }
}
