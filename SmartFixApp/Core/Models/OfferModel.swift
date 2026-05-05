//
//  OfferModel.swift
//  SmartFixApp
//
//  Created by Oğuzhan Abuhanoğlu on 4.05.2026.
//

import Foundation

struct OfferModel: Codable, Sendable {
    let id: String
    let requestId: String
    let customerId: String

    let technicianId: String
    let technicianName: String

    let requestTitle: String
    let requestCategory: String
    let requestDeviceName: String
    let requestCity: String

    let price: String
    let estimatedTime: String

    let status: OfferStatus
    let createdAt: TimeInterval
}

enum OfferStatus: String, Codable, Sendable {
    case pending
    case accepted
    case rejected
    case completed
    case cancelled
}
