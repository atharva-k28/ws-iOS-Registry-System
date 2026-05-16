//
//  ContributionSuccessView.swift
//  iOS_Registry_System
//
//  Screen 4 — fullscreen celebration success state.
//  Floating particles, animated progress update, and
//  an emotional confirmation message.
//

import SwiftUI

// MARK: - Particle Model

private struct Particle: Identifiable {
    let id = UUID()
    let emoji: String
    let x: CGFloat
    let delay: Double
    let scale: CGFloat
    let rotationDegrees: Double
}

// MARK: - Contribution Success View

struct ContributionSuccessView: View {

    let gift: PriorityGiftItem
    let amount: Double
    let note: String
    let emoji: String

    @State private var particles: [Particle] = []
    @State private var showContent = false
    @State private var progressValue: Double = 0
    @State private var floatOffset: CGFloat = 0
    @State private var screenWidth: CGFloat = 390
    @Environment(\.dismiss) private var dismiss

    private let confettiEmojis = ["🎉", "✨", "💝", "🌹", "🎊", "💫", "🥂"]

    private var newProgress: Double {
        min((gift.currentAmount + amount) / gift.goalAmount, 1.0)
    }
    private var newPercent: Int { Int(newProgress * 100) }

    var body: some View {
        ZStack {
            // Warm ivory background
            Color(hex: "FAF7F4")
                .ignoresSafeArea()
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .onAppear { screenWidth = geo.size.width }
                            .onChange(of: geo.size.width) { _, newSize in screenWidth = newSize }
                    }
                )

            // Floating particle layer
            GeometryReader { geo in
                ForEach(particles) { p in
                    Text(p.emoji)
                        .font(.system(size: 24 * p.scale))
                        .position(x: p.x, y: showContent ? -40 : geo.size.height + 40)
                        .rotationEffect(.degrees(p.rotationDegrees))
                        .animation(
                            .easeOut(duration: 2.5)
                            .delay(p.delay),
                            value: showContent
                        )
                        .opacity(showContent ? 0 : 1)
                }
            }
            .ignoresSafeArea()

            VStack(spacing: AppSpacing.xxl) {

                Spacer()

                // Animated emoji + glow
                ZStack {
                    Circle()
                        .fill(AppColors.accentRed.opacity(0.08))
                        .frame(width: 130, height: 130)
                        .scaleEffect(showContent ? 1.15 : 0.9)
                        .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: showContent)

                    Text(emoji)
                        .font(.system(size: 60))
                        .offset(y: floatOffset)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: floatOffset)
                }

                // Heading + subheading
                VStack(spacing: 8) {
                    Text("Your gift is in.")
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(AppColors.primaryText)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showContent)

                    Text("You helped bring this celebration closer.")
                        .font(.system(size: 17, weight: .regular, design: .serif))
                        .italic()
                        .foregroundStyle(AppColors.secondaryGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.xl)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 16)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.35), value: showContent)
                }

                // Contribution summary card
                summaryCard
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 24)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5), value: showContent)

                // Updated progress ring
                updatedProgressRing
                    .opacity(showContent ? 1 : 0)
                    .scaleEffect(showContent ? 1 : 0.85)
                    .animation(.spring(response: 0.7, dampingFraction: 0.65).delay(0.65), value: showContent)

                Spacer()

                // Done CTA
                Button {
                    dismiss()
                } label: {
                    Text("Back to Gift")
                        .font(AppTypography.buttonLarge)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(AppColors.primaryDark)
                        .clipShape(Capsule())
                        .softShadow()
                }
                .buttonStyle(.plain)
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .opacity(showContent ? 1 : 0)
                .animation(.easeIn.delay(0.85), value: showContent)

                Color.clear.frame(height: AppSpacing.xl)
            }
        }
        .onAppear {
            generateParticles(screenWidth: screenWidth)
            withAnimation { showContent = true }
            withAnimation(.easeInOut(duration: 1.5).delay(0.8)) {
                progressValue = newProgress
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                floatOffset = -8
            }
        }
    }

    // MARK: - Summary Card

    private var summaryCard: some View {
        HStack(spacing: AppSpacing.md) {
            AsyncImage(url: URL(string: gift.galleryURL(index: 0))) { img in
                img.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color(hex: "E8E2DC")
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(gift.title)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)
                Text("You contributed $\(Int(amount))")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.accentRed)
                if !note.isEmpty {
                    Text("\"\(note)\"")
                        .font(.system(size: 12, weight: .regular, design: .serif))
                        .italic()
                        .foregroundStyle(AppColors.secondaryGray)
                        .lineLimit(1)
                }
            }

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(Color(hex: "34C759"))
        }
        .padding(AppSpacing.md)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
        .softShadow()
        .padding(.horizontal, AppSpacing.screenHorizontal)
    }

    // MARK: - Updated Progress Ring

    private var updatedProgressRing: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .stroke(AppColors.backgroundGray, lineWidth: 8)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: progressValue)
                    .stroke(AppColors.accentRed, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.65), value: progressValue)

                Text("\(newPercent)%")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.primaryText)
            }

            Text("funded now")
                .font(AppTypography.caption1)
                .foregroundStyle(AppColors.secondaryGray)
        }
    }

    // MARK: - Particle Generation

    private func generateParticles(screenWidth: CGFloat = 390) {
        particles = (0..<20).map { _ in
            Particle(
                emoji: confettiEmojis.randomElement()!,
                x: CGFloat.random(in: 40...(screenWidth - 40)),
                delay: Double.random(in: 0...1.2),
                scale: CGFloat.random(in: 0.6...1.4),
                rotationDegrees: Double.random(in: -60...60)
            )
        }
    }
}

// MARK: - Preview

#Preview("Contribution Success") {
    ContributionSuccessView(
        gift: .espressoMachine,
        amount: 50,
        note: "Congrats! Can't wait 🥂",
        emoji: "🎉"
    )
}
