//
//  AIRecommendationsView.swift
//  iOS_Registry_System
//
//  AI Smart Planner — "For You" recommendations screen.
//  Williams-Sonoma editorial aesthetic with functional filters,
//  working add-to-registry actions, and a product quick-add sheet.
//

import SwiftUI

// MARK: - Filter Category

enum AIRecommendationFilter: String, CaseIterable, Identifiable {
    case budget    = "Budget friendly"
    case luxury    = "Luxury"
    case seasonal  = "Seasonal"
    case bundle    = "Bundle"

    var id: String { rawValue }
}

// MARK: - Recommendation Item Model

struct AIRecommendationItem: Identifiable {
    let id        = UUID()
    let title:      String
    let subtitle:   String
    let price:      Int
    let imageUrl:   String
    let category:   AIRecommendationFilter
    let tags:       [String]

    // Williams-Sonoma catalogue
    static let all: [AIRecommendationItem] = [
        AIRecommendationItem(
            title: "Wooden Utensil Set",
            subtitle: "Pairs with cast iron",
            price: 68,
            imageUrl: "https://images.unsplash.com/photo-1556909211-36987daf7b4d?w=600&q=80",
            category: .budget,
            tags: ["Kitchen", "Everyday"]
        ),
        AIRecommendationItem(
            title: "Oven Mitt Set",
            subtitle: "Daily essential",
            price: 32,
            imageUrl: "https://images.unsplash.com/photo-1556909172-54557c7e4fb7?w=600&q=80",
            category: .budget,
            tags: ["Protection", "Essentials"]
        ),
        AIRecommendationItem(
            title: "Serving Bowl Set",
            subtitle: "For dinner parties",
            price: 112,
            imageUrl: "https://images.unsplash.com/photo-1603199505524-3e4cdaef1f6a?w=600&q=80",
            category: .bundle,
            tags: ["Entertaining", "Ceramic"]
        ),
        AIRecommendationItem(
            title: "Pasta Station",
            subtitle: "A weekend ritual",
            price: 248,
            imageUrl: "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600&q=80",
            category: .bundle,
            tags: ["Bundle", "Pasta"]
        ),
        AIRecommendationItem(
            title: "All-Clad Skillet",
            subtitle: "Restaurant-grade at home",
            price: 195,
            imageUrl: "https://images.unsplash.com/photo-1507048331197-7d4ac70811cf?w=600&q=80",
            category: .luxury,
            tags: ["Cookware", "Premium"]
        ),
        AIRecommendationItem(
            title: "Le Creuset Dutch Oven",
            subtitle: "Heritage craft, modern kitchen",
            price: 420,
            imageUrl: "https://images.unsplash.com/photo-1585837146751-a44117eb2ee4?w=600&q=80",
            category: .luxury,
            tags: ["Cast Iron", "Heirloom"]
        ),
        AIRecommendationItem(
            title: "Linen Napkin Set",
            subtitle: "Seasonal table setting",
            price: 54,
            imageUrl: "https://images.unsplash.com/photo-1528822855841-a4cb76a9b8b3?w=600&q=80",
            category: .seasonal,
            tags: ["Table", "Linen"]
        ),
        AIRecommendationItem(
            title: "Herb Garden Kit",
            subtitle: "Fresh flavours, year-round",
            price: 78,
            imageUrl: "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=600&q=80",
            category: .seasonal,
            tags: ["Garden", "Organic"]
        )
    ]
}

// MARK: - Quick-Add Sheet

private struct QuickAddSheet: View {
    let item:        AIRecommendationItem
    var onAdded:     () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var added = false

    var body: some View {
        VStack(spacing: 0) {

            // Drag indicator
            Capsule()
                .fill(Color.black.opacity(0.12))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, AppSpacing.md)

            // Product image
            AsyncImage(url: URL(string: item.imageUrl)) { img in
                img.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color(hex: "E8E2DC")
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
            .padding(.horizontal, AppSpacing.screenHorizontal)

            // Info
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(AppTypography.title3)
                            .foregroundStyle(AppColors.primaryText)
                        Text(item.subtitle)
                            .font(AppTypography.footnote)
                            .foregroundStyle(AppColors.secondaryGray)
                    }
                    Spacer()
                    Text("$\(item.price)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.primaryText)
                }

                // Tags
                HStack {
                    ForEach(item.tags, id: \.self) { tag in
                        Text(tag)
                            .font(AppTypography.caption1)
                            .foregroundStyle(AppColors.secondaryGray)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(AppColors.backgroundGray)
                            )
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.md)

            Spacer()

            // CTA
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    added = true
                }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    onAdded()
                    dismiss()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: added ? "checkmark" : "plus")
                        .font(.system(size: 15, weight: .semibold))
                    Text(added ? "Added to Registry" : "Add to Registry")
                        .font(AppTypography.buttonLarge)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(added ? Color(hex: "34C759") : AppColors.primaryText)
                .clipShape(Capsule())
                .animation(.spring(response: 0.3), value: added)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.bottom, 32)
        }
        .appBackground()
    }
}

// MARK: - AI Recommendations View

struct AIRecommendationsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFilter: AIRecommendationFilter = .budget
    @State private var addedItemIDs:  Set<UUID>               = []
    @State private var selectedItem:  AIRecommendationItem?   = nil
    @State private var showQuickAdd                           = false

    private var filteredItems: [AIRecommendationItem] {
        AIRecommendationItem.all.filter { $0.category == selectedFilter }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {

                    headerSection
                    inspiredByCard
                    quoteCard
                    youMightLoveSection

                    Color.clear.frame(height: 64)
                }
                .padding(.top, AppSpacing.lg)
                .padding(.horizontal, AppSpacing.screenHorizontal)
            }
            .appBackground()

            // Pinned bottom label
            Text("AI SMART PLANNER")
                .font(AppTypography.caption1Medium)
                .tracking(2)
                .foregroundStyle(AppColors.secondaryGray)
                .padding(.bottom, 8)
        }
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppColors.primaryText)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(AppColors.white)
                                .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
                        )
                }
                .buttonStyle(.plain)
            }
            ToolbarItem(placement: .principal) {
                Text("FOR YOU")
                    .font(AppTypography.caption1Medium)
                    .tracking(2)
                    .foregroundStyle(AppColors.secondaryGray)
            }
        }
        .sheet(item: $selectedItem) { item in
            QuickAddSheet(item: item) {
                addedItemIDs.insert(item.id)
            }
            .presentationDetents([.medium])
            .presentationCornerRadius(32)
            .presentationDragIndicator(.hidden)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("QUIETLY CURATED")
                .font(AppTypography.caption1Medium)
                .tracking(2)
                .foregroundStyle(AppColors.secondaryGray)

            Text("A few things that\nmight complete the set.")
                .font(.system(size: 32, weight: .regular, design: .serif))
                .foregroundStyle(AppColors.primaryText)
                .lineSpacing(3)

            Text("Suggestions shaped by your registry, the\nseason, and the way you love to host.")
                .font(AppTypography.body)
                .foregroundStyle(AppColors.secondaryGray)
                .lineSpacing(4)
        }
    }

    // MARK: - Inspired By Card

    private var inspiredByCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("INSPIRED BY")
                .font(AppTypography.caption1Medium)
                .tracking(1.5)
                .foregroundStyle(AppColors.secondaryGray)
                .padding(.horizontal, AppSpacing.md)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.sm)

            HStack(spacing: AppSpacing.md) {
                // Split image thumbnail
                AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1584990347449-a2d4e8c98b16?w=120&q=80")) { img in
                    img.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    HStack(spacing: 2) {
                        Color(hex: "3D4F3E").frame(width: 28, height: 52)
                        Color(hex: "212F3C").frame(width: 28, height: 52)
                    }
                }
                .frame(width: 56, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Made In Stainless Set")
                        .font(AppTypography.headline)
                        .foregroundStyle(AppColors.primaryText)
                    Text("Cookware · 5 piece")
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.secondaryGray)
                }

                Spacer()

                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColors.primaryText)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.bottom, AppSpacing.md)
        }
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
        .softShadow()
    }

    // MARK: - Quote Card

    private var quoteCard: some View {
        Text("\"Couples who chose this set often round it out with wooden utensils and a linen mitt — small things that make a cooking ritual feel whole.\"")
            .font(.system(size: 16, weight: .regular, design: .serif))
            .italic()
            .foregroundStyle(AppColors.primaryText)
            .lineSpacing(6)
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.white)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
            .softShadow()
    }

    // MARK: - You Might Love

    private var youMightLoveSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("YOU MIGHT LOVE")
                .font(AppTypography.caption1Medium)
                .tracking(2)
                .foregroundStyle(AppColors.primaryText)

            filtersSection

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: AppSpacing.md), GridItem(.flexible(), spacing: AppSpacing.md)],
                spacing: AppSpacing.md
            ) {
                ForEach(filteredItems) { item in
                    recommendationCard(item: item)
                        .onTapGesture {
                            selectedItem = item
                        }
                }
            }

            if filteredItems.isEmpty {
                Text("No items in this category yet.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryGray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.xl)
            }
        }
    }

    private func recommendationCard(item: AIRecommendationItem) -> some View {
        let isAdded = addedItemIDs.contains(item.id)

        return VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                AsyncImage(url: URL(string: item.imageUrl)) { img in
                    img.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    ZStack {
                        Color(hex: "EDE8E3")
                        ProgressView()
                            .tint(AppColors.secondaryGray)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 148)
                .clipped()

                // Add button
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        if isAdded {
                            addedItemIDs.remove(item.id)
                        } else {
                            addedItemIDs.insert(item.id)
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    }
                } label: {
                    Image(systemName: isAdded ? "checkmark" : "plus")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(AppColors.white)
                        .frame(width: 34, height: 34)
                        .background(isAdded ? Color(hex: "34C759") : AppColors.primaryText)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                        .scaleEffect(isAdded ? 1.05 : 1.0)
                }
                .buttonStyle(.plain)
                .padding(AppSpacing.sm)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)

                Text(item.subtitle)
                    .font(AppTypography.caption1)
                    .foregroundStyle(AppColors.secondaryGray)

                Text("$\(item.price)")
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)
                    .padding(.top, 4)
            }
            .padding(AppSpacing.sm)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
        .softShadow()
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                .stroke(isAdded ? Color(hex: "34C759").opacity(0.4) : Color.clear, lineWidth: 1.5)
        )
    }

    // MARK: - Filter Chips

    private var filtersSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(AIRecommendationFilter.allCases) { filter in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            selectedFilter = filter
                        }
                    } label: {
                        Text(filter.rawValue)
                            .font(AppTypography.footnoteSemibold)
                            .foregroundStyle(selectedFilter == filter ? AppColors.white : AppColors.primaryText)
                            .padding(.horizontal, AppSpacing.md)
                            .padding(.vertical, 10)
                            .background(
                                Group {
                                    if selectedFilter == filter {
                                        Capsule().fill(AppColors.primaryText)
                                    } else {
                                        Capsule()
                                            .fill(AppColors.white)
                                            .overlay(Capsule().stroke(Color.black.opacity(0.1), lineWidth: 1))
                                    }
                                }
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.vertical, 4)
        }
        .padding(.horizontal, -AppSpacing.screenHorizontal)
    }
}

// MARK: - Preview

#Preview("AI Recommendations") {
    NavigationStack {
        AIRecommendationsView()
    }
}
