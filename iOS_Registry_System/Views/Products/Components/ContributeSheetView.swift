//
//  ContributeSheetView.swift
//  iOS_Registry_System
//
//  Half-height modal sheet for group gifting contributions
//

import SwiftUI

struct ContributeSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var amount: String = "50"
    
    let presetAmounts = [25, 50, 100, 200]
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            // Header
            VStack(spacing: AppSpacing.xs) {
                Text("Group Gifting")
                    .font(AppTypography.caption1Medium)
                    .tracking(1.5)
                    .foregroundColor(AppColors.secondaryGray)
                
                Text("Seasoned Cast Iron Set")
                    .font(AppTypography.title3)
                    .foregroundColor(AppColors.primaryText)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, AppSpacing.xl)
            
            // Amount Input
            VStack(spacing: AppSpacing.md) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("$")
                        .font(AppTypography.title2)
                        .foregroundColor(AppColors.primaryText)
                    
                    TextField("0", text: $amount)
                        .font(.system(size: 48, weight: .semibold, design: .serif))
                        .foregroundColor(AppColors.primaryText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 140)
                }
                
                // Presets
                HStack(spacing: AppSpacing.sm) {
                    ForEach(presetAmounts, id: \.self) { preset in
                        Button {
                            amount = "\(preset)"
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            Text("$\(preset)")
                                .font(AppTypography.buttonMedium)
                                .foregroundColor(amount == "\(preset)" ? AppColors.white : AppColors.primaryText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(amount == "\(preset)" ? AppColors.primaryDark : AppColors.backgroundGray)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            
            Spacer()
            
            // Apple Pay / Continue Button
            Button {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "applelogo")
                        .font(.system(size: 16))
                    Text("Pay")
                        .font(AppTypography.buttonMedium)
                }
                .foregroundColor(AppColors.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(AppColors.primaryDark)
                .clipShape(Capsule())
            }
            .padding(.bottom, AppSpacing.xl)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .background(AppColors.white)
    }
}

#Preview {
    Text("Preview")
        .sheet(isPresented: .constant(true)) {
            ContributeSheetView()
                .presentationDetents([.medium])
        }
}
