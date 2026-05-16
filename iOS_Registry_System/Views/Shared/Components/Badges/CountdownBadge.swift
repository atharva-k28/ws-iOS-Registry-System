//
//  CountdownBadge.swift
//  iOS_Registry_System
//
//  Floating pill-style badge for event countdowns
//

import SwiftUI

struct CountdownBadge: View {
    let daysLeft: Int
    
    var body: some View {
        HStack(spacing: AppSpacing.xxs) {
            Image(systemName: "calendar")
                .font(.system(size: 11, weight: .semibold))
            
            Text("\(daysLeft) DAYS LEFT")
                .font(AppTypography.caption1Medium)
                // Monospaced digits help prevent jittering if counting down live
                .monospacedDigit()
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(AppColors.white)
        .foregroundColor(AppColors.primaryDark)
        .clipShape(Capsule())
        .softShadow()
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        
        CountdownBadge(daysLeft: 38)
    }
}
