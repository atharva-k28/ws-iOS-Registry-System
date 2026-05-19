//
//  RegistryProgressCard.swift
//  iOS_Registry_System
//
//  Shows progress of user's active registry on Home Screen
//

import SwiftUI

struct RegistryProgressCard: View {
    let eventTitle: String
    let eventType: String
    let progress: Double // 0 to 1
    let itemsClaimed: Int
    let totalItems: Int
    let contributors: Int

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("\(eventTypeDisplayName.uppercased()) REGISTRY")
                .font(AppTypography.caption1Medium)
                .tracking(1.5)
                .foregroundColor(AppColors.secondaryGray)

            HStack(alignment: .bottom) {
                Text(eventTitle)
                    .font(AppTypography.title2)
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(AppTypography.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primaryText)
            }
            
            ProgressBar(progress: progress, height: 6)
                .padding(.vertical, AppSpacing.xxs)
            
            Text("\(itemsClaimed) of \(totalItems) items claimed · \(contributors) contributors")
                .font(AppTypography.footnote)
                .foregroundColor(AppColors.secondaryGray)
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl, style: .continuous))
        .softShadow()
    }

    private var eventTypeDisplayName: String {
        eventType
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
}
