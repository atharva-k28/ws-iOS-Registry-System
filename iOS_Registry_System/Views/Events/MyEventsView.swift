//
//  MyEventsView.swift
//  iOS_Registry_System
//
//  My Events screen — starter layout
//

import SwiftUI

// MARK: - My Events View

struct MyEventsView: View {

    @State private var viewModel = EventsViewModel()

    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {

                    // MARK: Header

                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hosting")
                                .font(AppTypography.subheadline)
                                .foregroundStyle(AppColors.secondaryGray)

                            Text("My Events")
                                .font(AppTypography.largeTitleSerif)
                                .foregroundStyle(AppColors.primaryText)
                        }

                        Spacer()

                        Button(action: {
                            // Create event action
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(AppColors.accentRed)
                                .clipShape(Circle())
                                .softShadow()
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)

                    // MARK: Primary Event Card

                    if let primaryEvent = viewModel.filteredEvents.first {
                        EventCard(event: primaryEvent)
                            .padding(.horizontal, AppSpacing.screenHorizontal)

                        // MARK: Event Stats
                        HStack(spacing: AppSpacing.sm) {
                            statCard(value: "68%", label: "Complete", icon: "arrow.up.right")
                            statCard(value: "$4.2k", label: "Raised", icon: "wallet.pass")
                            statCard(value: "24", label: "Guests", icon: "person.2")
                        }
                        .padding(.horizontal, AppSpacing.screenHorizontal)

                        // MARK: Quiet Suggestions
                        SuggestionCard(
                            title: "A few quiet suggestions",
                            subtitle: "5 thoughtful additions for your registry"
                        )
                        .padding(.horizontal, AppSpacing.screenHorizontal)

                        // MARK: Priority Gifts
                        VStack(alignment: .leading, spacing: AppSpacing.sectionHeaderGap) {
                            HStack {
                                Text("PRIORITY GIFTS")
                                    .font(AppTypography.caption1Medium)
                                    .tracking(1.5)
                                    .foregroundColor(AppColors.primaryText)

                                Spacer()

                                Text("See all")
                                    .font(AppTypography.subheadline)
                                    .foregroundColor(AppColors.secondaryGray)
                            }
                            .padding(.horizontal, AppSpacing.screenHorizontal)

                            VStack(spacing: AppSpacing.sm) {
                                PriorityGiftCard(
                                    title: "Made In Cookware Set",
                                    currentAmount: 320,
                                    goalAmount: 500,
                                    imageSeed: "pans"
                                )
                                PriorityGiftCard(
                                    title: "Outdoor BBQ Bundle",
                                    currentAmount: 95,
                                    goalAmount: 280,
                                    imageSeed: "bbq"
                                )
                                PriorityGiftCard(
                                    title: "Espresso Machine",
                                    currentAmount: 640,
                                    goalAmount: 1200,
                                    imageSeed: "coffee"
                                )
                            }
                            .padding(.horizontal, AppSpacing.screenHorizontal)
                        }
                    }

                    // Bottom spacer for tab bar
                    Color.clear.frame(height: AppSpacing.tabBarHeight + AppSpacing.xxl)
                }
                .padding(.top, AppSpacing.md)
            }
            .appBackground()
            .transparentNavigationBar()
            .task {
                await viewModel.loadEvents()
            }
        }
    }

    private func statCard(value: String, label: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(AppColors.secondaryGray)
                .padding(.bottom, AppSpacing.xs)

            Text(value)
                .font(AppTypography.title2)
                .foregroundStyle(AppColors.primaryText)

            Text(label)
                .font(AppTypography.caption1)
                .foregroundStyle(AppColors.secondaryGray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.md)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
        .softShadow()
    }
}

// MARK: - Preview

#Preview("My Events") {
    MyEventsView()
}
