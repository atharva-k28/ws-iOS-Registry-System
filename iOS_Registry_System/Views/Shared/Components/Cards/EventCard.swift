//
//  EventCard.swift
//  iOS_Registry_System
//
//  Premium dark event card component
//

import SwiftUI

// MARK: - Event Card

struct EventCard: View {

    let event: Event
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {

                // MARK: Header — Event Type Badge + Date

                HStack {
                    // Event type badge
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: eventTypeIcon)
                            .font(.system(size: 11, weight: .semibold))
                        Text(event.eventType.replacingOccurrences(of: "_", with: " ").capitalized)
                            .font(AppTypography.caption1Medium)
                    }
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal, AppSpacing.xs)
                    .padding(.vertical, AppSpacing.xxs)
                    .background(.white.opacity(0.15))
                    .clipShape(Capsule())

                    Spacer()

                    // Date badge
                    if let date = event.eventDate {
                        Text(date.daysUntil)
                            .font(AppTypography.caption1Medium)
                            .foregroundStyle(AppColors.accentRed)
                    }
                }

                Spacer()

                // MARK: Title & Description

                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(event.title)
                        .font(AppTypography.title3)
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    if let desc = event.eventDescription {
                        Text(desc)
                            .font(AppTypography.footnote)
                            .foregroundStyle(.white.opacity(0.6))
                            .lineLimit(1)
                    }
                }

                // MARK: Footer — Date

                if let date = event.eventDate {
                    Text(date.formattedLong)
                        .font(AppTypography.caption1)
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .padding(AppSpacing.cardPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 200)
            .background(AppColors.premiumCardGradient)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl, style: .continuous))
            .darkCardShadow()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private var eventTypeIcon: String {
        EventType(rawValue: event.eventType)?.icon ?? "sparkles"
    }
}

// MARK: - Preview

#Preview("Event Card") {
    ScrollView {
        VStack(spacing: 16) {
            EventCard(event: .mock)
            EventCard(event: Event.mockList[1])
            EventCard(event: Event.mockList[2])
        }
        .padding(20)
    }
    .background(AppColors.background)
}
