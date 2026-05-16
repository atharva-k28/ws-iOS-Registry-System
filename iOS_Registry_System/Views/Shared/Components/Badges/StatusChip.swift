//
//  StatusChip.swift
//  iOS_Registry_System
//
//  Reusable chip component for categories and tags
//

import SwiftUI

struct StatusChip: View {
    let title: String
    var icon: String? = nil
    var isSelected: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        Group {
            if let action = action {
                Button(action: action) {
                    chipContent
                }
                .buttonStyle(.plain)
            } else {
                chipContent
            }
        }
    }

    private var chipContent: some View {
        HStack(spacing: AppSpacing.xxs) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .medium))
            }
            Text(title)
                .font(AppTypography.caption1Medium)
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(isSelected ? AppColors.primaryDark : AppColors.white)
        .foregroundColor(isSelected ? AppColors.white : AppColors.primaryText)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm, style: .continuous))
        .overlay {
            if !isSelected {
                RoundedRectangle(cornerRadius: AppCornerRadius.sm, style: .continuous)
                    .strokeBorder(AppColors.backgroundGray, lineWidth: 1)
            }
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        StatusChip(title: "All", isSelected: true)
        StatusChip(title: "Wedding", icon: "heart.fill")
        StatusChip(title: "Baby", icon: "stroller.fill")
    }
    .padding()
    .background(AppColors.background)
}
