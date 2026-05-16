//
//  ContributionSheetView.swift
//  iOS_Registry_System
//
//  Screen 3 in Priority Gifts flow.
//  Native iOS bottom sheet — amount selection, Apple Pay,
//  personal note, and emoji celebration picker.
//

import SwiftUI

// MARK: - Contribution Sheet View

struct ContributionSheetView: View {

    let gift: PriorityGiftItem
    @Binding var selectedAmount: Double
    var startInCustomMode: Bool = false
    let onContribute: () -> Void

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
            ContributionSuccessView(
                gift: gift,
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

                    // Product thumbnail + title
                    productSummary

                    // Quick amounts
                    quickAmountSection

                    // Custom amount field (if active)
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
        .onAppear {
            if startInCustomMode {
                isCustomMode = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    amountFieldFocused = true
                }
            }
        }
    }

    // MARK: - Header

    private var sheetHeader: some View {
        VStack(spacing: AppSpacing.xs) {
            // Single system grabber is rendered by .presentationDetents
            // Do NOT add a second custom capsule here

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
            AsyncImage(url: URL(string: gift.galleryURL(index: 0))) { img in
                img.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color(hex: "E8E2DC")
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(gift.collectionLabel)
                    .font(AppTypography.caption2)
                    .tracking(1.5)
                    .foregroundStyle(AppColors.secondaryGray)
                Text(gift.title)
                    .font(AppTypography.headline)
                    .foregroundStyle(AppColors.primaryText)

                // Inline progress bar
                ProgressBar(progress: gift.progress, height: 3)
                    .padding(.top, 4)

                Text("$\(Int(gift.currentAmount)) of $\(Int(gift.goalAmount)) raised")
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
        VStack(spacing: AppSpacing.sm) {

            // Apple Pay button (liquid glass style)
            Button {
                triggerContribute()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "applelogo")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Pay")
                        .font(AppTypography.buttonLarge)
                }
                .foregroundStyle(AppColors.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(AppColors.primaryDark)
                .clipShape(Capsule())
                .softShadow()
            }
            .buttonStyle(.plain)

            // Contribute amount button
            Button {
                triggerContribute()
            } label: {
                Text("Contribute $\(Int(effectiveAmount)) →")
                    .font(AppTypography.buttonMedium)
                    .foregroundStyle(AppColors.accentRed)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(Capsule().stroke(AppColors.accentRed.opacity(0.3), lineWidth: 1))
                    )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Actions

    private func triggerContribute() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showSuccess = true
        }
        onContribute()
    }
}

// MARK: - Invite Collaborators Sheet

struct InviteCollaboratorsSheet: View {
    let giftTitle: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Capsule()
                .fill(AppColors.secondaryGray.opacity(0.3))
                .frame(width: 36, height: 4)
                .padding(.top, AppSpacing.sm)

            Image(systemName: "person.2.wave.2")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.accentRed)
                .symbolEffect(.pulse)

            VStack(spacing: 8) {
                Text("Invite Friends")
                    .font(AppTypography.title2)
                    .foregroundStyle(AppColors.primaryText)
                Text("Share \"\(giftTitle)\" so friends can join the group gift.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryGray)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: AppSpacing.sm) {
                shareButton(icon: "message", label: "Send via Messages", color: Color(hex: "34C759"))
                shareButton(icon: "envelope",    label: "Send via Email",    color: Color(hex: "007AFF"))
                shareButton(icon: "link",         label: "Copy Link",         color: AppColors.primaryDark)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)

            Spacer()
        }
        .appBackground()
    }

    private func shareButton(icon: String, label: String, color: Color) -> some View {
        Button {
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(color)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                Text(label)
                    .font(AppTypography.bodyMedium)
                    .foregroundStyle(AppColors.primaryText)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppColors.secondaryGray)
            }
            .padding(AppSpacing.md)
            .cardStyle()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Contribution Sheet") {
    @Previewable @State var amount: Double = 50
    return ContributionSheetView(
        gift: .espressoMachine,
        selectedAmount: $amount,
        onContribute: { }
    )
}
