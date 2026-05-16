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

                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text("My Events")
                            .font(AppTypography.largeTitle)
                            .foregroundStyle(AppColors.primaryText)

                        Text("Your registries & celebrations")
                            .font(AppTypography.subheadline)
                            .foregroundStyle(AppColors.secondaryGray)
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)

                    // MARK: Filter Chips

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: AppSpacing.xs) {
                            filterChip(title: "All", isSelected: viewModel.selectedEventType == nil) {
                                viewModel.selectFilter(nil)
                            }
                            ForEach(EventType.allCases) { type in
                                filterChip(
                                    title: type.displayName,
                                    icon: type.icon,
                                    isSelected: viewModel.selectedEventType == type
                                ) {
                                    viewModel.selectFilter(type)
                                }
                            }
                        }
                        .padding(.horizontal, AppSpacing.screenHorizontal)
                    }

                    // MARK: Create New CTA

                    PrimaryButton(title: "Create New Registry", icon: "plus", style: .accent) {
                        // TODO: Navigate to create event
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)

                    // MARK: Event List

                    LazyVStack(spacing: AppSpacing.cardGap) {
                        ForEach(viewModel.filteredEvents) { event in
                            EventCard(event: event)
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)

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

    // MARK: - Filter Chip

    private func filterChip(title: String, icon: String? = nil, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 12))
                }
                Text(title)
                    .font(AppTypography.caption1Medium)
            }
            .foregroundStyle(isSelected ? .white : AppColors.primaryText)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.xs)
            .background(
                isSelected ? AppColors.primaryDark : AppColors.surface
            )
            .clipShape(Capsule())
            .softShadow()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("My Events") {
    MyEventsView()
}
