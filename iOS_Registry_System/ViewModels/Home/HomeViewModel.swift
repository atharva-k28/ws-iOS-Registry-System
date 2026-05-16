//
//  HomeViewModel.swift
//  iOS_Registry_System
//
//  Home screen view model
//

import SwiftUI

// MARK: - Home View Model

@MainActor
@Observable
final class HomeViewModel {

    // MARK: State

    var featuredEvents: [Event] = []
    var recommendedProducts: [Product] = []
    var isLoading = false
    var errorMessage: String?
    var greeting: String = "Good Morning"

    // MARK: - Actions

    func loadHomeData() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        updateGreeting()

        do {
            async let events = EventService.shared.fetchFriendEvents()
            async let products = AIService.shared.getRecommendations(for: "general")

            featuredEvents = try await events
            recommendedProducts = try await products
        } catch {
            errorMessage = error.localizedDescription
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
}
