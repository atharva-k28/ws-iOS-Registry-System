//
//  ContributionProgressBar.swift
//  iOS_Registry_System
//
//  Animated contribution progress bar component
//

import SwiftUI

// MARK: - Contribution Progress Bar

struct ContributionProgressBar: View {

    let progress: Double // 0.0 to 1.0
    let currentAmount: Double
    let targetAmount: Double
    var showLabels: Bool = true
    var height: CGFloat = 8
    var tint: Color = AppColors.accentRed

    @State private var animatedProgress: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {

            // MARK: Progress Bar

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(AppColors.backgroundGray)
                        .frame(height: height)

                    // Fill
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(
                            LinearGradient(
                                colors: [tint, tint.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * animatedProgress, height: height)
                }
            }
            .frame(height: height)

            // MARK: Labels

            if showLabels {
                HStack {
                    Text(CurrencyFormatter.formatCompact(currentAmount))
                        .font(AppTypography.caption1Medium)
                        .foregroundStyle(AppColors.primaryText)

                    Spacer()

                    Text("of \(CurrencyFormatter.formatCompact(targetAmount))")
                        .font(AppTypography.caption1)
                        .foregroundStyle(AppColors.secondaryGray)

                    Text("• \(PercentageFormatter.format(progress))")
                        .font(AppTypography.caption1Medium)
                        .foregroundStyle(tint)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                animatedProgress = progress
            }
        }
    }
}

// MARK: - Preview

#Preview("Progress Bar") {
    VStack(spacing: 32) {
        ContributionProgressBar(
            progress: 0.67,
            currentAmount: 280,
            targetAmount: 419.95
        )

        ContributionProgressBar(
            progress: 0.25,
            currentAmount: 125,
            targetAmount: 500
        )

        ContributionProgressBar(
            progress: 1.0,
            currentAmount: 749.99,
            targetAmount: 749.99,
            tint: .green
        )

        ContributionProgressBar(
            progress: 0.5,
            currentAmount: 44.50,
            targetAmount: 89,
            showLabels: false,
            height: 4
        )
    }
    .padding(24)
    .background(AppColors.surface)
}
