//
//  FriendEventCard.swift
//  iOS_Registry_System
//
//  Event card for friends' registries
//

import SwiftUI

struct FriendEventCard: View {
    let event: Event
    var progress: Double = 0.82
    var onTap: (() -> Void)?

    var body: some View {
        Button {
            onTap?()
        } label: {
            VStack(spacing: 0) {
                // Image Section
                ZStack(alignment: .bottomLeading) {
                    Color.gray.opacity(0.3)
                        .overlay {
                            AsyncImage(url: URL(string: imageUrl(for: event.title))) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                        }
                        .frame(height: 180)
                        .clipped()

                    // Gradient overlay
                    LinearGradient(
                        colors: [.black.opacity(0.7), .clear],
                        startPoint: .bottom,
                        endPoint: .top
                    )

                    // Title info
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(event.eventType.replacingOccurrences(of: "_", with: " ").uppercased()) · \((event.eventDate ?? Date()).formattedLong.uppercased())")
                            .font(AppTypography.caption1Medium)
                            .tracking(1.5)
                            .foregroundStyle(.white)

                        Text(event.title)
                            .font(AppTypography.premiumTitle)
                            .foregroundStyle(.white)
                    }
                    .padding(AppSpacing.md)
                    
                    // Top Right Badge
                    VStack {
                        HStack {
                            Spacer()
                            
                            // Circular Product Badge
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 64, height: 64)
                                    
                                HStack(spacing: 2) {
                                    AsyncImage(url: URL(string: badgeImage(for: event.title, index: 1))) { image in
                                        image.resizable().aspectRatio(contentMode: .fill)
                                    } placeholder: { Color.gray.opacity(0.2) }
                                    .frame(width: 26, height: 56)
                                    .clipped()
                                    
                                    VStack(spacing: 2) {
                                        AsyncImage(url: URL(string: badgeImage(for: event.title, index: 2))) { image in
                                            image.resizable().aspectRatio(contentMode: .fill)
                                        } placeholder: { Color.gray.opacity(0.2) }
                                        .frame(width: 26, height: 27)
                                        .clipped()
                                        
                                        AsyncImage(url: URL(string: badgeImage(for: event.title, index: 3))) { image in
                                            image.resizable().aspectRatio(contentMode: .fill)
                                        } placeholder: { Color.gray.opacity(0.2) }
                                        .frame(width: 26, height: 27)
                                        .clipped()
                                    }
                                }
                                .clipShape(Circle())
                                .padding(4)
                            }
                            .padding(AppSpacing.md)
                        }
                        Spacer()
                    }
                }

                // Bottom Action Section
                HStack(spacing: AppSpacing.md) {
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        HStack {
                            Text("Registry complete")
                                .font(AppTypography.caption1)
                                .foregroundStyle(AppColors.secondaryGray)
                            
                            Spacer()
                            
                            Text("\(Int(progress * 100))%")
                                .font(AppTypography.footnoteSemibold)
                                .foregroundStyle(AppColors.primaryDark)
                        }
                        ProgressBar(progress: progress, height: 4)
                    }

                    Button("View") {
                        onTap?()
                    }
                    .font(AppTypography.buttonSmall)
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, 8)
                    .background(AppColors.primaryDark)
                    .clipShape(Capsule())
                }
                .padding(AppSpacing.md)
                .background(AppColors.white)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl, style: .continuous))
            .softShadow()
        }
        .buttonStyle(.plain)
    }

    private func imageUrl(for title: String) -> String {
        if title.contains("Emma") { return "https://images.unsplash.com/photo-1555244162-803834f70033?w=800" }
        if title.contains("Maya") { return "https://images.unsplash.com/photo-1556910103-1c02745aae4d?w=800" }
        if title.contains("Liam") { return "https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=800" }
        return "https://images.unsplash.com/photo-1556911220-e15024029581?w=800"
    }

    private func badgeImage(for title: String, index: Int) -> String {
        let seeds = ["cookware", "plates", "crockery", "kitchen"]
        return "https://loremflickr.com/100/100/\(seeds[index % seeds.count])?lock=\(abs(title.hashValue % 100) + index)"
    }
}

#Preview {
    FriendEventCard(event: .mock)
        .padding()
        .background(AppColors.background)
}
