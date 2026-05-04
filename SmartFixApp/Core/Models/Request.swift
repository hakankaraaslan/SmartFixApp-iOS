//
//  Request.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 8.04.2026.
//

import Foundation

struct RepairRequestModel: Codable {
    let id: String
    let customerId: String
    let customerName: String

    let category: String
    let deviceName: String
    let title: String
    let detailDescription: String
    let brand: String?
    let model: String?

    let city: String
    let state: String?
    let customerAddress: UserAddress?

    let status: RequestStatus
    let acceptedOfferId: String?
    let acceptedTechnicianId: String?
}

enum RequestStatus: String, Codable {
    case open
    case offerAccepted
    case completed
    case cancelled

}

struct Offer {
    let id: String
    let requestId: String
    let technicianName: String
    let price: String
    let estimatedTime: String
}
