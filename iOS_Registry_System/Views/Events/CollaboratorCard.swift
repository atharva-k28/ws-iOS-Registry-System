//
//  CollaboratorCard.swift
//  iOS_Registry_System
//
//  Screens 4 & 5 — Collaborator card component.
//  Shows pending state, active state, and multi-collaborator stack.
//

import SwiftUI

// MARK: - Single Collaborator Card

struct CollaboratorCard: View {

    let collaborator: Collaborator
    var onManage: (() -> Void)?
    var onResend: (() -> Void)?
    @State private var showManageAccess = false
    @State private var mutablePermissions: CollaboratorPermissions

    init(collaborator: Collaborator, onManage: (() -> Void)? = nil, onResend: (() -> Void)? = nil) {
        self.collaborator = collaborator
        self.onManage = onManage
        self.onResend = onResend
        _mutablePermissions = State(initialValue: collaborator.permissions)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // Header row
            HStack(spacing: AppSpacing.sm) {
                // Avatar
                AsyncImage(url: URL(string: collaborator.avatarURL ?? "")) { img in
                    img.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle().fill(AppColors.backgroundGray)
                        .overlay(
                            Text(String(collaborator.name.prefix(1)))
                                .font(AppTypography.headline)
                                .foregroundStyle(AppColors.secondaryGray)
                        )
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())

                // Name + role
                VStack(alignment: .leading, spacing: 3) {
                    Text(collaborator.name)
                        .font(AppTypography.bodyMedium)
                        .foregroundStyle(AppColors.primaryText)
                    HStack(spacing: 6) {
                        Text(collaborator.role.rawValue)
                            .font(AppTypography.caption1)
                            .foregroundStyle(AppColors.secondaryGray)
                        Text("·")
                            .foregroundStyle(AppColors.secondaryGray)
                        statusBadge
                    }
                }
                Spacer()

                // Status dot
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
            }

            // MARK: Pending state
            if collaborator.status == .pending {
                Text("Waiting for response…")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.secondaryGray)
                    .italic()

                HStack(spacing: AppSpacing.sm) {
                    Button {
                        onResend?()
                    } label: {
                        Text("Resend")
                            .font(AppTypography.buttonSmall)
                            .foregroundStyle(AppColors.primaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                                    .stroke(Color.black.opacity(0.12), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)

                    Button {
                        showManageAccess = true
                    } label: {
                        Text("Manage")
                            .font(AppTypography.buttonSmall)
                            .foregroundStyle(AppColors.primaryText)
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(AppColors.backgroundGray)
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                    }
                    .buttonStyle(.plain)
                }
            }

            // MARK: Active state
            if collaborator.status == .active {
                // Access summary pills
                let summary = collaborator.accessSummary
                if !summary.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Can manage:")
                            .font(AppTypography.caption1)
                            .foregroundStyle(AppColors.secondaryGray)
                        HStack(spacing: 6) {
                            ForEach(summary, id: \.self) { item in
                                Text(item)
                                    .font(AppTypography.caption1Medium)
                                    .foregroundStyle(AppColors.primaryText)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule().fill(AppColors.backgroundGray)
                                    )
                            }
                        }
                    }
                }

                Button {
                    showManageAccess = true
                } label: {
                    Text("Manage Access")
                        .font(AppTypography.buttonSmall)
                        .foregroundStyle(AppColors.accentRed)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                                .stroke(AppColors.accentRed.opacity(0.3), lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
            }

            // MARK: Declined / Expired
            if collaborator.status == .declined || collaborator.status == .expired {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 13))
                        .foregroundStyle(AppColors.accentRed)
                    Text(collaborator.status == .declined ? "Invite was declined." : "Invite expired.")
                        .font(AppTypography.footnote)
                        .foregroundStyle(AppColors.accentRed)
                }

                Button {
                    onResend?()
                } label: {
                    Text("Send Again")
                        .font(AppTypography.buttonSmall)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(AppColors.accentRed)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                .stroke(
                    collaborator.status == .active
                        ? Color(hex: "34C759").opacity(0.2)
                        : collaborator.status == .pending
                        ? Color(hex: "FF9500").opacity(0.2)
                        : Color.clear,
                    lineWidth: 1.5
                )
        )
        .softShadow()
        .sheet(isPresented: $showManageAccess) {
            ManageAccessView(role: collaborator.role, permissions: $mutablePermissions)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(32)
        }
    }

    private var statusBadge: some View {
        Text(collaborator.status.rawValue)
            .font(AppTypography.caption1Medium)
            .foregroundStyle(statusColor)
    }

    private var statusColor: Color {
        switch collaborator.status {
        case .active:   return Color(hex: "34C759")
        case .pending:  return Color(hex: "FF9500")
        case .declined: return AppColors.accentRed
        case .expired:  return AppColors.secondaryGray
        }
    }
}

// MARK: - Multi Collaborator Stack

struct CollaboratorStack: View {

    let collaborators: [Collaborator]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            // Stacked avatars header
            HStack(spacing: -10) {
                ForEach(Array(collaborators.prefix(4).enumerated()), id: \.element.id) { i, c in
                    AsyncImage(url: URL(string: c.avatarURL ?? "")) { img in
                        img.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle().fill(AppColors.backgroundGray)
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(AppColors.white, lineWidth: 2))
                    .zIndex(Double(4 - i))
                }
                if collaborators.count > 4 {
                    Circle()
                        .fill(AppColors.backgroundGray)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text("+\(collaborators.count - 4)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(AppColors.secondaryGray)
                        )
                        .overlay(Circle().stroke(AppColors.white, lineWidth: 2))
                }
                Text("\(collaborators.count) collaborator\(collaborators.count == 1 ? "" : "s")")
                    .font(AppTypography.footnote)
                    .foregroundStyle(AppColors.secondaryGray)
                    .padding(.leading, 16)
            }

            ForEach(collaborators) { collaborator in
                CollaboratorCard(collaborator: collaborator)
            }
        }
    }
}

// MARK: - Preview

#Preview("Pending State") {
    VStack(spacing: 16) {
        CollaboratorCard(collaborator: .mockPending)
        CollaboratorCard(collaborator: .mockActive)
    }
    .padding()
    .background(AppColors.background)
}
