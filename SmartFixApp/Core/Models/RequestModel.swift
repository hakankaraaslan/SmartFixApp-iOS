//
//  Request.swift
//  SmartFixApp
//
//  Created by Ahmet Hakan Karaaslan on 8.04.2026.
//

import Foundation

struct RepairRequestModel: Codable, Sendable {
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
    let cityKey: String
    let state: String?
    let customerAddress: UserAddress?
    
    let status: RequestStatus
    let acceptedOfferId: String?
    let acceptedTechnicianId: String?
    
    let createdAt: TimeInterval
}

enum RequestStatus: String, Codable, Sendable {
    case open          // hiç teklif yok
    case pending       // teklif geldi, customer karar bekliyor
    case offerAccepted // bir teklif kabul edildi
    case completed
    case cancelled
}
