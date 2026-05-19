//
//  ContributionHistoryView.swift
//  iOS_Registry_System
//
//  Dedicated screen for viewing past contributions
//

import SwiftUI
import Supabase

private struct ContributionHistoryItem: Identifiable {
    let id: UUID
    let eventName: String
    let giftName: String
    let amount: String
    let date: String
    let imageUrl: String?
}

struct ContributionHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var contributions: [ContributionHistoryItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text("Your history of\ngiving.")
                    .font(.system(size: 32, weight: .regular, design: .serif))
                    .foregroundStyle(AppColors.primaryText)
                    .lineSpacing(3)
                    .padding(.top, AppSpacing.sm)

                if isLoading {
                    InlineLoadingView()
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                } else if contributions.isEmpty {
                    EmptyStateView(
                        systemImageName: "gift",
                        title: "No Contributions",
                        description: errorMessage ?? "Gift contributions you make will appear here."
                    )
                } else {
                    VStack(spacing: AppSpacing.md) {
                        ForEach(contributions) { item in
                            contributionRow(item: item)
                        }
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
        .task {
            await loadContributions()
        }
    }

    private func contributionRow(item: ContributionHistoryItem) -> some View {
        HStack(spacing: AppSpacing.md) {
            AsyncImage(url: item.imageUrl.flatMap(URL.init(string:))) { img in
                img.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                AppColors.backgroundGray
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.eventName)
                    .font(AppTypography.caption1Medium)
                    .foregroundColor(AppColors.secondaryGray)
                    .lineLimit(1)

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

    private func loadContributions() async {
        guard let userId = AuthService.shared.currentUser?.id else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await SupabaseManager.shared.client
                .from("contributions")
                .select("id,amount,created_at,gift_reservations(registry_items(item_name,image_url,registries(events(title))))")
                .eq("contributor_by", value: userId.uuidString)
                .order("created_at", ascending: false)
                .execute()

            struct ContributionRow: Decodable {
                let id: UUID
                let amount: Double
                let createdAt: Date?
                let giftReservations: ReservationRow?

                enum CodingKeys: String, CodingKey {
                    case id
                    case amount
                    case createdAt = "created_at"
                    case giftReservations = "gift_reservations"
                }
            }

            struct ReservationRow: Decodable {
                let registryItems: RegistryItemRow?

                enum CodingKeys: String, CodingKey {
                    case registryItems = "registry_items"
                }
            }

            struct RegistryItemRow: Decodable {
                let itemName: String?
                let imageUrl: String?
                let registries: RegistryRow?

                enum CodingKeys: String, CodingKey {
                    case itemName = "item_name"
                    case imageUrl = "image_url"
                    case registries
                }
            }

            struct RegistryRow: Decodable {
                let events: EventRow?
            }

            struct EventRow: Decodable {
                let title: String?
            }

            let rows = try dateDecoder.decode([ContributionRow].self, from: response.data)
            contributions = rows.map { row in
                let registryItem = row.giftReservations?.registryItems
                return ContributionHistoryItem(
                    id: row.id,
                    eventName: registryItem?.registries?.events?.title ?? "Registry Contribution",
                    giftName: registryItem?.itemName ?? "Gift contribution",
                    amount: CurrencyFormatter.format(row.amount),
                    date: row.createdAt?.formatted(date: .abbreviated, time: .omitted) ?? "Date unavailable",
                    imageUrl: registryItem?.imageUrl
                )
            }
        } catch {
            contributions = []
            errorMessage = error.localizedDescription
        }
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
}

#Preview {
    NavigationStack {
        ContributionHistoryView()
    }
}
