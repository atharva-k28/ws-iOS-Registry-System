//
//  FriendRegistryDetailViewModel.swift
//  iOS_Registry_System
//
//  ViewModel for the friend registry detail screen
//

import SwiftUI

// MARK: - Friend Registry Detail View Model

@MainActor
@Observable
final class FriendRegistryDetailViewModel {

    // MARK: State

    let event: Event
    var registryItems: [RegistryItem] = []
    var products: [UUID: Product] = [:]
    var isLoading = false
    var errorMessage: String?
    var selectedCategory: String? = nil
    var selectedItem: RegistryItem?
    var showCart = false
    var enabledGroupGiftingIds: Set<UUID> = []

    // MARK: Init

    init(event: Event) {
        self.event = event
    }

    // MARK: Actions

    func enableGroupGifting(for item: RegistryItem) {
        enabledGroupGiftingIds.insert(item.id)

        if let index = registryItems.firstIndex(where: { $0.id == item.id }) {
            // Trigger UI refresh / future backend sync hook
            registryItems[index].quantityNeeded = registryItems[index].quantityNeeded
        }
    }

    // MARK: Computed

    /// Unique product categories from loaded products
    var categories: [String] {
        let cats = Set(registryItems.compactMap { product(for: $0)?.category })
        return cats.isEmpty ? ["Kitchen"] : cats.sorted()
    }

    /// Price threshold for group gifting eligibility
    static let groupGiftingThreshold: Double = 300.0

    /// Whether a registry item qualifies for group gifting
    func isGroupGifting(for item: RegistryItem) -> Bool {
        if enabledGroupGiftingIds.contains(item.id) {
            return true
        }

        if item.isCashFund == true {
            return true
        }

        if let funded = item.fundedAmount, funded > 0 {
            return true
        }

        guard let product = product(for: item) else {
            return false
        }

        return product.price >= Self.groupGiftingThreshold
    }

    /// Registry items for 'Complete the set' section (priority 1 active items)
    var completeTheSetItems: [RegistryItem] {
        registryItems.filter { item in
            let isCompleted = isItemCompleted(item)
            return !isCompleted && item.priority == "1"
        }.sorted { Int($0.priority ?? "0") ?? 0 < Int($1.priority ?? "0") ?? 0 }
    }

    /// Registry items for 'Other items' section (all other active items + completed items)
    var otherItems: [RegistryItem] {
        let ctsIds = Set(completeTheSetItems.map { $0.id })
        let remaining = registryItems.filter { !ctsIds.contains($0.id) }

        return remaining.sorted { lhs, rhs in
            let lhsCompleted = isItemCompleted(lhs)
            let rhsCompleted = isItemCompleted(rhs)

            if lhsCompleted != rhsCompleted {
                return !lhsCompleted
            }

            return Int(lhs.priority ?? "0") ?? 0 < Int(rhs.priority ?? "0") ?? 0
        }
    }

    /// Registry items filtered by selected category, with completed items sorted to the bottom
    var filteredItems: [RegistryItem] {
        let items: [RegistryItem]

        if let category = selectedCategory {
            items = registryItems.filter { item in
                guard let product = product(for: item) else {
                    return false
                }

                let pCat = product.category.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                let sCat = category.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                return pCat == sCat
            }
        } else {
            items = registryItems
        }

        // Active items first (by priority), then completed items last
        return items.sorted { lhs, rhs in
            let lhsCompleted = isItemCompleted(lhs)
            let rhsCompleted = isItemCompleted(rhs)

            if lhsCompleted != rhsCompleted {
                return !lhsCompleted
            }

            return Int(lhs.priority ?? "0") ?? 0 < Int(rhs.priority ?? "0") ?? 0
        }
    }

    /// Total number of items
    var totalItems: Int {
        registryItems.count
    }

    /// Number of items that are purchased or fully funded
    var claimedItems: Int {
        registryItems.filter {
            isItemCompleted($0)
        }.count
    }

    /// Overall funding percentage across all items
    var overallProgress: Double {
        let totalTarget = registryItems.reduce(0) {
            $0 + ($1.price * Double($1.quantityNeeded ?? 1))
        }

        let totalCurrent = registryItems.reduce(0) {
            $0 + ($1.fundedAmount ?? 0.0)
        }

        guard totalTarget > 0 else { return 0 }

        return min(totalCurrent / totalTarget, 1.0)
    }

    /// Total amount contributed
    var totalContributed: Double {
        registryItems.reduce(0) {
            $0 + ($1.fundedAmount ?? 0.0)
        }
    }

    func isItemCompleted(_ item: RegistryItem) -> Bool {
        let isGroup = isGroupGifting(for: item)
        if item.isCashFund == true || isGroup {
            let targetAmount = item.price * Double(item.quantityNeeded ?? 1)
            return (item.fundedAmount ?? 0.0) >= targetAmount || item.progress >= 1.0
        } else {
            return (item.quantityPurchased ?? 0) >= (item.quantityNeeded ?? 1)
        }
    }

    /// Look up the product for a registry item, synthesizing it if it is not in the database catalog products table
    func product(for item: RegistryItem) -> Product? {
        if let productId = item.productId, let product = products[productId] {
            return product
        }
        
        // Dynamically synthesize a Product from the registry item's cached columns
        return Product(
            id: item.productId ?? item.id,
            sku: item.sku,
            name: item.itemName,
            description: "A gorgeous registry gift item.",
            brand: "Gift Registry",
            category: "Kitchen", // default category so it satisfies filters
            subcategory: nil,
            price: item.price,
            salePrice: nil,
            originalPrice: nil,
            isSale: false,
            saleLabel: nil,
            isBestSeller: item.isBestSeller ?? false,
            isExclusive: false,
            isFreeShipping: item.isFreeShipping ?? false,
            isPickupAvailable: false,
            isInStore: false,
            imageUrl: item.imageUrl,
            productUrl: item.itemLink,
            isActive: true,
            isRegistryEligible: true,
            isGiftEligible: true,
            createdAt: item.createdAt
        )
    }

    // MARK: - Actions

    func loadRegistryData() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            // 1. Fetch registry items first
            let items = try await EventService.shared.fetchRegistryItems(eventID: event.id)
            
            self.registryItems = items.sorted {
                Int($0.priority ?? "0") ?? 0 < Int($1.priority ?? "0") ?? 0
            }
            
            // 2. Fetch corresponding products in the registry
            let productIds = items.compactMap { $0.productId }
            var productList: [Product] = []
            
            if !productIds.isEmpty {
                productList = try await ProductService.shared.fetchProducts(ids: productIds)
            }
            
            // 3. Supplement with featured products as fallback to make sure there are always items and categories
            if productList.isEmpty {
                if let featured = try? await ProductService.shared.fetchFeaturedProducts() {
                    productList = featured
                }
            }
            
            self.products = Dictionary(
                uniqueKeysWithValues: productList.map { ($0.id, $0) }
            )

        } catch {
            print("❌ Failed to load friend registry data: \(error)")
            self.errorMessage = error.localizedDescription
        }
    }
}
