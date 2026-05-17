//
//  SettingsDetailView.swift
//  iOS_Registry_System
//
//  Generic detail view for settings sub-pages
//

import SwiftUI

struct SettingsDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: AppSpacing.lg) {
                // Placeholder content
                Image(systemName: "gearshape.2")
                    .font(.system(size: 60))
                    .foregroundStyle(AppColors.secondaryGray.opacity(0.3))
                    .padding(.top, 60)
                
                Text("\(title) Settings")
                    .font(.system(size: 24, weight: .regular, design: .serif))
                    .foregroundStyle(AppColors.primaryText)
                    .multilineTextAlignment(.center)
                
                Text("This is a placeholder view for the \(title) configuration. Here you would find toggles, forms, or related settings.")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.secondaryGray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xl)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
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
                Text(title.uppercased())
                    .font(AppTypography.caption1Medium)
                    .tracking(1.5)
                    .foregroundColor(AppColors.secondaryGray)
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsDetailView(title: "Notifications")
    }
}
