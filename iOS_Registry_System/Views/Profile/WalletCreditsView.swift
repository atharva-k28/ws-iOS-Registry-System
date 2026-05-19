//
//  WalletCreditsView.swift
//  iOS_Registry_System
//
//  Wallet & Credits detailed view
//

import SwiftUI
import Supabase

private struct WalletActivityItem: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let amount: String
    let isPositive: Bool
}

struct WalletCreditsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var activities: [WalletActivityItem] = []
    @State private var availableBalance: Double = 0
    @State private var receivedTotal: Double = 0
    @State private var redeemedTotal: Double = 0
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: AppSpacing.lg) {
                walletHeaderCard
                statsBlocks
                recentActivityList
                Spacer(minLength: 40)
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
                Text("WALLET")
                    .font(AppTypography.caption1Medium)
                    .tracking(1.5)
                    .foregroundColor(AppColors.secondaryGray)
            }
        }
        .overlay(
            VStack {
                Spacer()
                Text("WALLET & CREDITS")
                    .font(AppTypography.caption1Medium)
                    .tracking(2.0)
                    .foregroundColor(AppColors.secondaryGray)
                    .padding(.bottom, AppSpacing.md)
            }
        )
        .task {
            await loadWalletCredits()
        }
    }

    private var walletHeaderCard: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("GIFT CONTINUATION")
                .font(AppTypography.caption1Medium)
                .tracking(1.2)
                .foregroundColor(AppColors.secondaryGray)
                .padding(.bottom, 2)

            Text(CurrencyFormatter.format(availableBalance))
                .font(.system(size: 48, weight: .regular, design: .serif))
                .foregroundColor(AppColors.white)

            Text("From the generosity of friends")
                .font(AppTypography.bodyMedium)
                .foregroundColor(AppColors.secondaryGray)
        }
        .padding(AppSpacing.xl)
        .background(
            LinearGradient(
                colors: [Color(hex: "3A3632"), Color(hex: "2A2826")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .darkCardShadow()
    }

    private var statsBlocks: some View {
        HStack(spacing: AppSpacing.sm) {
            statItem(value: compactCurrency(receivedTotal), label: "Received")
            statItem(value: compactCurrency(redeemedTotal), label: "Redeemed")
            statItem(value: compactCurrency(availableBalance), label: "Available")
        }
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: AppSpacing.xxs) {
            Text(value)
                .font(AppTypography.title2)
                .fontWeight(.bold)
                .foregroundStyle(AppColors.primaryText)
            Text(label)
                .font(AppTypography.caption1)
                .foregroundStyle(AppColors.secondaryGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.lg)
        .background(AppColors.white)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg, style: .continuous))
        .softShadow()
    }

    private var recentActivityList: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("RECENT ACTIVITY")
                .font(AppTypography.caption1Medium)
                .tracking(1.2)
                .foregroundColor(AppColors.primaryText)
                .padding(.top, AppSpacing.sm)
                .padding(.bottom, AppSpacing.xs)

            if isLoading {
                InlineLoadingView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.xl)
                    .background(AppColors.white)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl, style: .continuous))
                    .softShadow()
            } else if activities.isEmpty {
                EmptyStateView(
                    systemImageName: "wallet.pass",
                    title: "No Wallet Activity",
                    description: errorMessage ?? "Credits from registry activity will appear here."
                )
            } else {
                VStack(spacing: 0) {
                    ForEach(activities.indices, id: \.self) { index in
                        let activity = activities[index]
                        HStack(spacing: AppSpacing.md) {
                            Circle()
                                .fill(AppColors.backgroundGray)
                                .frame(width: 44, height: 44)
                                .overlay {
                                    Image(systemName: activity.isPositive ? "arrow.down.left" : "arrow.up.right")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(AppColors.primaryDark)
                                }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(activity.title)
                                    .font(AppTypography.bodyMedium)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppColors.primaryText)
                                Text(activity.subtitle)
                                    .font(AppTypography.footnote)
                                    .foregroundColor(AppColors.secondaryGray)
                            }

                            Spacer()

                            Text(activity.amount)
                                .font(AppTypography.bodyMedium)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primaryText)
                        }
                        .padding(.vertical, AppSpacing.md)

                        if index < activities.count - 1 {
                            Divider().padding(.leading, 60)
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.md)
                .background(AppColors.white)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xl, style: .continuous))
                .softShadow()
            }
        }
    }

    private func loadWalletCredits() async {
        guard let userId = AuthService.shared.currentUser?.id else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let eventResponse = try await SupabaseManager.shared.client
                .from("events")
                .select("id")
                .eq("owner_user_id", value: userId.uuidString)
                .execute()

            struct EventRow: Decodable { let id: UUID }
            let eventIds = try JSONDecoder().decode([EventRow].self, from: eventResponse.data).map(\.id)
            guard !eventIds.isEmpty else {
                resetWallet()
                return
            }

            let registryResponse = try await SupabaseManager.shared.client
                .from("registries")
                .select("id")
                .in("event_id", values: eventIds.map(\.uuidString))
                .execute()

            struct RegistryRow: Decodable { let id: UUID }
            let registryIds = try JSONDecoder().decode([RegistryRow].self, from: registryResponse.data).map(\.id)
            guard !registryIds.isEmpty else {
                resetWallet()
                return
            }

            let creditsResponse = try await SupabaseManager.shared.client
                .from("wallet_credits")
                .select("id,amount,status,created_at,redeemed_at")
                .in("registry_id", values: registryIds.map(\.uuidString))
                .execute()

            struct CreditRow: Decodable {
                let id: UUID
                let amount: Double
                let status: String?
                let createdAt: Date?
                let redeemedAt: Date?

                enum CodingKeys: String, CodingKey {
                    case id
                    case amount
                    case status
                    case createdAt = "created_at"
                    case redeemedAt = "redeemed_at"
                }
            }

            let credits = try dateDecoder.decode([CreditRow].self, from: creditsResponse.data)
            receivedTotal = credits.reduce(0) { $0 + $1.amount }
            redeemedTotal = credits.filter { $0.status == "redeemed" }.reduce(0) { $0 + $1.amount }
            availableBalance = credits.filter { $0.status != "redeemed" }.reduce(0) { $0 + $1.amount }
            activities = credits
                .sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
                .map { credit in
                    let isRedeemed = credit.status == "redeemed"
                    let date = (isRedeemed ? credit.redeemedAt : credit.createdAt)?
                        .formatted(date: .abbreviated, time: .omitted) ?? "Date unavailable"
                    return WalletActivityItem(
                        id: credit.id,
                        title: isRedeemed ? "Redeemed credit" : "Wallet credit",
                        subtitle: date,
                        amount: "\(isRedeemed ? "-" : "+")\(CurrencyFormatter.format(credit.amount))",
                        isPositive: !isRedeemed
                    )
                }
        } catch {
            resetWallet()
            errorMessage = error.localizedDescription
        }
    }

    private func resetWallet() {
        availableBalance = 0
        receivedTotal = 0
        redeemedTotal = 0
        activities = []
    }

    private var dateDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)

            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = isoFormatter.date(from: dateStr) {
                return date
            }

            isoFormatter.formatOptions = [.withInternetDateTime]
            if let date = isoFormatter.date(from: dateStr) {
                return date
            }

            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateStr)")
        }
        return decoder
    }

    private func compactCurrency(_ amount: Double) -> String {
        if amount >= 1_000 {
            return String(format: "$%.1fk", amount / 1_000)
        }
        return CurrencyFormatter.format(amount)
    }
}

#Preview {
    NavigationStack {
        WalletCreditsView()
    }
}
