//
//  HomeViewModel.swift
//  iOS_Registry_System
//
//  Home screen view model
//

import Supabase
import SwiftUI

// MARK: - Home View Model

struct HomeRegistryProgress: Hashable {
    let eventTitle: String
    let eventType: String
    let progress: Double
    let itemsClaimed: Int
    let totalItems: Int
    let contributors: Int
}

private struct HomeRegistryContext {
    let event: Event
    let registry: Registry
}

@MainActor
@Observable
final class HomeViewModel {

    // MARK: State

    var featuredEvents: [Event] = []
    var recommendedProducts: [Product] = []
    var notifications: [Notification] = []
    var searchQuery = ""
    var searchResults: [Product] = []
    var aiBundleProducts: [Product] = []
    var aiCuratedContextTitle: String?
    var aiCuratedContextDescription: String?
    var registryProgress: HomeRegistryProgress?
    var isLoading = false
    var isLoadingNotifications = false
    var isSearching = false
    var isLoadingAIBundle = false
    var errorMessage: String?
    var greeting: String = "Good Morning"

    var shouldShowAICuratedCard: Bool {
        aiCuratedContextTitle != nil && !aiBundleProducts.isEmpty
    }

    var aiBundleTitle: String {
        aiCuratedContextTitle ?? ""
    }

    var aiBundleDescription: String {
        aiCuratedContextDescription ?? ""
    }

    var collectionProducts: [Product] {
        Array(recommendedProducts.prefix(4))
    }

    var moreToExploreProducts: [Product] {
        Array(recommendedProducts.dropFirst(4).prefix(4))
    }

    var unreadNotificationCount: Int {
        notifications.filter { $0.isRead != true }.count
    }

    // MARK: - Actions

    func loadHomeData() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        updateGreeting()
        clearAICuratedContext()

        do {
            let aiContext = try await loadAICuratedContext()

            async let events = EventService.shared.fetchFriendEvents()
            async let products = fetchHomeProducts()
            async let progress = fetchActiveRegistryProgress()
            async let notificationRows = fetchNotifications()

            featuredEvents = try await events
            recommendedProducts = try await products
            registryProgress = try await progress
            notifications = try await notificationRows

            if aiContext != nil {
                await refreshAICuratedBundle()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshAICuratedBundle() async {
        guard !isLoadingAIBundle else { return }

        isLoadingAIBundle = true
        defer { isLoadingAIBundle = false }

        do {
            aiBundleProducts = try await fetchAICuratedBundle()
        } catch {
            errorMessage = error.localizedDescription
            aiBundleProducts = []
        }
    }

    func loadNotifications() async {
        isLoadingNotifications = true
        defer { isLoadingNotifications = false }

        do {
            notifications = try await fetchNotifications()
        } catch {
            errorMessage = error.localizedDescription
            notifications = []
        }
    }

    func markNotificationsRead() async {
        guard let userId = AuthService.shared.currentUser?.id else { return }

        do {
            try await SupabaseManager.shared.client
                .from("notifications")
                .update(["is_read": true])
                .eq("user_id", value: userId.uuidString)
                .eq("is_read", value: false)
                .execute()

            notifications = notifications.map { notification in
                var updated = notification
                updated.isRead = true
                return updated
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func searchProducts() async {
        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            searchResults = []
            return
        }

        isSearching = true
        defer { isSearching = false }

        do {
            searchResults = try await ProductService.shared.searchProducts(query: trimmedQuery)
        } catch {
            errorMessage = error.localizedDescription
            searchResults = []
        }
    }

    // MARK: - Helpers

    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12:
            greeting = "Good Morning"
        case 12..<17:
            greeting = "Good Afternoon"
        case 17..<22:
            greeting = "Good Evening"
        default:
            greeting = "Good Night"
        }
    }

    private func fetchHomeProducts() async throws -> [Product] {
        let featured = try await ProductService.shared.fetchFeaturedProducts()
        if !featured.isEmpty {
            return featured
        }

        return try await ProductService.shared.fetchAllProducts()
    }

    private func fetchNotifications() async throws -> [Notification] {
        guard let userId = AuthService.shared.currentUser?.id else {
            return []
        }

        let response = try await SupabaseManager.shared.client
            .from("notifications")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .limit(50)
            .execute()

        return try decoder.decode([Notification].self, from: response.data)
    }

    private func clearAICuratedContext() {
        aiBundleProducts = []
        aiCuratedContextTitle = nil
        aiCuratedContextDescription = nil
    }

    private func loadAICuratedContext() async throws -> HomeRegistryContext? {
        guard let context = try await activeRegistryContext() else {
            clearAICuratedContext()
            return nil
        }

        aiCuratedContextTitle = context.registry.title.isEmpty ? context.event.title : context.registry.title
        aiCuratedContextDescription = context.event.eventType
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
        return context
    }

    private func fetchAICuratedBundle() async throws -> [Product] {
        guard let context = try await activeRegistryContext() else {
            clearAICuratedContext()
            return []
        }

        let event = context.event
        let registry = context.registry
        var preferences = [event.eventType, event.title]

        let registryItems = try await fetchRegistryItems(registryId: registry.id)
        let registryPreferences = registryItems
            .flatMap { [$0.itemName, $0.priority, $0.sku].compactMap { $0 } }
            .filter { !$0.isEmpty }

        preferences.append(contentsOf: registryPreferences)

        return try await AIService.shared.generateSmartRegistry(
            eventType: event.eventType,
            preferences: Array(Set(preferences)).sorted()
        )
    }

    private func fetchActiveRegistryProgress() async throws -> HomeRegistryProgress? {
        guard let event = try await activeUserEvent() else {
            return nil
        }

        guard let registry = try await fetchRegistry(for: event.id) else {
            return nil
        }

        let items = try await fetchRegistryItems(registryId: registry.id)
        let totalItems = items.reduce(0) { $0 + ($1.quantityNeeded ?? 1) }
        let itemsClaimed = items.reduce(0) { total, item in
            total + min(max(item.quantityReserved ?? 0, item.quantityPurchased ?? 0), item.quantityNeeded ?? 1)
        }
        let contributors = try await fetchContributorCount(registryItemIds: items.map(\.id))
        let progress = totalItems > 0 ? Double(itemsClaimed) / Double(totalItems) : 0

        return HomeRegistryProgress(
            eventTitle: registry.title.isEmpty ? event.title : registry.title,
            eventType: event.eventType,
            progress: min(max(progress, 0), 1),
            itemsClaimed: itemsClaimed,
            totalItems: totalItems,
            contributors: contributors
        )
    }

    private func activeUserEvent() async throws -> Event? {
        let events = try await EventService.shared.fetchMyEvents()
        return events.sorted(by: { lhs, rhs in
            (lhs.eventDate ?? lhs.startDate ?? lhs.createdAt ?? .distantFuture) <
            (rhs.eventDate ?? rhs.startDate ?? rhs.createdAt ?? .distantFuture)
        }).first
    }

    private func activeRegistryContext() async throws -> HomeRegistryContext? {
        guard let event = try await activeUserEvent(),
              let registry = try await fetchRegistry(for: event.id) else {
            return nil
        }

        return HomeRegistryContext(event: event, registry: registry)
    }

    private func fetchRegistry(for eventId: UUID) async throws -> Registry? {
        let response = try? await SupabaseManager.shared.client
            .from("registries")
            .select()
            .eq("event_id", value: eventId.uuidString)
            .single()
            .execute()

        guard let data = response?.data else {
            return nil
        }

        return try decoder.decode(Registry.self, from: data)
    }

    private func fetchRegistryItems(registryId: UUID) async throws -> [RegistryItem] {
        let response = try await SupabaseManager.shared.client
            .from("registry_items")
            .select()
            .eq("registry_id", value: registryId.uuidString)
            .execute()

        return try decoder.decode([RegistryItem].self, from: response.data)
    }

    private func fetchContributorCount(registryItemIds: [UUID]) async throws -> Int {
        guard !registryItemIds.isEmpty else {
            return 0
        }

        let reservationsResponse = try await SupabaseManager.shared.client
            .from("gift_reservations")
            .select("id,reserved_by")
            .in("registry_item_id", values: registryItemIds.map(\.uuidString))
            .execute()

        struct ReservationContributor: Codable {
            let id: UUID
            let reservedBy: UUID?

            enum CodingKeys: String, CodingKey {
                case id
                case reservedBy = "reserved_by"
            }
        }

        let reservations = try decoder.decode([ReservationContributor].self, from: reservationsResponse.data)
        var contributorIds = Set(reservations.compactMap(\.reservedBy))

        let reservationIds = reservations.map(\.id)
        if !reservationIds.isEmpty {
            let contributionsResponse = try await SupabaseManager.shared.client
                .from("contributions")
                .select("contributor_by")
                .in("reservation_id", values: reservationIds.map(\.uuidString))
                .execute()

            struct ContributionContributor: Codable {
                let contributorBy: UUID?

                enum CodingKeys: String, CodingKey {
                    case contributorBy = "contributor_by"
                }
            }

            let contributions = try decoder.decode([ContributionContributor].self, from: contributionsResponse.data)
            contributorIds.formUnion(contributions.compactMap(\.contributorBy))
        }

        return contributorIds.count
    }

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)

            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: dateStr) {
                return date
            }

            isoFormatter.formatOptions = [.withInternetDateTime]
            if let date = isoFormatter.date(from: dateStr) {
                return date
            }

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
}
