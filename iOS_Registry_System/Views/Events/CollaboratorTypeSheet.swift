//
//  CollaboratorTypeSheet.swift
//  iOS_Registry_System
//
//  Screen 2 — Role picker sheet
//

import SwiftUI

struct CollaboratorTypeSheet: View {

    @Binding var selectedRole: CollaboratorRole?
    var onContinue: (CollaboratorRole) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 6) {
                Text("Plan together")
                    .font(.system(size: 26, weight: .regular, design: .serif))
                    .foregroundStyle(AppColors.primaryText)
                Text("Choose how this person will help with your event.")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.secondaryGray)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, AppSpacing.xl)
            .padding(.horizontal, AppSpacing.screenHorizontal)

            // Role cards
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(CollaboratorRole.allCases) { role in
                        roleCard(role: role)
                    }

                    // Continue Solo
                    soloCard
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.vertical, AppSpacing.lg)
            }

            // CTA
            Button {
                if let role = selectedRole {
                    onContinue(role)
                }
            } label: {
                Text("Continue")
                    .font(AppTypography.buttonLarge)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        selectedRole != nil
                        ? AnyShapeStyle(AppColors.accentRed)
                        : AnyShapeStyle(AppColors.secondaryGray)
                    )
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(selectedRole == nil)
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.bottom, AppSpacing.xxl)
            .animation(.spring(response: 0.3), value: selectedRole)
        }
        .appBackground()
    }

    // MARK: - Role Card

    private func roleCard(role: CollaboratorRole) -> some View {
        let isSelected = selectedRole == role

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedRole = role
            }
        } label: {
            HStack(spacing: AppSpacing.md) {
                // Icon circle
                ZStack {
                    Circle()
                        .fill(isSelected ? AppColors.white.opacity(0.2) : AppColors.backgroundGray)
                        .frame(width: 48, height: 48)
                    Image(systemName: role.icon)
                        .font(.system(size: 20))
                        .foregroundStyle(isSelected ? .white : AppColors.primaryText)
                }

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(role.rawValue)
                        .font(AppTypography.headline)
                        .foregroundStyle(isSelected ? .white : AppColors.primaryText)
                    Text(role.description)
                        .font(AppTypography.footnote)
                        .foregroundStyle(isSelected ? .white.opacity(0.8) : AppColors.secondaryGray)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .fill(isSelected ? AnyShapeStyle(AppColors.primaryText) : AnyShapeStyle(AppColors.white))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .stroke(isSelected ? Color.clear : Color.black.opacity(0.06), lineWidth: 1)
            )
            .shadow(
                color: isSelected ? AppColors.primaryText.opacity(0.2) : .black.opacity(0.04),
                radius: isSelected ? 12 : 4,
                y: isSelected ? 4 : 2
            )
        }
        .buttonStyle(.plain)
    }

    private var soloCard: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                selectedRole = nil
                dismiss()
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Continue Solo")
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.primaryText)
                    Text("You can add collaborators any time later.")
                        .font(AppTypography.caption1)
                        .foregroundStyle(AppColors.secondaryGray)
                }
                Spacer()
            }
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .stroke(Color.black.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview("Role Sheet") {
    CollaboratorTypeSheet(selectedRole: .constant(.partner)) { _ in }
}
