//
//  Contribution.swift
//  iOS_Registry_System
//
//  Contribution model — tracks gift contributions
//

import Foundation

// MARK: - Contribution

struct Contribution: Codable, Identifiable, Hashable {
    let id: UUID
    var reservationId: UUID
    var contributorBy: UUID? = nil
    var amount: Double
    var contributionType: String? = nil
    var paymentStatus: String? = nil
    var transactionReference: String? = nil
    var message: String? = nil
    var createdAt: Date? = nil

    enum CodingKeys: String, CodingKey {
        case id
        case reservationId = "reservation_id"
        case contributorBy = "contributor_by"
        case amount
        case contributionType = "contribution_type"
        case paymentStatus = "payment_status"
        case transactionReference = "transaction_reference"
        case message
        case createdAt = "created_at"
    }
}

