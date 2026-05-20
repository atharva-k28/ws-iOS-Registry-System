//
//  PostEventRecapViewModel.swift
//  iOS_Registry_System
//
//  ViewModel for Post-Event Recap View
//

import SwiftUI
import Supabase

@MainActor
@Observable
final class PostEventRecapViewModel {
    var isLoading = false
    var event: Event?
    
    var totalGifted: Double = 0
    var goalAmount: Double = 0
    var totalGifts: Int = 0
    var walletCredits: Double = 0
    
    var categories: [CategoryItem] = []
    var contributors: [ContributorItem] = []
    
    func loadRecapData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let events = try await EventService.shared.fetchMyEvents()
            guard let firstEvent = events.first else { return }
            self.event = firstEvent
            
            let registryId = try await EventService.shared.getOrCreateRegistryID(for: firstEvent.id)
            
            // Fetch registry items
            let itemsResponse = try await SupabaseManager.shared.client
                .from("registry_items")
                .select("id, price, funded_amount, quantity_needed, quantity_purchased")
                .eq("registry_id", value: registryId.uuidString)
                .execute()
            
            struct MinimalRegistryItem: Codable {
                let id: UUID
                let price: Double
                let funded_amount: Double?
                let quantity_needed: Int?
                let quantity_purchased: Int?
            }
            
            let items = try JSONDecoder().decode([MinimalRegistryItem].self, from: itemsResponse.data)
            
            var currentTotal: Double = 0
            var currentGoal: Double = 0
            var currentGifts: Int = 0
            
            for item in items {
                currentTotal += item.funded_amount ?? 0
                currentGoal += item.price * Double(item.quantity_needed ?? 1)
                currentGifts += item.quantity_purchased ?? 0
            }
            
            self.totalGifted = currentTotal
            self.goalAmount = currentGoal
            self.totalGifts = currentGifts
            
            // Wallet credits
            let creditsResponse = try await SupabaseManager.shared.client
                .from("wallet_credits")
                .select("amount")
                .eq("registry_id", value: registryId.uuidString)
                .eq("status", value: "available")
                .execute()
                
            struct CreditRow: Codable { let amount: Double }
            let credits = try? JSONDecoder().decode([CreditRow].self, from: creditsResponse.data)
            self.walletCredits = credits?.map(\.amount).reduce(0, +) ?? 0
            
            // Categories and contributors would require more complex joins.
            // For now, we fetch contributors from reservations -> contributions -> users
            let resResponse = try await SupabaseManager.shared.client
                .from("gift_reservations")
                .select("id")
                .in("registry_item_id", values: items.map { $0.id.uuidString })
                .execute()
                
            struct MinimalRes: Codable { let id: UUID }
            let resIds = try? JSONDecoder().decode([MinimalRes].self, from: resResponse.data).map { $0.id.uuidString }
            
            if let resIds = resIds, !resIds.isEmpty {
                let contribResponse = try await SupabaseManager.shared.client
                    .from("contributions")
                    .select("amount, contributor_by")
                    .in("reservation_id", values: resIds)
                    .execute()
                
                struct MinimalContrib: Codable {
                    let amount: Double
                    let contributor_by: UUID?
                }
                
                let contribs = try? JSONDecoder().decode([MinimalContrib].self, from: contribResponse.data)
                
                if let contribs = contribs {
                    // Group by user
                    var userAmounts: [UUID: Double] = [:]
                    for c in contribs {
                        if let uId = c.contributor_by {
                            userAmounts[uId, default: 0] += c.amount
                        }
                    }
                    
                    if !userAmounts.isEmpty {
                        let usersResponse = try await SupabaseManager.shared.client
                            .from("users")
                            .select("id, full_name, avatar_url")
                            .in("id", values: Array(userAmounts.keys).map { $0.uuidString })
                            .execute()
                            
                        struct MinimalUser: Codable {
                            let id: UUID
                            let full_name: String
                            let avatar_url: String?
                        }
                        
                        let users = try? JSONDecoder().decode([MinimalUser].self, from: usersResponse.data)
                        
                        if let users = users {
                            var parsedContributors: [ContributorItem] = []
                            for user in users {
                                let amt = userAmounts[user.id] ?? 0
                                parsedContributors.append(
                                    ContributorItem(
                                        name: user.full_name.isEmpty ? "Guest" : user.full_name,
                                        amount: CurrencyFormatter.format(amt),
                                        avatarUrl: user.avatar_url ?? ""
                                    )
                                )
                            }
                            self.contributors = parsedContributors.sorted { $0.amount > $1.amount }
                        }
                    }
                }
            }
            
            // Dummy categories for now, but dynamically calculated if we fetch products
            // Since MinimalRegistryItem doesn't have category, we mock or fetch products
            self.categories = [] // Update to fetch actual categories if needed
            
        } catch {
            print("Error loading recap: \(error)")
        }
    }
}
