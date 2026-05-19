//
//  ProfileViewModel.swift
//  iOS_Registry_System
//
//  Profile screen view model
//

import SwiftUI
import Supabase

// MARK: - Profile View Model

@MainActor
@Observable
final class ProfileViewModel {

    // MARK: State

    var user: User?
    var totalContributions: Int = 0
    var totalContributedAmount: Double = 0
    var eventsHosted: Int = 0
    var totalEvents: Int = 0
    var giftsCount: Int = 0
    var walletBalance: Double = 0
    var isLoading = false
    var isSaving = false
    var errorMessage: String?

    // MARK: - Actions

    func loadProfile() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            await AuthService.shared.fetchCurrentUser()
            guard let currentUser = AuthService.shared.currentUser else {
                user = nil
                resetStats()
                return
            }

            user = currentUser
            AppState.shared.currentUser = currentUser
            try await loadProfileStats(userId: currentUser.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func signOut() async {
        do {
            try await AuthService.shared.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Input for `saveProfile` — bundled into a struct to work around a Swift
    /// `@Observable` + `@MainActor` + `async` ABI bug where multiple `String`
    /// parameters get shifted in the stack frame.
    struct ProfileSaveInput: Sendable {
        let name: String
        let email: String
        let phone: String?
        let image: UIImage?
    }

    func saveProfile(_ input: ProfileSaveInput) async {
        guard let user else { return }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        let cleanName = input.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanEmail = input.email.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanPhone = input.phone?.trimmingCharacters(in: .whitespacesAndNewlines)
        let nameParts = cleanName.split(separator: " ", maxSplits: 1).map(String.init)

        struct UserProfileUpdate: Encodable {
            let full_name: String
            let email: String
            let phone: String?
            let first_name: String?
            let last_name: String?
            let avatar_url: String?
        }

        var newAvatarUrl: String? = nil
        
        do {
            // Verify session exists right before upload
            let session = try await SupabaseManager.shared.client.auth.session
            print("Current active session user: \(session.user.id)")
            
            if let image = input.image {
                let resizedImage = resizeImage(image, targetSize: CGSize(width: 512, height: 512))
                if let imageData = resizedImage.jpegData(compressionQuality: 0.8) {
                    let fileName = "\(user.id.uuidString)-\(UUID().uuidString).jpg"
                
                // Write to temp file to avoid URLSession HTTP/2 stream bug (-1017 protocol violation)
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                try imageData.write(to: tempURL)
                
                try await SupabaseManager.shared.client.storage
                    .from("avatars")
                    .upload(
                        fileName,
                        fileURL: tempURL,
                        options: FileOptions(cacheControl: "3600", contentType: "image/jpeg", upsert: false)
                    )
                
                try? FileManager.default.removeItem(at: tempURL)
                
                newAvatarUrl = try SupabaseManager.shared.client.storage
                    .from("avatars")
                    .getPublicURL(path: fileName).absoluteString
                }
            }
        } catch {
            print("Failed to upload avatar: \(error)")
            // We can continue saving the profile even if avatar fails
        }

        let update = UserProfileUpdate(
            full_name: cleanName,
            email: cleanEmail,
            phone: cleanPhone?.isEmpty == true ? nil : cleanPhone,
            first_name: nameParts.first,
            last_name: nameParts.dropFirst().first,
            avatar_url: newAvatarUrl
        )

        do {
            // 1. Update the Auth User Metadata (Primary source of truth, often syncs to public.users via trigger)
            var authData: [String: AnyJSON] = [
                "full_name": .string(cleanName),
                "name": .string(cleanName)
            ]
            if let first = nameParts.first { authData["first_name"] = .string(first) }
            if let last = nameParts.dropFirst().first { authData["last_name"] = .string(last) }
            if let phone = cleanPhone, !phone.isEmpty {
                authData["phone"] = .string(phone)
            } else {
                authData["phone"] = .null
            }
            if let avatarUrl = newAvatarUrl {
                authData["avatar_url"] = .string(avatarUrl)
            }

            let attributes = UserAttributes(
                email: cleanEmail != user.email ? cleanEmail : nil,
                data: authData
            )
            try await SupabaseManager.shared.client.auth.update(user: attributes)
            
            // 2. Attempt to update public.users directly 
            // Note: We intentionally omit .select().single() here. If your backend RLS blocks
            // direct updates to public.users, this will silently ignore the public update rather than crashing.
            try await SupabaseManager.shared.client
                .from("users")
                .update(update)
                .eq("id", value: user.id.uuidString)
                .execute()

            await AuthService.shared.fetchCurrentUser()
            self.user = AuthService.shared.currentUser
            AppState.shared.currentUser = self.user
        } catch {
            print("Error updating profile: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Derived values

    var displayName: String {
        guard let user else { return "" }
        let fullName = user.fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !fullName.isEmpty { return fullName }

        let firstLast = [user.firstName, user.lastName]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
        if !firstLast.isEmpty { return firstLast }

        return user.email
    }

    var subtitle: String {
        guard let user else { return "" }

        var parts: [String] = []
        if !user.email.isEmpty {
            parts.append(user.email)
        }
        if let createdAt = user.createdAt {
            parts.append("Joined \(createdAt.formatted(.dateTime.month(.abbreviated).year()))")
        }
        return parts.joined(separator: " · ")
    }

    var initials: String {
        let source = displayName
        let words = source.split(separator: " ")
        let letters = words.prefix(2).compactMap { $0.first }
        let value = String(letters).uppercased()
        return value.isEmpty ? "U" : value
    }

    var totalEventsText: String {
        "\(totalEvents)"
    }

    var contributedText: String {
        compactCurrency(totalContributedAmount)
    }

    var giftsText: String {
        "\(giftsCount)"
    }

    // MARK: - Supabase helpers

    private func loadProfileStats(userId: UUID) async throws {
        let ownedEventIds = try await fetchOwnedEventIds(userId: userId)
        let memberEventIds = try await fetchMemberEventIds(userId: userId)
        let contributionAmounts = try await fetchContributionAmounts(userId: userId)

        eventsHosted = ownedEventIds.count
        totalEvents = Set(ownedEventIds + memberEventIds).count
        totalContributions = contributionAmounts.count
        totalContributedAmount = contributionAmounts.reduce(0, +)
        giftsCount = try await fetchGiftReservationCount(userId: userId)
        walletBalance = try await fetchWalletBalance(ownedEventIds: ownedEventIds)
    }

    private func resetStats() {
        totalContributions = 0
        totalContributedAmount = 0
        eventsHosted = 0
        totalEvents = 0
        giftsCount = 0
        walletBalance = 0
    }

    private func fetchOwnedEventIds(userId: UUID) async throws -> [UUID] {
        let response = try await SupabaseManager.shared.client
            .from("events")
            .select("id")
            .eq("owner_user_id", value: userId.uuidString)
            .execute()

        struct Row: Decodable { let id: UUID }
        return try decoder.decode([Row].self, from: response.data).map(\.id)
    }

    private func fetchMemberEventIds(userId: UUID) async throws -> [UUID] {
        let response = try await SupabaseManager.shared.client
            .from("event_members")
            .select("event_id")
            .eq("user_id", value: userId.uuidString)
            .eq("status", value: "accepted")
            .execute()

        struct Row: Decodable { let event_id: UUID }
        return try decoder.decode([Row].self, from: response.data).map(\.event_id)
    }

    private func fetchContributionAmounts(userId: UUID) async throws -> [Double] {
        let response = try await SupabaseManager.shared.client
            .from("contributions")
            .select("amount")
            .eq("contributor_by", value: userId.uuidString)
            .execute()

        struct Row: Decodable { let amount: Double }
        return try decoder.decode([Row].self, from: response.data).map(\.amount)
    }

    private func fetchGiftReservationCount(userId: UUID) async throws -> Int {
        let response = try await SupabaseManager.shared.client
            .from("gift_reservations")
            .select("id")
            .eq("reserved_by", value: userId.uuidString)
            .execute()

        struct Row: Decodable { let id: UUID }
        return try decoder.decode([Row].self, from: response.data).count
    }

    private func fetchWalletBalance(ownedEventIds: [UUID]) async throws -> Double {
        guard !ownedEventIds.isEmpty else { return 0 }

        let registryResponse = try await SupabaseManager.shared.client
            .from("registries")
            .select("id")
            .in("event_id", values: ownedEventIds.map(\.uuidString))
            .execute()

        struct RegistryRow: Decodable { let id: UUID }
        let registryIds = try decoder.decode([RegistryRow].self, from: registryResponse.data).map(\.id)
        guard !registryIds.isEmpty else { return 0 }

        let creditsResponse = try await SupabaseManager.shared.client
            .from("wallet_credits")
            .select("amount")
            .in("registry_id", values: registryIds.map(\.uuidString))
            .eq("status", value: "available")
            .execute()

        struct CreditRow: Decodable { let amount: Double }
        return try decoder.decode([CreditRow].self, from: creditsResponse.data)
            .map(\.amount)
            .reduce(0, +)
    }

    private var decoder: JSONDecoder {
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

            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)

            let formats = [
                "yyyy-MM-dd HH:mm:ss.SSSX",
                "yyyy-MM-dd HH:mm:ss.SSSZZZZZ",
                "yyyy-MM-dd HH:mm:ss.SSSZ",
                "yyyy-MM-dd HH:mm:ss.SSSSSSX",
                "yyyy-MM-dd HH:mm:ss.SSSSSSZZZZZ",
                "yyyy-MM-dd HH:mm:ss.SSSSSSZ",
                "yyyy-MM-dd HH:mm:ssX",
                "yyyy-MM-dd HH:mm:ssZZZZZ",
                "yyyy-MM-dd HH:mm:ssZ",
                "yyyy-MM-dd'T'HH:mm:ss.SSSX",
                "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ",
                "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSX",
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZZZZZ",
                "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ",
                "yyyy-MM-dd'T'HH:mm:ssX",
                "yyyy-MM-dd'T'HH:mm:ssZZZZZ",
                "yyyy-MM-dd'T'HH:mm:ssZ",
                "yyyy-MM-dd"
            ]

            for format in formats {
                formatter.dateFormat = format
                if let date = formatter.date(from: dateStr) {
                    return date
                }
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

    // MARK: - Image Resizing

    private func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        if scaleFactor >= 1.0 { return image }
        
        let scaledSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: scaledSize, format: format)
        
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: scaledSize))
        }
    }
}
