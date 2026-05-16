//
//  AppHeader.swift
//  iOS_Registry_System
//
//  Reusable section and screen header
//

import SwiftUI

struct AppHeader: View {
    let title: String
    var subtitle: String? = nil
    var trailingIcon: String? = nil
    var trailingAction: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(title)
                    .font(AppTypography.largeTitleSerif)
                    .foregroundColor(AppColors.primaryDark)
                
                if let subtitle {
                    Text(subtitle)
                        .font(AppTypography.subheadline)
                        .foregroundColor(AppColors.secondaryGray)
                }
            }
            
            Spacer()
            
            if let trailingIcon {
                Button(action: {
                    trailingAction?()
                }) {
                    Image(systemName: trailingIcon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(AppColors.primaryDark)
                        .frame(width: 44, height: 44)
                        .background(AppColors.white)
                        .clipShape(Circle())
                        .softShadow()
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, AppSpacing.sm)
        .padding(.bottom, AppSpacing.xs)
    }
}

#Preview {
    ZStack {
        AppColors.background.ignoresSafeArea()
        VStack {
            AppHeader(
                title: "My Events",
                subtitle: "Manage your registries",
                trailingIcon: "plus"
            )
            Spacer()
        }
    }
}
