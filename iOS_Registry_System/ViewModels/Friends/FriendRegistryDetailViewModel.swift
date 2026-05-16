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

    // MARK: Init

    init(event: Event) {
        self.event = event
    }

    // MARK: Actions

    func enableGroupGifting(for item: RegistryItem) {
        if let index = registryItems.firstIndex(where: { $0.id == item.id }) {
            // In a real app, this would call a service
            registryItems[index].targetAmount = registryItems[index].targetAmount // No-op for now but triggers UI update
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
        guard let product = products[item.productID] else { return false }
        return product.price >= Self.groupGiftingThreshold
    }

    /// Registry items for 'Complete the set' section (priority 1 active items)
    var completeTheSetItems: [RegistryItem] {
        registryItems.filter { item in
            let isCompleted = item.isPurchased || item.progress >= 1.0
            return !isCompleted && item.priority == 1
        }.sorted { $0.priority < $1.priority }
    }

    /// Registry items for 'Other items' section (all other active items + completed items)
    var otherItems: [RegistryItem] {
        let ctsIds = Set(completeTheSetItems.map { $0.id })
        let remaining = registryItems.filter { !ctsIds.contains($0.id) }
        
        return remaining.sorted { lhs, rhs in
            let lhsCompleted = lhs.isPurchased || lhs.progress >= 1.0
            let rhsCompleted = rhs.isPurchased || rhs.progress >= 1.0
            if lhsCompleted != rhsCompleted {
                return !lhsCompleted
            }
            return lhs.priority < rhs.priority
        }
    }

    /// Registry items filtered by selected category, with completed items sorted to the bottom
    var filteredItems: [RegistryItem] {
        let items: [RegistryItem]
        if let category = selectedCategory {
            items = registryItems.filter { item in
                guard let product = products[item.productID] else { return false }
                return product.category == category
            }
        } else {
            items = registryItems
        }

        // Active items first (by priority), then completed items last
        return items.sorted { lhs, rhs in
            let lhsCompleted = lhs.isPurchased || lhs.progress >= 1.0
            let rhsCompleted = rhs.isPurchased || rhs.progress >= 1.0
            if lhsCompleted != rhsCompleted {
                return !lhsCompleted
            }
            return lhs.priority < rhs.priority
        }
    }

    /// Total number of items
    var totalItems: Int { registryItems.count }

    /// Number of items that are purchased or fully funded
    var claimedItems: Int {
        registryItems.filter { $0.isPurchased || $0.progress >= 1.0 }.count
    }

    /// Overall funding percentage across all items
    var overallProgress: Double {
        let totalTarget = registryItems.reduce(0) { $0 + $1.targetAmount }
        let totalCurrent = registryItems.reduce(0) { $0 + $1.currentAmount }
        guard totalTarget > 0 else { return 0 }
        return min(totalCurrent / totalTarget, 1.0)
    }

    /// Total amount contributed
    var totalContributed: Double {
        registryItems.reduce(0) { $0 + $1.currentAmount }
    }

    // MARK: Helpers

    /// Look up the product for a registry item
    func product(for item: RegistryItem) -> Product? {
        products[item.productID]
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

            registryItems = items.sorted { $0.priority < $1.priority }
            products = Dictionary(uniqueKeysWithValues: productList.map { ($0.id, $0) })
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
