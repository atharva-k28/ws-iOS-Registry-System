//
//  FriendContributionSheetView.swift
//  iOS_Registry_System
//
//  Bottom sheet modal for contributing to a gift registry item on the Friends tab.
//

import SwiftUI

// MARK: - Friend Contribution Sheet View

struct FriendContributionSheetView: View {

    let item: RegistryItem
    let product: Product
    let isPreviouslyGroupGifting: Bool
    let onContribute: (Double) -> Void

    @State private var selectedAmount: Double = 50.0
    @State private var customAmountText: String = ""
    @State private var isCustomMode: Bool = false
    @State private var note: String = ""
    @State private var selectedEmoji: String = "🎉"
    @State private var showSuccess: Bool = false
    @FocusState private var amountFieldFocused: Bool
    @FocusState private var noteFocused: Bool
    @Environment(\.dismiss) private var dismiss

    private let quickAmounts: [Double] = [25, 50, 100, 200]
    private let celebrationEmojis = ["🎉", "💝", "🥂", "🎊", "✨", "💫", "🌹", "🎁"]

    var effectiveAmount: Double {
        if isCustomMode, let val = Double(customAmountText), val > 0 { return val }
        return selectedAmount
    }

    var body: some View {
        if showSuccess {
            FriendContributionSuccessView(
                item: item,
                product: product,
                isPreviouslyGroupGifting: isPreviouslyGroupGifting,
                amount: effectiveAmount,
                note: note,
                emoji: selectedEmoji
            )
        } else {
            mainSheet
        }
    }

    // MARK: - Main Sheet

    private var mainSheet: some View {
        VStack(spacing: 0) {

            // Header
            sheetHeader

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppSpacing.xl) {

                    // Product summary
                    productSummary

                    // Quick amounts
                    quickAmountSection

                    // Custom amount field
                    if isCustomMode {
                        customAmountField
                    }

                    // Note composer
                    noteSection

                    // Celebration emoji picker
                    emojiSection

                    // Payment buttons
                    paymentSection

                    Color.clear.frame(height: AppSpacing.lg)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.md)
            }
        }
        .appBackground()
    }

    // MARK: - Header

    private var sheetHeader: some View {
        VStack(spacing: AppSpacing.xs) {
            Text("Contribute to a Gift")
                .font(AppTypography.title3)
                .foregroundStyle(AppColors.primaryText)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.md)
        }
    }

    // MARK: - Product Summary

    private var productSummary: some View {
        HStack(spacing: AppSpacing.md) {
            AsyncImage(url: URL(string: imageURL)) { img in
                img.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color(hex: "E8E2DC")
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(product.brand?.uppercased() ?? "GIFT ITEM")
                    .font(AppTypography.caption2)
                    .tracking(1.5)
                    .foregroundStyle(AppColors.secondaryGray)
                Text(product.name)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)

                // Inline progress bar
                ContributionProgressBar(
                    progress: isPreviouslyGroupGifting ? item.progress : 0.0,
                    currentAmount: isPreviouslyGroupGifting ? item.currentAmount : 0.0,
                    targetAmount: item.targetAmount,
                    showLabels: false,
                    height: 3
                )
                .padding(.top, 4)

                Text("$\(Int(isPreviouslyGroupGifting ? item.currentAmount : 0.0)) of $\(Int(item.targetAmount)) raised")
                    .font(AppTypography.caption1)
                    .foregroundStyle(AppColors.secondaryGray)
            }
            Spacer()
        }
        .padding(AppSpacing.md)
        .cardStyle()
    }

    // MARK: - Quick Amount Section

    private var quickAmountSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Choose an amount")
                .font(AppTypography.footnoteSemibold)
                .foregroundStyle(AppColors.secondaryGray)
                .tracking(0.5)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: AppSpacing.sm), count: 4),
                spacing: AppSpacing.sm
            ) {
                ForEach(quickAmounts, id: \.self) { amount in
                    quickAmountChip(amount: amount)
                }
                customChip
            }
        }
    }

    private func quickAmountChip(amount: Double) -> some View {
        let isSelected = !isCustomMode && selectedAmount == amount
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isCustomMode = false
                selectedAmount = amount
            }
        } label: {
            Text("$\(Int(amount))")
                .font(AppTypography.bodyMedium)
                .foregroundStyle(isSelected ? AppColors.white : AppColors.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    Group {
                        if isSelected {
                            RoundedRectangle(cornerRadius: AppCornerRadius.md, style: .continuous)
                                .fill(AppColors.primaryDark)
                        } else {
                            RoundedRectangle(cornerRadius: AppCornerRadius.md, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppCornerRadius.md, style: .continuous)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
                                )
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }

    private var customChip: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isCustomMode = true
                amountFieldFocused = true
            }
        } label: {
            Text("Custom")
                .font(AppTypography.bodyMedium)
                .foregroundStyle(isCustomMode ? AppColors.white : AppColors.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    Group {
                        if isCustomMode {
                            RoundedRectangle(cornerRadius: AppCornerRadius.md, style: .continuous)
                                .fill(AppColors.primaryDark)
                        } else {
                            RoundedRectangle(cornerRadius: AppCornerRadius.md, style: .continuous)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppCornerRadius.md, style: .continuous)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
                                )
                        }
                    }
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Custom Amount Field

    private var customAmountField: some View {
        HStack {
            Text("$")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.accentRed)
            TextField("0", text: $customAmountText)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(AppColors.primaryText)
                .keyboardType(.decimalPad)
                .focused($amountFieldFocused)
        }
        .padding(AppSpacing.md)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.md, style: .continuous)
                .stroke(AppColors.accentRed.opacity(0.3), lineWidth: 1)
        )
        .softShadow()
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: - Note Section

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Add a personal note")
                .font(AppTypography.footnoteSemibold)
                .foregroundStyle(AppColors.secondaryGray)
                .tracking(0.5)

            ZStack(alignment: .topLeading) {
                if note.isEmpty {
                    Text("Write something heartfelt…")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.secondaryGray.opacity(0.6))
                        .padding(.top, 12)
                        .padding(.leading, 4)
                }
                TextEditor(text: $note)
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.primaryText)
                    .scrollContentBackground(.hidden)
                    .focused($noteFocused)
                    .frame(minHeight: 80)
            }
            .padding(AppSpacing.md)
            .background(AppColors.white)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md, style: .continuous))
            .softShadow()
        }
    }

    // MARK: - Emoji Section

    private var emojiSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Celebration mood")
                .font(AppTypography.footnoteSemibold)
                .foregroundStyle(AppColors.secondaryGray)
                .tracking(0.5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(celebrationEmojis, id: \.self) { emoji in
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                selectedEmoji = emoji
                            }
                        } label: {
                            Text(emoji)
                                .font(.system(size: 28))
                                .frame(width: 52, height: 52)
                                .background(
                                    Circle()
                                        .fill(selectedEmoji == emoji
                                            ? AppColors.accentRed.opacity(0.12)
                                            : AppColors.white)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedEmoji == emoji
                                                    ? AppColors.accentRed.opacity(0.4)
                                                    : Color.clear,
                                                    lineWidth: 1.5)
                                        )
                                )
                                .scaleEffect(selectedEmoji == emoji ? 1.15 : 1.0)
                        }
                        .buttonStyle(.plain)
                        .softShadow()
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Payment Section

    private var paymentSection: some View {
        Button {
            triggerContribute()
        } label: {
            HStack {
                Text("Contribute $\(Int(effectiveAmount))")
                    .font(AppTypography.buttonLarge)
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, AppSpacing.xl)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(AppColors.primaryDark)
            .clipShape(Capsule())
            .softShadow()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func triggerContribute() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showSuccess = true
        }
        onContribute(effectiveAmount)
    }

    private var imageURL: String {
        let seed = product.name.replacingOccurrences(of: " ", with: ",")
        return "https://loremflickr.com/400/400/\(seed),product?lock=\(abs(product.id.hashValue % 100))"
    }
}

// MARK: - Friend Contribution Success View

struct FriendContributionSuccessView: View {

    let item: RegistryItem
    let product: Product
    let isPreviouslyGroupGifting: Bool
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
        let baseAmount = isPreviouslyGroupGifting ? item.currentAmount : 0.0
        return min((baseAmount + amount) / item.targetAmount, 1.0)
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
                    Text("Back to Registry")
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
            AsyncImage(url: URL(string: imageURL)) { img in
                img.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color(hex: "E8E2DC")
            }
            .frame(width: 56, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
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

    private var imageURL: String {
        let seed = product.name.replacingOccurrences(of: " ", with: ",")
        return "https://loremflickr.com/400/400/\(seed),product?lock=\(abs(product.id.hashValue % 100))"
    }
}

// MARK: - Particle Model

private struct Particle: Identifiable {
    let id = UUID()
    let emoji: String
    let x: CGFloat
    let delay: Double
    let scale: CGFloat
    let rotationDegrees: Double
}
