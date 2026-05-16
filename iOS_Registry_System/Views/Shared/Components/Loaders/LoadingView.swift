//
//  LoadingView.swift
//  iOS_Registry_System
//
//  Premium loading indicator
//

import SwiftUI

// MARK: - Loading View

struct LoadingView: View {

    var message: String = "Loading..."

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            // Animated dots
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(AppColors.accentRed)
                        .frame(width: 10, height: 10)
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .opacity(isAnimating ? 1.0 : 0.3)
                        .animation(
                            .easeInOut(duration: 0.6)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                            value: isAnimating
                        )
                }
            }

            Text(message)
                .font(AppTypography.footnote)
                .foregroundStyle(AppColors.secondaryGray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background.ignoresSafeArea())
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Inline Loading

struct InlineLoadingView: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .tint(AppColors.accentRed)
            .frame(maxWidth: .infinity)
            .padding(AppSpacing.xxl)
    }
}

// MARK: - Preview

#Preview("Loading View") {
    LoadingView()
}

#Preview("Inline Loading") {
    InlineLoadingView()
        .background(AppColors.background)
}
