//
//  GlassButton.swift
//  iOS_Registry_System
//
//  Translucent "liquid glass" style circular button for navigation
//

import SwiftUI

struct GlassButton: View {
    let icon: String
    let action: () -> Void
    let useSFWeight: Font.Weight
    let iconSize: CGFloat

    init(icon: String, useSFWeight: Font.Weight = .semibold, iconSize: CGFloat = 16, action: @escaping () -> Void) {
        self.icon = icon
        self.useSFWeight = useSFWeight
        self.iconSize = iconSize
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: iconSize, weight: useSFWeight))
                .foregroundColor(AppColors.primaryDark)
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.2), lineWidth: 0.5)
                )
                .softShadow()
        }
        .buttonStyle(.plain)
    }
}
