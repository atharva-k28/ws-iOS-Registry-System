//
//  PostEventRecapView.swift
//  iOS_Registry_System
//
//  Post-Event Recap View
//

import SwiftUI

struct CategoryItem: Identifiable {
    let id = UUID()
    let name: String
    let amount: String
    let progress: Double
}

struct ContributorItem: Identifiable {
    let id = UUID()
    let name: String
    let amount: String
    let avatarUrl: String
}

struct PostEventRecapView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showThankYouSheet = false
    
    let categories = [
        CategoryItem(name: "Cookware", amount: "$2,140", progress: 0.9),
        CategoryItem(name: "Tabletop", amount: "$1,560", progress: 0.7),
        CategoryItem(name: "Coffee & Bar", amount: "$1,280", progress: 0.5)
    ]
    
    let contributors = [
        ContributorItem(name: "Maya", amount: "$320", avatarUrl: "https://i.pravatar.cc/150?img=1"),
        ContributorItem(name: "Sofia", amount: "$240", avatarUrl: "https://i.pravatar.cc/150?img=5"),
        ContributorItem(name: "Liam", amount: "$180", avatarUrl: "https://i.pravatar.cc/150?img=8")
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // Header Texts
                VStack(alignment: .leading, spacing: 4) {
                    Text("JUNE 14, 2026 • WEDDING")
                        .font(AppTypography.caption1Medium)
                        .tracking(1.5)
                        .foregroundColor(AppColors.secondaryGray)
                    
                    Text("Olivia & James")
                        .font(.system(size: 32, weight: .regular, design: .serif))
                        .foregroundColor(AppColors.primaryText)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.sm)
                
                // Total Gifted Card
                totalGiftedCard
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                
                // Completion & Wallet Credits Row
                HStack(spacing: AppSpacing.sm) {
                    completionBlock
                    walletBlock
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                
                // Most Loved Categories
                categoriesList
                
                // Top Contributors
                contributorsList
                
                // Send a thank you
                thankYouCard
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                
                Spacer(minLength: 40)
            }
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
                Text("EVENT RECAP")
                    .font(AppTypography.caption1Medium)
                    .tracking(1.5)
                    .foregroundColor(AppColors.secondaryGray)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: MemoryCardView()) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(AppColors.primaryDark)
                        .frame(width: 40, height: 40)
                        .background(AppColors.white)
                        .clipShape(Circle())
                        .softShadow()
                }
            }
        }
        .sheet(isPresented: $showThankYouSheet) {
            ThankYouNoteSheet()
        }
        .overlay(
            VStack {
                Spacer()
                Text("POST-EVENT RECAP")
                    .font(AppTypography.caption1Medium)
                    .tracking(2.0)
                    .foregroundColor(AppColors.secondaryGray)
                    .padding(.bottom, AppSpacing.md)
            }
        )
    }
    
    // MARK: - Subviews
    
    private var totalGiftedCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("TOTAL GIFTED")
                .font(AppTypography.caption1Medium)
                .tracking(1.2)
                .foregroundColor(AppColors.secondaryGray)
            
            HStack(alignment: .bottom, spacing: AppSpacing.sm) {
                Text("$6,840")
                    .font(.system(size: 40, weight: .regular, design: .serif))
                    .foregroundColor(AppColors.white)
                
                HStack(spacing: 2) {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 10, weight: .bold))
                    Text("+24% vs goal")
                        .font(AppTypography.footnote)
                }
                .foregroundColor(AppColors.secondaryGray)
                .padding(.bottom, 6)
            }
            
            Text("From 24 contributors • 58 gifts")
                .font(AppTypography.bodyMedium)
                .foregroundColor(AppColors.secondaryGray)
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.primaryDark)
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .darkCardShadow()
    }
    
    private var completionBlock: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("COMPLETION")
                .font(AppTypography.caption1Medium)
                .tracking(1.2)
                .foregroundColor(AppColors.secondaryGray)
            
            Text("94%")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppColors.backgroundGray)
                        .frame(height: 4)
                    Capsule()
                        .fill(AppColors.accentRed)
                        .frame(width: proxy.size.width * 0.94, height: 4)
                }
            }
            .frame(height: 4)
            .padding(.top, 4)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl, style: .continuous))
        .softShadow()
    }
    
    private var walletBlock: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("WALLET CREDITS")
                .font(AppTypography.caption1Medium)
                .tracking(1.2)
                .foregroundColor(AppColors.secondaryGray)
                .lineLimit(1)
            
            Text("$248")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(AppColors.primaryText)
            
            NavigationLink(destination: WalletCreditsView()) {
                HStack(spacing: 4) {
                    Text("Redeem now")
                    Image(systemName: "arrow.right")
                }
                .font(AppTypography.caption1Medium)
                .foregroundColor(AppColors.primaryText)
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl, style: .continuous))
        .softShadow()
    }
    
    private var categoriesList: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("MOST LOVED CATEGORIES")
                .font(AppTypography.caption1Medium)
                .tracking(1.2)
                .foregroundColor(AppColors.primaryText)
                .padding(.horizontal, AppSpacing.screenHorizontal)
            
            VStack(spacing: AppSpacing.lg) {
                ForEach(categories) { category in
                    VStack(spacing: 8) {
                        HStack {
                            Text(category.name)
                                .font(AppTypography.bodyMedium)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primaryText)
                            Spacer()
                            Text(category.amount)
                                .font(AppTypography.footnote)
                                .foregroundColor(AppColors.secondaryGray)
                        }
                        
                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(AppColors.backgroundGray)
                                    .frame(height: 8)
                                Capsule()
                                    .fill(AppColors.primaryDark)
                                    .frame(width: proxy.size.width * category.progress, height: 8)
                            }
                        }
                        .frame(height: 8)
                    }
                }
            }
            .padding(AppSpacing.lg)
            .background(AppColors.white)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl, style: .continuous))
            .softShadow()
            .padding(.horizontal, AppSpacing.screenHorizontal)
        }
        .padding(.top, AppSpacing.md)
    }
    
    private var contributorsList: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("TOP CONTRIBUTORS")
                .font(AppTypography.caption1Medium)
                .tracking(1.2)
                .foregroundColor(AppColors.primaryText)
                .padding(.horizontal, AppSpacing.screenHorizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.md) {
                    ForEach(contributors) { contributor in
                        VStack(spacing: AppSpacing.sm) {
                            AsyncImage(url: URL(string: contributor.avatarUrl)) { image in
                                image.resizable().scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(width: 56, height: 56)
                            .clipShape(Circle())
                            
                            VStack(spacing: 2) {
                                Text(contributor.name)
                                    .font(AppTypography.bodyMedium)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppColors.primaryText)
                                Text(contributor.amount)
                                    .font(AppTypography.footnote)
                                    .foregroundColor(AppColors.secondaryGray)
                            }
                        }
                        .padding(.vertical, AppSpacing.lg)
                        .padding(.horizontal, AppSpacing.xl)
                        .background(AppColors.white)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl, style: .continuous))
                        .softShadow()
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.bottom, AppSpacing.md)
            }
        }
        .padding(.top, AppSpacing.sm)
    }
    
    private var thankYouCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Send a thank you")
                .font(.system(size: 22, weight: .regular, design: .serif))
                .foregroundColor(AppColors.primaryText)
            
            Text("A personal note to every contributor.")
                .font(AppTypography.bodyMedium)
                .foregroundColor(AppColors.secondaryGray)
            
            Button(action: { showThankYouSheet = true }) {
                Text("Compose notes")
                    .font(AppTypography.buttonMedium)
                    .foregroundColor(AppColors.white)
                    .padding(.horizontal, AppSpacing.xl)
                    .frame(height: 44)
                    .background(AppColors.accentRed)
                    .clipShape(Capsule())
            }
            .padding(.top, AppSpacing.xs)
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.96, green: 0.93, blue: 0.90)) // Soft peach/beige background
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
    }
}

#Preview {
    NavigationStack {
        PostEventRecapView()
    }
}
