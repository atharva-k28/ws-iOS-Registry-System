//
//  WalletCreditsView.swift
//  iOS_Registry_System
//
//  Wallet & Credits detailed view
//

import SwiftUI

struct ActivityItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let amount: String
    let isPositive: Bool
}

struct WalletCreditsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showAddFunds = false
    @State private var showRedeem = false
    
    let activities = [
        ActivityItem(title: "Maya contributed", subtitle: "Espresso machine • Today", amount: "+$50", isPositive: true),
        ActivityItem(title: "Redeemed credit", subtitle: "Citron dinner set • Yesterday", amount: "-$48", isPositive: false),
        ActivityItem(title: "Sofia contributed", subtitle: "Stainless set • May 14", amount: "+$100", isPositive: true),
        ActivityItem(title: "Group refund", subtitle: "Leftover funds • May 10", amount: "+$30", isPositive: true)
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: AppSpacing.lg) {
                // MARK: - Dark Header Card
                walletHeaderCard
                
                // MARK: - Arriving Soon
                arrivingSoonBlock
                
                // MARK: - Stats
                statsBlocks
                
                // MARK: - Recent Activity
                recentActivityList
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.md)
        }
        .appBackground()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(AppColors.primaryText)
                        .frame(width: 36, height: 36)
                        .background(
                            Circle()
                                .fill(AppColors.white)
                                .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
                        )
                }
                .buttonStyle(.plain)
            }
            ToolbarItem(placement: .principal) {
                Text("WALLET")
                    .font(AppTypography.caption1Medium)
                    .tracking(1.5)
                    .foregroundColor(AppColors.secondaryGray)
            }
        }
        .overlay(
            VStack {
                Spacer()
                Text("WALLET & CREDITS")
                    .font(AppTypography.caption1Medium)
                    .tracking(2.0)
                    .foregroundColor(AppColors.secondaryGray)
                    .padding(.bottom, AppSpacing.md)
            }
        )
        .sheet(isPresented: $showAddFunds) {
            VStack(spacing: AppSpacing.lg) {
                Text("Add Funds")
                    .font(AppTypography.title2)
                Text("Simulate adding funds via Apple Pay or Credit Card here.")
                    .font(AppTypography.body)
                    .multilineTextAlignment(.center)
                    .padding()
                Button("Done") { showAddFunds = false }
                    .buttonStyle(.borderedProminent)
            }
            .presentationDetents([.medium])
        }
        .alert("Redeem Credits", isPresented: $showRedeem) {
            Button("Redeem to Bank", role: .none) {}
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Transfer your available $248.50 balance to your linked bank account.")
        }
    }
    
    // MARK: - Subviews
    
    private var walletHeaderCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("GIFT CONTINUATION")
                .font(AppTypography.caption1Medium)
                .tracking(1.2)
                .foregroundColor(AppColors.secondaryGray)
                .padding(.bottom, 2)
            
            Text("$248.50")
                .font(.system(size: 48, weight: .regular, design: .serif))
                .foregroundColor(AppColors.white)
            
            Text("From the generosity of friends")
                .font(AppTypography.bodyMedium)
                .foregroundColor(AppColors.secondaryGray)
                .padding(.bottom, AppSpacing.md)
            
            HStack(spacing: AppSpacing.md) {
                Button(action: { showAddFunds = true }) {
                    HStack {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                        Text("Add funds")
                    }
                    .font(AppTypography.buttonMedium)
                    .foregroundColor(AppColors.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Capsule())
                }
                
                Button(action: { showRedeem = true }) {
                    HStack {
                        Image(systemName: "gift")
                            .font(.system(size: 14, weight: .bold))
                        Text("Redeem")
                    }
                    .font(AppTypography.buttonMedium)
                    .foregroundColor(AppColors.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(AppColors.accentRed)
                    .clipShape(Capsule())
                }
            }
        }
        .padding(AppSpacing.xl)
        .background(
            LinearGradient(
                colors: [Color(hex: "3A3632"), Color(hex: "2A2826")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .darkCardShadow()
    }
    
    private var arrivingSoonBlock: some View {
        HStack(spacing: AppSpacing.md) {
            Circle()
                .fill(AppColors.backgroundGray)
                .frame(width: 44, height: 44)
                .overlay {
                    Image(systemName: "arrow.down.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppColors.primaryDark)
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("$80 arriving soon")
                    .font(AppTypography.bodyMedium)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primaryText)
                Text("A group gift completes in 2 days")
                    .font(AppTypography.footnote)
                    .foregroundColor(AppColors.secondaryGray)
            }
            Spacer()
        }
        .padding(AppSpacing.md)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl, style: .continuous))
        .softShadow()
    }
    
    private var statsBlocks: some View {
        HStack(spacing: AppSpacing.sm) {
            statItem(value: "$1,820", label: "Received")
            statItem(value: "$1,572", label: "Spent")
            statItem(value: "$248", label: "Available")
        }
    }
    
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: AppSpacing.xxs) {
            Text(value)
                .font(AppTypography.title2)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.primaryText)
            Text(label)
                .font(AppTypography.caption1)
                .foregroundStyle(AppColors.secondaryGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
        .softShadow()
    }
    
    private var recentActivityList: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("RECENT ACTIVITY")
                .font(AppTypography.caption1Medium)
                .tracking(1.2)
                .foregroundColor(AppColors.primaryText)
                .padding(.top, AppSpacing.sm)
                .padding(.bottom, AppSpacing.xs)
            
            VStack(spacing: 0) {
                ForEach(activities.indices, id: \.self) { index in
                    let activity = activities[index]
                    HStack(spacing: AppSpacing.md) {
                        Circle()
                            .fill(AppColors.backgroundGray)
                            .frame(width: 44, height: 44)
                            .overlay {
                                Image(systemName: activity.isPositive ? "arrow.down.left" : "arrow.up.right")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(AppColors.primaryDark)
                            }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(activity.title)
                                .font(AppTypography.bodyMedium)
                                .fontWeight(.semibold)
                                .foregroundColor(AppColors.primaryText)
                            Text(activity.subtitle)
                                .font(AppTypography.footnote)
                                .foregroundColor(AppColors.secondaryGray)
                        }
                        
                        Spacer()
                        
                        Text(activity.amount)
                            .font(AppTypography.bodyMedium)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.primaryText)
                    }
                    .padding(.vertical, AppSpacing.md)
                    
                    if index < activities.count - 1 {
                        Divider().padding(.leading, 60)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .background(AppColors.white)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl, style: .continuous))
            .softShadow()
        }
    }
}

#Preview {
    NavigationStack {
        WalletCreditsView()
    }
}
