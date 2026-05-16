//
//  QuantityStepper.swift
//  iOS_Registry_System
//
//  Custom quantity stepper
//

import SwiftUI

struct QuantityStepper: View {
    @Binding var quantity: Int
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Button {
                if quantity > 1 {
                    quantity -= 1
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(quantity > 1 ? AppColors.primaryDark : AppColors.secondaryGray)
                    .frame(width: 32, height: 32)
                    .background(AppColors.backgroundGray)
                    .clipShape(Circle())
            }
            .disabled(quantity <= 1)
            
            Text("\(quantity)")
                .font(AppTypography.bodySemibold)
                .foregroundColor(AppColors.primaryText)
                .frame(minWidth: 20)
            
            Button {
                quantity += 1
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.white)
                    .frame(width: 32, height: 32)
                    .background(AppColors.primaryDark)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, 4)
        .background(AppColors.white)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(AppColors.backgroundGray, lineWidth: 1))
    }
}

#Preview {
    QuantityStepper(quantity: .constant(1))
}
