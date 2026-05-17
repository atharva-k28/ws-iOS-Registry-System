//
//  ContributorsListView.swift
//  iOS_Registry_System
//
//  Screen 5 — full contributor list with timestamps and amounts.
//  Accessible from tapping "friends" stat on GroupGiftDetailView.
//

import SwiftUI

// MARK: - Contributors List View

struct ContributorsListView: View {

    let gift: PriorityGiftItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {

                // Progress summary header
                progressHeader

                // Total stat row
                statRow

                // Contributors section
                VStack(alignment: .leading, spacing: AppSpacing.sectionHeaderGap) {
                    Text("CONTRIBUTORS")
                        .font(AppTypography.caption1Medium)
                        .tracking(1.5)
                        .foregroundStyle(AppColors.primaryText)
                        .padding(.horizontal, AppSpacing.screenHorizontal)

                    VStack(spacing: 0) {
                        ForEach(gift.contributors) { contributor in
                            ContributorRow(contributor: contributor)

                            if contributor.id != gift.contributors.last?.id {
                                Divider()
                                    .padding(.leading, 72)
                            }
                        }
                    }
                    .background(AppColors.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
                    .softShadow()
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                }

                Color.clear.frame(height: AppSpacing.xxl)
            }
            .padding(.top, AppSpacing.lg)
        }
        .appBackground()
        .navigationTitle("Who Joined")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppColors.primaryText)
                        .frame(width: 38, height: 38)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 0.5))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        VStack(alignment: .center, spacing: AppSpacing.sm) {
            ZStack {
                Circle()
                    .stroke(AppColors.backgroundGray, lineWidth: 8)
                    .frame(width: 90, height: 90)

                Circle()
                    .trim(from: 0, to: CGFloat(gift.progress))
                    .stroke(AppColors.accentRed, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(gift.percentFunded)%")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.primaryText)
                    Text("funded")
                        .font(AppTypography.caption2)
                        .foregroundStyle(AppColors.secondaryGray)
                }
            }

            Text(gift.title)
                .font(AppTypography.title3)
                .foregroundStyle(AppColors.primaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
    }

    // MARK: - Stat Row

    private var statRow: some View {
        HStack(spacing: AppSpacing.sm) {
            miniStat(value: "$\(Int(gift.currentAmount))", label: "raised")
            miniStat(value: "$\(Int(gift.amountToGo))",   label: "to go")
            miniStat(value: "\(gift.contributorCount)",   label: "friends")
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
    }

    private func miniStat(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(AppTypography.title3)
                .foregroundStyle(AppColors.primaryText)
            Text(label)
                .font(AppTypography.caption1)
                .foregroundStyle(AppColors.secondaryGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
        .cardStyle()
    }
}

// MARK: - Preview

#Preview("Contributors List") {
    NavigationStack {
        ContributorsListView(gift: .espressoMachine)
    }
}
