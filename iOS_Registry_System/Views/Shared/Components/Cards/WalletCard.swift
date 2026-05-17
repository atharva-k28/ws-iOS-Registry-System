//
//  WalletCard.swift
//  iOS_Registry_System
//
//  Premium wallet card for displaying balances
//

import SwiftUI

struct WalletCard: View {
    let balance: Double
    var onAddFunds: () -> Void = {}
    var onRedeem: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("WALLET CREDITS")
                        .font(AppTypography.caption1Medium)
                        .tracking(1.2)
                        .foregroundColor(AppColors.secondaryGray)
                    
                    Text(CurrencyFormatter.format(balance))
                        .font(AppTypography.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.white)
                }
                
                Spacer()
                
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: "wallet.pass")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
            }
            .padding(.bottom, 4)
            
            HStack(spacing: AppSpacing.md) {
                Button(action: onAddFunds) {
                    Text("Add funds")
                        .font(AppTypography.buttonMedium)
                        .foregroundColor(AppColors.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                Button(action: onRedeem) {
                    Text("Redeem")
                        .font(AppTypography.buttonMedium)
                        .foregroundColor(AppColors.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(AppColors.accentRed)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(AppSpacing.xl)
        .background(AppColors.primaryDark)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl, style: .continuous))
        .darkCardShadow()
    }
}

#Preview {
    WalletCard(balance: 1250.00)
        .padding()
        .background(AppColors.background)
}
