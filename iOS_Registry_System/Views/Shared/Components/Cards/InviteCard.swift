//
//  InviteCard.swift
//  iOS_Registry_System
//
//  Premium invite card for pending registry invitations
//

import SwiftUI

// MARK: - Invite Card

struct InviteCard: View {
    let event: Event
    var onAccept: () -> Void
    var onDecline: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Cover Image
            ZStack(alignment: .bottomLeading) {
                Color.gray.opacity(0.3)
                    .overlay {
                        AsyncImage(url: URL(string: coverImage(for: event.eventType))) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                    }
                    .frame(height: 140)
                    .clipped()

                // Gradient
                LinearGradient(
                    colors: [.black.opacity(0.7), .clear],
                    startPoint: .bottom,
                    endPoint: .top
                )

                // Badge
                VStack {
                    HStack {
                        Spacer()
                        HStack(spacing: 4) {
                            Image(systemName: "envelope.badge")
                                .font(.system(size: 11, weight: .semibold))
                            Text("INVITE")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1.2)
                        }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppColors.accentRed)
                        .clipShape(Capsule())
                        .padding(AppSpacing.sm)
                    }
                    Spacer()
                }

                // Event info overlay
                VStack(alignment: .leading, spacing: 4) {
                    Text(eventTypeLabel.uppercased())
                        .font(AppTypography.caption1Medium)
                        .tracking(1.5)
                        .foregroundStyle(.white.opacity(0.85))

                    Text(event.title)
                        .font(AppTypography.premiumTitle)
                        .foregroundStyle(.white)
                }
                .padding(AppSpacing.md)
            }

            // Details + Action Buttons
            VStack(spacing: AppSpacing.md) {
                // Date & venue row
                HStack(spacing: AppSpacing.lg) {
                    if let date = event.startDate ?? event.eventDate {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 13))
                                .foregroundStyle(AppColors.accentRed)
                            Text(date.formattedLong)
                                .font(AppTypography.caption1)
                                .foregroundStyle(AppColors.secondaryGray)
                        }
                    }

                    if let venue = event.venue, !venue.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 13))
                                .foregroundStyle(AppColors.accentRed)
                            Text(venue)
                                .font(AppTypography.caption1)
                                .foregroundStyle(AppColors.secondaryGray)
                                .lineLimit(1)
                        }
                    }

                    Spacer()
                }

                // Action buttons
                HStack(spacing: AppSpacing.sm) {
                    // Decline
                    Button {
                        onDecline()
                    } label: {
                        Text("Decline")
                            .font(AppTypography.buttonSmall)
                            .foregroundStyle(AppColors.accentRed)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(
                                Capsule()
                                    .stroke(AppColors.accentRed, lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(.plain)

                    // Accept
                    Button {
                        onAccept()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .semibold))
                            Text("Accept")
                                .font(AppTypography.buttonSmall)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color(hex: "34C759"))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppSpacing.md)
            .background(AppColors.white)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl, style: .continuous))
        .softShadow()
    }

    // MARK: - Helpers

    private var eventTypeLabel: String {
        event.eventType.replacingOccurrences(of: "_", with: " ")
    }

    private func coverImage(for type: String) -> String {
        switch type {
        case "wedding":
            return "https://images.unsplash.com/photo-1519741497674-611481863552?w=800"
        case "baby_shower":
            return "https://images.unsplash.com/photo-1555244162-803834f70033?w=800"
        case "housewarming":
            return "https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=800"
        case "birthday":
            return "https://images.unsplash.com/photo-1464349153159-d0c351cc3987?w=800"
        default:
            return "https://images.unsplash.com/photo-1556911220-e15024029581?w=800"
        }
    }
}
