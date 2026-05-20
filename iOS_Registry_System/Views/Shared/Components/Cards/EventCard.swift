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
    var onManageRegistry: (() -> Void)?
    var onInvite: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            ZStack(alignment: .bottom) {
                // Background Image
                Color.gray.opacity(0.3)
                    .overlay {
                        AsyncImage(url: URL(string: EventCoverImage.url(for: event))) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                    }
                    .frame(height: 280)
                    .clipped()

                // Top Left Badge
                VStack {
                    HStack {
                        if let date = event.startDate {
                            Text(date.daysUntil.uppercased())
                                .font(AppTypography.caption1Medium)
                                .fontWeight(.bold)
                                .foregroundStyle(AppColors.primaryDark)
                                .padding(.horizontal, AppSpacing.sm)
                                .padding(.vertical, 6)
                                .background(.white)
                                .clipShape(Capsule())
                                .padding(AppSpacing.md)
                        }
                        Spacer()
                    }
                    Spacer()
                }

                // Bottom Glassmorphic Card
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(event.eventType.replacingOccurrences(of: "_", with: " ").uppercased()) · \((event.startDate ?? Date()).formattedLong.uppercased())")
                            .font(AppTypography.caption2)
                            .tracking(1)
                            .foregroundStyle(.white.opacity(0.8))

                        Text(event.title)
                            .font(AppTypography.largeTitleSerif)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                    }


                }
                .padding(AppSpacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [.black.opacity(0.8), .black.opacity(0.0)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl, style: .continuous))
            .softShadow()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private var eventTypeIcon: String {
        EventType(rawValue: event.eventType)?.icon ?? "sparkles"
    }


}
