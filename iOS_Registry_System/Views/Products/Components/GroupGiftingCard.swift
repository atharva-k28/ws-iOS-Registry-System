//
//  GroupGiftingCard.swift
//  iOS_Registry_System
//
//  Group gifting progress card
//

import SwiftUI

struct GroupGiftingCard: View {
    let currentAmount: Double
    let targetAmount: Double
    let contributorsCount: Int
    let onContribute: () -> Void
    
    var progress: Double {
        min(currentAmount / targetAmount, 1.0)
    }
    
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.secondaryGray)
                    Text("GROUP GIFTING")
                        .font(AppTypography.caption2)
                        .tracking(1.5)
                        .foregroundColor(AppColors.secondaryGray)
                }
                
                Spacer()
                
                Text("\(CurrencyFormatter.format(currentAmount)) / \(CurrencyFormatter.format(targetAmount))")
                    .font(AppTypography.subheadlineMedium)
                    .foregroundColor(AppColors.primaryText)
            }
            
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppColors.backgroundGray)
                        .frame(height: 6)
                    
                    Capsule()
                        .fill(AppColors.accentRed)
                        .frame(width: proxy.size.width * progress, height: 6)
                }
            }
            .frame(height: 6)
            
            HStack {
                Text("\(contributorsCount) friends contributed")
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColors.secondaryGray)
                
                Text("·")
                    .font(AppTypography.caption1)
                    .foregroundColor(AppColors.secondaryGray)
                
                Text("\(CurrencyFormatter.format(targetAmount - currentAmount)) to go")
                    .font(AppTypography.caption1Medium)
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.md, style: .continuous)
                .stroke(AppColors.backgroundGray, lineWidth: 1)
        )
        .onTapGesture {
            onContribute()
        }
    }
}

#Preview {
    GroupGiftingCard(currentAmount: 210, targetAmount: 320, contributorsCount: 6, onContribute: {})
        .padding()
}
