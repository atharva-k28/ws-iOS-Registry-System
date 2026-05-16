//
//  ContributionWidget.swift
//  iOS_Registry_System
//
//  Progress-based card showing funding status
//

import SwiftUI

struct ContributionWidget: View {
    let title: String
    let currentAmount: Double
    let targetAmount: Double
    var onContribute: (() -> Void)? = nil
    
    private var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(currentAmount / targetAmount, 1.0)
    }
    
    private var isFunded: Bool {
        currentAmount >= targetAmount
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(title)
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.primaryDark)
                    
                    Text("Group Gift")
                        .font(AppTypography.caption1)
                        .foregroundColor(AppColors.secondaryGray)
                }
                
                Spacer()
                
                if isFunded {
                    StatusChip(title: "Fully Funded", isSelected: true)
                }
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack {
                    Text(String(format: "$%.0f", currentAmount))
                        .font(AppTypography.bodySemibold)
                        .foregroundColor(AppColors.primaryDark)
                    
                    Text("of \(String(format: "$%.0f", targetAmount))")
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.secondaryGray)
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(AppTypography.footnoteSemibold)
                        .foregroundColor(AppColors.accentRed)
                }
                
                ProgressBar(progress: progress)
            }
            
            if !isFunded {
                PrimaryButton(title: "Contribute", style: .outline) {
                    onContribute?()
                }
            }
        }
        .padding(AppSpacing.cardPadding)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md, style: .continuous))
        .softShadow()
    }
}

#Preview {
    VStack(spacing: 20) {
        ContributionWidget(
            title: "Honeymoon Fund",
            currentAmount: 750,
            targetAmount: 2000
        )
        
        ContributionWidget(
            title: "Espresso Machine",
            currentAmount: 500,
            targetAmount: 500
        )
    }
    .padding()
    .background(AppColors.background)
}
