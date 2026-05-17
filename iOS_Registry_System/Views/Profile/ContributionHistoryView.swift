//
//  ContributionHistoryView.swift
//  iOS_Registry_System
//
//  Dedicated screen for viewing past contributions
//

import SwiftUI

struct ContributionHistoryItem: Identifiable {
    let id = UUID()
    let eventName: String
    let giftName: String
    let amount: String
    let date: String
    let imageUrl: String
}

struct ContributionHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    
    let contributions = [
        ContributionHistoryItem(eventName: "Emma & Noah's Wedding", giftName: "Le Creuset Dutch Oven", amount: "$150", date: "Jun 14, 2026", imageUrl: "https://images.unsplash.com/photo-1585837146751-a44117eb2ee4?w=200&q=80"),
        ContributionHistoryItem(eventName: "Sarah's Housewarming", giftName: "Vitamix Pro", amount: "$80", date: "May 02, 2026", imageUrl: "https://images.unsplash.com/photo-1596541603953-29a59b5896a2?w=200&q=80"),
        ContributionHistoryItem(eventName: "Baby Shower for James", giftName: "Nursery Glider", amount: "$120", date: "Apr 18, 2026", imageUrl: "https://images.unsplash.com/photo-1588854337236-6889d631faa8?w=200&q=80")
    ]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                
                Text("Your history of\ngiving.")
                    .font(.system(size: 32, weight: .regular, design: .serif))
                    .foregroundStyle(AppColors.primaryText)
                    .lineSpacing(3)
                    .padding(.top, AppSpacing.sm)
                
                VStack(spacing: AppSpacing.md) {
                    ForEach(contributions) { item in
                        contributionRow(item: item)
                    }
                }
                
                Color.clear.frame(height: 40)
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
                Text("CONTRIBUTION HISTORY")
                    .font(AppTypography.caption1Medium)
                    .tracking(1.5)
                    .foregroundColor(AppColors.secondaryGray)
            }
        }
    }
    
    private func contributionRow(item: ContributionHistoryItem) -> some View {
        HStack(spacing: AppSpacing.md) {
            AsyncImage(url: URL(string: item.imageUrl)) { img in
                img.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.eventName)
                    .font(AppTypography.caption1Medium)
                    .foregroundColor(AppColors.secondaryGray)
                
                Text(item.giftName)
                    .font(AppTypography.bodyMedium)
                    .foregroundColor(AppColors.primaryText)
                    .lineLimit(1)
                
                HStack {
                    Text(item.amount)
                        .font(AppTypography.bodyMedium)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primaryDark)
                    Spacer()
                    Text(item.date)
                        .font(AppTypography.footnote)
                        .foregroundColor(AppColors.secondaryGray)
                }
                .padding(.top, 2)
            }
        }
        .padding(AppSpacing.sm)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
        .softShadow()
    }
}

#Preview {
    NavigationStack {
        ContributionHistoryView()
    }
}
