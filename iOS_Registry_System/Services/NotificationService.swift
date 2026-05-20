//
//  NotificationService.swift
//  iOS_Registry_System
//
//  Service for managing in-app notifications
//

import Foundation
import PostgREST
import Supabase

final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    // MARK: - Create

    func createNotification(
        userId: UUID,
        registryId: UUID? = nil,
        type: String,
        title: String,
        body: String
    ) async throws {
        struct NotificationInsert: Encodable {
            let id: String
            let user_id: String
            let registry_id: String?
            let type: String
            let title: String
            let body: String
            let is_read: Bool
        }

        let insert = NotificationInsert(
            id: UUID().uuidString,
            user_id: userId.uuidString,
            registry_id: registryId?.uuidString,
            type: type,
            title: title,
            body: body,
            is_read: false
        )

        let _ = try await SupabaseManager.shared.client
            .from("notifications")
            .insert(insert)
            .execute()
    }

    // MARK: - Read

    func fetchNotifications(for userId: UUID) async throws -> [Notification] {
        let response = try await SupabaseManager.shared.client
            .from("notifications")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .limit(50)
            .execute()

        return try decoder.decode([Notification].self, from: response.data)
    }

    // MARK: - Mark Read

    func markAsRead(notificationId: UUID) async throws {
        struct ReadUpdate: Encodable { let is_read: Bool }
        try await SupabaseManager.shared.client
            .from("notifications")
            .update(ReadUpdate(is_read: true))
            .eq("id", value: notificationId.uuidString)
            .execute()
    }

    func markAllAsRead(for userId: UUID) async throws {
        struct ReadUpdate: Encodable { let is_read: Bool }
        try await SupabaseManager.shared.client
            .from("notifications")
            .update(ReadUpdate(is_read: true))
            .eq("user_id", value: userId.uuidString)
            .eq("is_read", value: false)
            .execute()
    }

    // MARK: - Decoder

    private var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let str = try container.decode(String.self)

            let iso = ISO8601DateFormatter()
            iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = iso.date(from: str) { return date }

            iso.formatOptions = [.withInternetDateTime]
            if let date = iso.date(from: str) { return date }

            let fmt = DateFormatter()
            fmt.locale = Locale(identifier: "en_US_POSIX")
            fmt.timeZone = TimeZone(secondsFromGMT: 0)
            for format in ["yyyy-MM-dd HH:mm:ssX", "yyyy-MM-dd'T'HH:mm:ssX", "yyyy-MM-dd"] {
                fmt.dateFormat = format
                if let date = fmt.date(from: str) { return date }
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid date: \(str)"
            )
        }
        return d
    }
}
