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

    // MARK: Init

    init(event: Event) {
        self.event = event
    }

    // MARK: Actions

    func enableGroupGifting(for item: RegistryItem) {
        if let index = registryItems.firstIndex(where: { $0.id == item.id }) {
            // In a real app, this would call a service
            registryItems[index].quantityNeeded = registryItems[index].quantityNeeded // No-op for now but triggers UI update
            // For the mock, we can simulate price >= threshold if needed, but the UI is driven by isGroupGifting helper
        }
    }

    // MARK: Computed

    /// Unique product categories from loaded products
    var categories: [String] {
        let cats = Set(products.values.compactMap { $0.category })
        return cats.sorted()
    }

    /// Price threshold for group gifting eligibility
    static let groupGiftingThreshold: Double = 300.0

    /// Whether a registry item qualifies for group gifting
    func isGroupGifting(for item: RegistryItem) -> Bool {
        guard let productId = item.productId, let product = products[productId] else { return false }
        return product.price >= Self.groupGiftingThreshold
    }

    /// Registry items for 'Complete the set' section (priority 1 active items)
    var completeTheSetItems: [RegistryItem] {
        registryItems.filter { item in
            let isCompleted = (item.fundedAmount ?? 0.0) >= (item.price * Double(item.quantityNeeded ?? 1)) || item.progress >= 1.0
            return !isCompleted && item.priority == "1"
        }.sorted { Int($0.priority ?? "0") ?? 0 < Int($1.priority ?? "0") ?? 0 }
    }

    /// Registry items for 'Other items' section (all other active items + completed items)
    var otherItems: [RegistryItem] {
        let ctsIds = Set(completeTheSetItems.map { $0.id })
        let remaining = registryItems.filter { !ctsIds.contains($0.id) }
        
        return remaining.sorted { lhs, rhs in
            let lhsCompleted = (lhs.fundedAmount ?? 0.0) >= (lhs.price * Double(lhs.quantityNeeded ?? 1)) || lhs.progress >= 1.0
            let rhsCompleted = (rhs.fundedAmount ?? 0.0) >= (rhs.price * Double(rhs.quantityNeeded ?? 1)) || rhs.progress >= 1.0
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
                guard let productId = item.productId, let product = products[productId] else { return false }
                return product.category == category
            }
        } else {
            items = registryItems
        }

        // Active items first (by priority), then completed items last
        return items.sorted { lhs, rhs in
            let lhsCompleted = (lhs.fundedAmount ?? 0.0) >= (lhs.price * Double(lhs.quantityNeeded ?? 1)) || lhs.progress >= 1.0
            let rhsCompleted = (rhs.fundedAmount ?? 0.0) >= (rhs.price * Double(rhs.quantityNeeded ?? 1)) || rhs.progress >= 1.0
            if lhsCompleted != rhsCompleted {
                return !lhsCompleted
            }
            return Int(lhs.priority ?? "0") ?? 0 < Int(rhs.priority ?? "0") ?? 0
        }
    }

    /// Total number of items
    var totalItems: Int { registryItems.count }

    /// Number of items that are purchased or fully funded
    var claimedItems: Int {
        registryItems.filter { ($0.fundedAmount ?? 0.0) >= ($0.price * Double($0.quantityNeeded ?? 1)) || $0.progress >= 1.0 }.count
    }

    /// Overall funding percentage across all items
    var overallProgress: Double {
        let totalTarget = registryItems.reduce(0) { $0 + ($1.price * Double($1.quantityNeeded ?? 1)) }
        let totalCurrent = registryItems.reduce(0) { $0 + ($1.fundedAmount ?? 0.0) }
        guard totalTarget > 0 else { return 0 }
        return min(totalCurrent / totalTarget, 1.0)
    }

    /// Total amount contributed
    var totalContributed: Double {
        registryItems.reduce(0) { $0 + ($1.fundedAmount ?? 0.0) }
    }

    // MARK: Helpers

    /// Look up the product for a registry item
    func product(for item: RegistryItem) -> Product? {
        guard let productId = item.productId else { return nil }
        return products[productId]
    }

    // MARK: - Actions

    func loadRegistryData() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let itemsTask = EventService.shared.fetchRegistryItems(eventID: event.id)
            async let productsTask = ProductService.shared.fetchFeaturedProducts()

            let (items, productList) = try await (itemsTask, productsTask)

            registryItems = items.sorted { Int($0.priority ?? "0") ?? 0 < Int($1.priority ?? "0") ?? 0 }
            products = Dictionary(uniqueKeysWithValues: productList.map { ($0.id, $0) })
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
