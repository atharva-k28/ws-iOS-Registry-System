//
//  RegistryHealthSheet.swift
//  iOS_Registry_System
//
//  Premium AI-powered Registry Health Analyzer Sheet
//

import SwiftUI

struct RegistryHealthSheet: View {
    let items: [PriorityGiftItem]
    @Environment(\.dismiss) private var dismiss
    
    @State private var result: AIService.RegistryHealthResult? = nil
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isLoading {
                    loadingView
                } else if let res = result {
                    resultsContent(res)
                }
            }
            .appBackground()
            .navigationTitle("Registry Health")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.accentRed)
                }
            }
            .task {
                result = await AIService.shared.analyzeRegistry(items: items)
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: AppSpacing.md) {
            ProgressView()
                .tint(AppColors.accentRed)
                .scaleEffect(1.5)
            Text("Analyzing your registry...")
                .font(AppTypography.bodyMedium)
                .foregroundStyle(AppColors.secondaryGray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func resultsContent(_ res: AIService.RegistryHealthResult) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: AppSpacing.xl) {
                // Score gauge card
                scoreGaugeCard(score: res.score)
                
                // Strengths
                sectionCard(title: "Strengths", icon: "checkmark.circle.fill", iconColor: Color(hex: "34C759"), items: res.strengths)
                
                // Weaknesses
                sectionCard(title: "Areas to Improve", icon: "exclamationmark.triangle.fill", iconColor: Color(hex: "FF9500"), items: res.weaknesses)
                
                // Suggestions
                sectionCard(title: "AI Recommendations", icon: "sparkles", iconColor: AppColors.accentRed, items: res.suggestions)
                
                Color.clear.frame(height: AppSpacing.lg)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.md)
        }
    }
    
    private func scoreGaugeCard(score: Int) -> some View {
        VStack(spacing: AppSpacing.sm) {
            ZStack {
                Circle()
                    .stroke(AppColors.backgroundGray, lineWidth: 10)
                    .frame(width: 100, height: 100)
                
                Circle()
                    .trim(from: 0, to: CGFloat(score) / 100.0)
                    .stroke(
                        AngularGradient(
                            colors: [AppColors.accentRed, Color(hex: "34C759")],
                            center: .center,
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270)
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 2) {
                    Text("\(score)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.primaryText)
                    Text("/100")
                        .font(AppTypography.caption2)
                        .foregroundStyle(AppColors.secondaryGray)
                }
            }
            
            Text("REGISTRY HEALTH SCORE")
                .font(AppTypography.caption1Medium)
                .tracking(1.5)
                .foregroundStyle(AppColors.secondaryGray)
                .padding(.top, 4)
            
            Text(scoreStatus(score))
                .font(AppTypography.headline)
                .foregroundStyle(scoreColor(score))
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
        .softShadow()
    }
    
    private func sectionCard(title: String, icon: String, iconColor: Color, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(iconColor)
                Text(title.uppercased())
                    .font(AppTypography.caption1Medium)
                    .tracking(1.5)
                    .foregroundStyle(AppColors.primaryText)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                ForEach(items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 10) {
                        Text("•")
                            .font(.system(size: 16))
                            .foregroundStyle(iconColor)
                        Text(item)
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.secondaryGray)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
        .softShadow()
    }
    
    private func scoreStatus(_ score: Int) -> String {
        if score >= 85 { return "Excellent" }
        if score >= 70 { return "Looking Good" }
        return "Needs Attention"
    }
    
    private func scoreColor(_ score: Int) -> Color {
        if score >= 85 { return Color(hex: "34C759") }
        if score >= 70 { return Color(hex: "FF9500") }
        return AppColors.accentRed
    }
}
