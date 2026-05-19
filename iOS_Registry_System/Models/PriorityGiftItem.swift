//
//  PriorityGiftItem.swift
//  iOS_Registry_System
//
//  Priority Gift item model — drives the Group Contribution flow
//

import Foundation

// MARK: - Contributor

struct Contributor: Identifiable, Hashable {
    let id: UUID
    let name: String
    let avatarURL: String?
    let amount: Double
    let timeAgo: String
    var itemName: String? = nil
    var date: Date? = nil
}

// MARK: - Priority Gift Item

struct PriorityGiftItem: Identifiable, Hashable {
    let id: UUID
    let title: String
    let collectionLabel: String        // e.g. "BARISTA SERIES"
    let currentAmount: Double
    let goalAmount: Double
    let imageSeed: String
    let galleryURLs: [String]          // multiple editorial images
    let isAIRecommended: Bool
    let contributors: [Contributor]

    var progress: Double { min(currentAmount / goalAmount, 1.0) }
    var percentFunded: Int { Int(progress * 100) }
    var amountToGo: Double { max(goalAmount - currentAmount, 0) }
    var contributorCount: Int { contributors.count }

    // MARK: - Curated image URL helpers

    func galleryURL(index: Int) -> String {
        guard !galleryURLs.isEmpty else {
            return "https://loremflickr.com/400/400/\(imageSeed)?lock=\(index)"
        }
        return galleryURLs[index % galleryURLs.count]
    }
}

// MARK: - Mock Data

extension PriorityGiftItem {
    static let mockContributors: [Contributor] = [
        Contributor(id: UUID(), name: "Maya",  avatarURL: "https://i.pravatar.cc/150?img=5",  amount: 50,  timeAgo: "2m ago"),
        Contributor(id: UUID(), name: "Liam",  avatarURL: "https://i.pravatar.cc/150?img=8",  amount: 25,  timeAgo: "12m ago"),
        Contributor(id: UUID(), name: "Sofia", avatarURL: "https://i.pravatar.cc/150?img=9",  amount: 100, timeAgo: "1h ago"),
        Contributor(id: UUID(), name: "Ethan", avatarURL: "https://i.pravatar.cc/150?img=11", amount: 75,  timeAgo: "3h ago"),
    ]

    static let espressoMachine = PriorityGiftItem(
        id: UUID(),
        title: "Espresso Machine",
        collectionLabel: "BARISTA SERIES",
        currentAmount: 420,
        goalAmount: 500,
        imageSeed: "espresso,coffee,kitchen",
        galleryURLs: [
            "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=600",
            "https://images.unsplash.com/photo-1501492673258-2af452b2a5b6?w=600",
            "https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=600"
        ],
        isAIRecommended: true,
        contributors: mockContributors
    )

    static let cookwareSet = PriorityGiftItem(
        id: UUID(),
        title: "Made In Cookware Set",
        collectionLabel: "KITCHEN ESSENTIALS",
        currentAmount: 320,
        goalAmount: 500,
        imageSeed: "cookware,pans,kitchen",
        galleryURLs: [
            "https://images.unsplash.com/photo-1590794056226-79ef3a8147e1?w=600",
            "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600",
            "https://images.unsplash.com/photo-1585515320310-259814833e62?w=600"
        ],
        isAIRecommended: false,
        contributors: Array(mockContributors.prefix(3))
    )

    static let bbqBundle = PriorityGiftItem(
        id: UUID(),
        title: "Outdoor BBQ Bundle",
        collectionLabel: "OUTDOOR LIVING",
        currentAmount: 95,
        goalAmount: 280,
        imageSeed: "bbq,grilling,outdoor",
        galleryURLs: [
            "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=600",
            "https://images.unsplash.com/photo-1529193591184-b1d58069ecdd?w=600"
        ],
        isAIRecommended: false,
        contributors: Array(mockContributors.prefix(2))
    )

    static let allMock: [PriorityGiftItem] = [cookwareSet, bbqBundle, espressoMachine]
}
